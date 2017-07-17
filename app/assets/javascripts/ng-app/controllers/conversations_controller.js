angular.module('blnkk.controllers')
  .controller('DashboardController', ['$scope', '$rootScope', '$filter', '$location', '$state', '$stateParams', '$timeout', 'Analytics', 'Alerts', 'Conversation', 'SocketMessages', 'Rating', function($scope, $rootScope, $filter, $location, $state, $stateParams, $timeout, Analytics, Alerts, Conversation, SocketMessages, Rating){
    var theController = this;
    var checkUsersOnlineStatusPromise;
    var conversationDataToSend;
    $scope.isLoadingConversations = true;
    

    var loadConversations = function() {
      if ($scope.session.connected) {
        $scope.isLoadingConversations = true;
        Conversation.getAll()
          .then( function(conversations) {
            $scope.conversations = conversations;
            $rootScope.$broadcast('reloadSelectedConversation');
            checkUsersOnlineStatus();
            $scope.isLoadingConversations = false;
          }, function(message) {
            $scope.isLoadingConversations = false;
            Alerts.add('danger', message);
          });
      }
    };
    var checkUsersOnlineStatus = function() {
      var user_ids = [];
      for (var i=0; i<$scope.conversations.length; i++) {
        // $scope.typingMessageSent[$scope.conversations[i].id] = false;
        for (var j=0; j<$scope.conversations[i].users.length; j++) {
          if ($scope.conversations[i].users[j].id != $scope.session.user.id) {
            user_ids.push($scope.conversations[i].users[j].id);
            break;
          }
        }
      }
      SocketMessages.getUsersOnlineStatus(user_ids);
    };

    if ($scope.session.connected) {
      loadConversations();
    }

    $rootScope.$on('reloadConversations', function(event, args) {
      loadConversations();
    });

    $rootScope.$on('user-loaded', function(event, args) {
      if ($scope.conversations == null) {
        loadConversations();
      }
    });

    $rootScope.$on('connexion-change', function(event, args) {
      if (!args.signedIn) {
        $scope.conversations = [];
        Conversation.data.selectedConversation = $scope.selectedConversation = null;
      } else {
        loadConversations();
      }
    });

    $rootScope.$on('socket-connexion', function(event, args) {
      if (!args.connected) {
        if ($scope.conversations) {
          for (var i=0; i<$scope.conversations.length; i++) {
            $scope.conversations[i].isTyping = $scope.conversations[i].user.online = false;
          }
        }
      } else {
        if ($scope.conversations) {
          checkUsersOnlineStatus();
        }
      }
    });


  }])







  .controller('ConversationShowController', ['$scope', '$rootScope', '$filter', '$location', '$state', '$stateParams', '$timeout', '$element', 'Analytics', 'Alerts', 'Conversation', 'SocketMessages', 'Rating', function($scope, $rootScope, $filter, $location, $state, $stateParams, $timeout, $element, Analytics, Alerts, Conversation, SocketMessages, Rating){
    var theController = this;
    var isTypingPromise;
    var TYPING_TIMEOUT = 20000;
    $scope.isLoadingConversation = false;
    $scope.typingMessageSent = {};


    var getConversation = function() {
      $scope.conversations = Conversation.data.conversations;
      if ($scope.conversations.length == 0){
        return;
      }
      var conversationId = $stateParams.id;
      if (!angular.isDefined(conversationId)){
        return;
      }

      $scope.isLoadingConversation = !$scope.selectedConversation || conversationId != $scope.selectedConversation.id;
      // $state.current.reloadOnSearch = false;
      // $location.replace();
      // $location.search('conversationId', conversationId);
      // $state.params = { conversationId: conversationId };
      // $timeout(function () {
      //   $state.current.reloadOnSearch = true;  
      // },0);
      var conversationToUpdate = $filter('filter')($scope.conversations, { id: parseInt(conversationId) }, true)[0];
      if (conversationToUpdate && conversationToUpdate.unread){
        $scope.session.user.unread_conversations_count = $scope.session.user.unread_conversations_count - 1;  
      }

      Conversation.getById(conversationId)
        .then( function(conversation) {
          $scope.selectedConversation = conversation;
          setNotTypingForSelectedConversation();
          setTitle($rootScope, conversation.user.name + " - " + I18n.t("conversations.title"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
          
          // $scope.selectedConversation.user.online = conversationToUpdate.online;
          if (conversationToUpdate){
            Conversation.data.selectedConversation.isTyping = conversationToUpdate.isTyping;
            conversationToUpdate.unread = false;
          }
          
          // SocketMessages.notifyConversationRead( $scope.session.user.id, Conversation.data.selectedConversation.id );
          Rating.getRatings('Conversation', conversationId)
            .then( function(ratings) {
              if (ratings.length > 0) {
                $scope.selectedConversation.user_rating = ratings[0].rating;
              } else {
                $scope.selectedConversation.user_rating = 0;
              }
            }, function(message) {
              Alerts.add('danger', message);
            });
          $scope.isLoadingConversation = false;
          $timeout(function () {
            $('#messageReply').keyup();
            if ($(window).width() >= 768){
              $('#messageReply').focus();
            }
          },100);
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoadingConversation = false;
          $timeout(function () {
            $('#messageReply').keyup();
            if ($(window).width() >= 768){
              $('#messageReply').focus();
            }
          },100);
        });
    };
    // $scope.replyToRequest = function() {
    //   $scope.isPosting = true;
    //   var conversationData = { message: {content: $filter('htmlToPlaintext')($scope.requestInfo.reply)}, request_id: $scope.request.id };
    //   SocketMessages.postMessage(conversationData,
    //     function() {
    //       $scope.requestInfo.reply = '';
    //       $scope.hasReplied = true;
    //       $scope.isPosting = false;
    //       $scope.$apply();
    //     }, function() {
    //       $scope.isPosting = false;
    //       alertsService.add('danger', 'Sending of message failed.');
    //     });
    // };
    $scope.addMessage = function (conversationId, messageContent) {
      if ($scope.isPosting){
        return;
      }
      $scope.isPosting = true;
      theController.conversationDataToSend = { conversationId: conversationId, messageContent: messageContent };
      var conversationData = { message: {content: $filter('htmlToPlaintext')(messageContent), conversation_id: conversationId} };
      SocketMessages.postMessage(conversationData,
        function() {
          theController.conversationDataToSend = null;
          $scope.messageReply[conversationId] = '';
          $scope.typingMessageSent[$scope.selectedConversation.id] = false;
          setNotTypingForSelectedConversation();
          $scope.isPosting = false;
          $timeout(function () {
            $('#messageReply').keyup();
            if ($(window).width() >= 768){
              $('#messageReply').focus();
            }
          },100);
        }, function(error) {
          theController.conversationDataToSend = null;
          $scope.isPosting = false;
          $timeout(function () {
            $('#messageReply').keyup();
            if ($(window).width() >= 768){
              $('#messageReply').focus();
            }
          },100);
          if (error.status == 'conflict') {
            $scope.messageReply[conversationId] = '';
            $scope.typingMessageSent[$scope.selectedConversation.id] = false;
            setNotTypingForSelectedConversation();
            loadConversations();
          } else {
            Alerts.add('danger', I18n.t("conversations.send_failed"));
          }
        });
    };

    var sendIsTypingMessage = function(conversationId, isTyping) {
      SocketMessages.sendIsTypingMessage(conversationId, isTyping,
        function() {
          $scope.typingMessageSent[$scope.selectedConversation.id] = isTyping;
        }, function() {
          Alerts.add('danger', I18n.t("conversations.websocket_error"));
        });
    };

    if ($scope.session.connected) {
      getConversation();
    }

    $scope.$on('reloadSelectedConversation', function(event, args) {
      if($scope.isPosting && theController.conversationDataToSend) {
        $scope.isPosting = false;
        $scope.addMessage(theController.conversationDataToSend.conversationId, theController.conversationDataToSend.messageContent);
      }
      getConversation();
    });

    $scope.$on('user-loaded', function(event, args) {
      if ($scope.selectedConversation == null) {
        Conversation.data.selectedConversation = $scope.selectedConversation = null;
        getConversation();
      }
    });

    $scope.$on('connexion-change', function(event, args) {
      if (!args.signedIn) {
        Conversation.data.selectedConversation = $scope.selectedConversation = null;
      } else {
        getConversation();
      }
    });

    $scope.$on('socket-connexion', function(event, args) {
      if (!args.connected) {
        if ($scope.selectedConversation) {
          $scope.selectedConversation.isTyping = $scope.selectedConversation.user.online = false;
        }
      }
    });

    $scope.$on("$destroy", function() {
      Conversation.data.selectedConversation = $scope.selectedConversation = null;
    });

    $scope.replyChangedHandler = function() {
      if (angular.isDefined(isTypingPromise)) {
        $timeout.cancel(isTypingPromise);
      }
      if (typeof $scope.messageReply !== "undefined" && $scope.messageReply[$scope.selectedConversation.id] && $scope.messageReply[$scope.selectedConversation.id].length > 0) {
        isTypingPromise = $timeout(setNotTypingForSelectedConversation, TYPING_TIMEOUT);
        if (!$scope.typingMessageSent[$scope.selectedConversation.id]) {
          sendIsTypingMessage($scope.selectedConversation.id, true);  
        }
      } else if ($scope.typingMessageSent[$scope.selectedConversation.id] && ($scope.messageReply[$scope.selectedConversation.id] == null || $scope.messageReply[$scope.selectedConversation.id] == '')) {
        sendIsTypingMessage($scope.selectedConversation.id, false);
      }
    };

    var setNotTypingForSelectedConversation = function() {
      if (angular.isDefined(isTypingPromise)) {
        $timeout.cancel(isTypingPromise);
      }
      if ($scope.selectedConversation != null) {
        sendIsTypingMessage($scope.selectedConversation.id, false);
      }
    };

    $('#messageReply').keyup(function(event) {
      var messageReply = $('#messageReply')[0];
      var messagesBox = $('.messages:not(.ng-hide)');

      var atBottom = messagesBox[0].scrollHeight - messagesBox.scrollTop() == messagesBox.outerHeight();

      $(messageReply).height( 0 );
      var newHeight = Math.min(100, Math.max(20, messageReply.scrollHeight-12));
      $(messageReply).height( newHeight );

      $('.messages').css("bottom",($element.find('.item-footer').outerHeight()+20)+"px");
      if (atBottom){
        $timeout( function() {
          messagesBox.scrollTop(messagesBox[0].scrollHeight);
        }, 100);
      }
    });

    $('#messageReply').keydown(function(event) {
      if (event.keyCode == 13 && !event.ctrlKey && !event.shiftKey) { // Enter pressed without control
        if (typeof $scope.messageReply !== "undefined" && $scope.messageReply[$scope.selectedConversation.id].length > 0){
          $scope.addMessage($scope.selectedConversation.id, $scope.messageReply[$scope.selectedConversation.id]);
        }
        return false;
      }
      if ((event.keyCode == 13 || event.keyCode == 10) && (event.ctrlKey || event.shiftKey)) { // Ctrl+Enter pressed
        var messageReply = $('#messageReply')[0];
        var val = messageReply.value;
        if (typeof messageReply.selectionStart == "number" && typeof messageReply.selectionEnd == "number") {
            var start = messageReply.selectionStart;
            messageReply.value = val.slice(0, start) + "\n" + val.slice(messageReply.selectionEnd);
            messageReply.selectionStart = messageReply.selectionEnd = start + 1;
        } else if (document.selection && document.selection.createRange) {
            messageReply.focus();
            var range = document.selection.createRange();
            range.text = "\r\n";
            range.collapse(false);
            range.select();
        }
        return false;
      }
    });

    $('#messageReplySubmit').click(function(event){
      if (typeof $scope.messageReply !== "undefined" && $scope.messageReply[$scope.selectedConversation.id].length > 0){
        $scope.addMessage($scope.selectedConversation.id, $scope.messageReply[$scope.selectedConversation.id]);
      }
      return false;
    });

  }])
;