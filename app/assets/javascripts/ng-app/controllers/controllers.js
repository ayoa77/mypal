'use strict';

var setTitle = function(rootScope, title, count, analytics) {
  var prefix = (count > 0 ? '(' + count + ') ' : '');

  if (title){
    // title += " - " + settings["SUBSITE"] + " " + settings["SITE_NAME"];
    title += " - " + " " + settings["SITE_NAME"];
  } else {
    title = settings["SUBSITE"] + " " + settings["SITE_NAME"] + " - ";
    if (I18n.locale == settings["LOCALE_SECONDARY"]){
      title += settings["TAGLINE_SECONDARY"];
    } else {
      title += settings["TAGLINE_PRIMARY"];
    }
  }


  rootScope.title = prefix + title;
  // analytics.trackPage();
  setTimeout(function(){analytics.trackPage();},0);
}

var signInWithFacebook = function(signinType, alerts, state, window, facebookAuthentication, redirectTo) {
  alerts.clear();
  var pathToRedirect;
  if (redirectTo) {
    pathToRedirect = state.href(redirectTo);
  } else {
    pathToRedirect = state.href(state.current.name);
  }
  window.location.href = facebookAuthentication.getAuthenticationURL(pathToRedirect, signinType);
};

/* Controllers */

angular.module('blnkk.controllers', [ 'persona' ])
  .controller('AlertsController', ['$scope', 'Alerts', function( $scope, Alerts ){
    $scope.alerts = Alerts;
    $scope.closeAlert = function(index) {
      Alerts.removeAt(index);
    };
  }])

  .controller('SessionController', ['$rootScope', '$scope', '$state', '$location', '$document', '$window', '$filter', '$timeout', '$interval', '$uibModal', 'notify', 'Authentication', 'User', 'Tag', 'Persona', 'Alerts', 'SocketMessages', 'Conversation', 'Request', 'Contact', 'Analytics', 'FacebookAuthentication', function($rootScope, $scope, $state, $location, $document, $window, $filter, $timeout, $interval, $uibModal, notify, Authentication, User, Tag, Persona, Alerts, SocketMessages, Conversation, Request, Contact, Analytics, FacebookAuthentication) {

    setTitle($rootScope, "", 0, Analytics);

    var alertsService = Alerts;
    var authService = Authentication;
    var hasToGetUserData = false;
    var theController = this;
    var wsReconnectPromise;
    var wsInitialTimeout = 5000;
    var wsCurrentTimeout = wsInitialTimeout;
    var isInitialSocketConnexion = true;
    $scope.session = { connected : authService.state.signedIn, user: {}, contacts: {}, isSigningIn: false };
    $rootScope.session = $scope.session; //Benji: is this hack OKAY with you?
    $scope.isRetrievingProfile = true;
    if ($location.search().auth_result == "error" || $location.search().auth_result == "unknown") {
      $location.search("");
      alertsService.add('danger', I18n.t("session.unable_sign_in"));
    } else if ($location.search().auth_result == "not_found") {
      $location.search("");
      alertsService.add('danger', I18n.t("services.auth_user_not_found"));
    } else if ($location.search().auth_result == "forbidden") {
      $location.search("");
      alertsService.add('danger', I18n.t("services.auth_user_forbidden"));
    } else if ($location.search().auth_result == "exist") {
      $location.search("");
      alertsService.add('danger', I18n.t("services.auth_user_already_exists"));
    }
    
    $scope.signIn = function(redirectTo, type) {
      // if (redirectToPath == null) {
      //   redirectToPath = $location.path();
      // }
      if (type == 'signin-Facebook' || type == 'signup-Facebook') {
        signInWithFacebook(type.split('-')[0], Alerts, $state, $window, FacebookAuthentication, redirectTo);
        return;
      }
      if (type != 'signin' && type != 'signup'){
        type = 'signin';
      }
      $uibModal.open({
        templateUrl: 'modals/signin.html',
        controller: 'SigninSelectionController',
        size: 'sm',
        resolve: {
          redirectTo: function () {
            return redirectTo;
          },
          type: function () {
            return type;
          }
        }
      });
    };
    $rootScope.signIn = $scope.signIn; //Benji: is this hack OKAY with you?
    
    $scope.sharePage = function(redirectTo) {
      $uibModal.open({
        templateUrl: 'modals/share-page.html',
        controller: 'modalCancelController',
        size: 'sm'
      });
    };
    var handleUsersOnlineStatus = function(onlineUsers) {
      for (var i=0; i<Conversation.data.conversations.length; i++) {
        var index = onlineUsers.users_id.indexOf(Conversation.data.conversations[i].user.id);
        Conversation.data.conversations[i].user.online = (index != -1);
      }
      if (Conversation.data.selectedConversation) {
        Conversation.data.selectedConversation.user.online = (onlineUsers.users_id.indexOf(Conversation.data.selectedConversation.user.id) != -1);
      }
      $scope.$apply();
    };
    var connectedUserHandler = function(onlineUser) {
      setOnlineStatusForUser(onlineUser.user_id, true);
    };
    var disconnectedUserHandler = function(onlineUser) {
      setOnlineStatusForUser(onlineUser.user_id, false);
      if (Conversation.data) {
        if (Conversation.data.selectedConversation.user.id == onlineUser.user_id) {
          Conversation.data.selectedConversation.isTyping = false;
        }
        for (var i=0; i<Conversation.data.conversations.length; i++) {
          if (Conversation.data.conversations[i].user.id == onlineUser.user_id) {
            Conversation.data.conversations[i].isTyping = false;
            break;
          }
        }
      }
      $scope.$apply();
    };
    var setOnlineStatusForUser = function(userId, online) {
      if (Conversation.data.selectedConversation && Conversation.data.selectedConversation.user.id == userId) {
        Conversation.data.selectedConversation.user.online = online;
      }
      for (var i=0; i<Conversation.data.conversations.length; i++) {
        if (Conversation.data.conversations[i].user.id == userId) {
          Conversation.data.conversations[i].user.online = online;
          break;
        }
      }
      $scope.$apply();
    };
    var userTypingHandler = function(data) {
      var conversationToUpdate = $filter('filter')(Conversation.data.conversations, { id: data.conversation_id }, false)[0];
      if (conversationToUpdate) {
        conversationToUpdate.isTyping = data.is_typing;
      }
      if (Conversation.data.selectedConversation && Conversation.data.selectedConversation.id == data.conversation_id) {
        Conversation.data.selectedConversation.isTyping = data.is_typing;
      }
      $scope.$apply();
    };
    var showNotification = function(title, avatar, messageContent, conversationId) {
      var watchingThisConversation = false;
      if (angular.isDefined($state.params.id)) {
        watchingThisConversation = ($state.current.name == 'home.conversation' && $state.params.id == conversationId);
      }
      if (Visibility.hidden() || !watchingThisConversation) {
        var myNotification = new Notify(title, {
          body: messageContent,
          notifyClick: function(event) {
            window.focus();
            $state.go('home.conversation', {id: conversationId});
          },
          icon: avatar,
          timeout: 5,
          tag: 'messageUpdate',
          notifyError: function(err) { console.log("Error"); },
          permissionDenied: function() { console.log("Denied"); },
          permissionGranted: function() { console.log("Granted"); }
        });
        if (Notify.permissionLevel == 'default') {
          Notify.requestPermission( function() { myNotification.show(); }, function() { console.log("Denied"); });
        } else if (Notify.permissionLevel == 'granted') {
          myNotification.show();
        }
      }
    };
    var newConversationHandler = function(conversation) {
      $rootScope.$broadcast('reloadConversations');
      if (!conversation.from_self) {
        $scope.session.user.unread_conversations_count = conversation.unread_conversations_count;
        $scope.$apply();
        showNotification(I18n.t("session.new_message_from", {name: conversation.from_user}), conversation.user_avatar, conversation.content, conversation.conversation_id);
      }
    };
    var newMessageHandler = function(update) {
      update.message.created_at = Math.round(new Date().getTime() / 1000);
      update.message.user = { name: update.from_user, avatar_url: update.user_avatar };
      if (!update.from_self && !update.message.system_generated) {
        showNotification(I18n.t("session.new_message_from", {name: update.from_user}), update.user_avatar, update.message.content, update.conversation_id);
        if (Conversation.data.selectedConversation) {
          Conversation.data.selectedConversation.isTyping = false;
        }
      }
      if ($state.current.name == 'home.conversation' && Conversation.data.selectedConversation != null && update.message.conversation_id == Conversation.data.selectedConversation.id) {
          // if (message.system_generated && message.user_id != $scope.session.user.id) {
          //   $scope.getConversation(Conversation.selectedConversation.id);
          // } else {
            Conversation.data.selectedConversation.updated_at = update.message.created_at;
            Conversation.data.selectedConversation.messages.push(update.message);
            if (Visibility.hidden()) {
              $scope.session.user.unread_conversations_count = update.unread_conversations_count;
            } else {
              SocketMessages.notifyConversationRead( $scope.session.user.id, Conversation.data.selectedConversation.id );
            }
          // }
      } else {
        $scope.session.user.unread_conversations_count = update.unread_conversations_count;
      }
      for (var i=0; i<Conversation.data.conversations.length; i++) {
        if (Conversation.data.conversations[i].id == update.message.conversation_id) {
          if (!update.from_self && !update.message.system_generated) {
            Conversation.data.conversations[i].isTyping = false;
          }
          Conversation.data.conversations[i].updated_at = update.message.created_at;
          if (Conversation.data.selectedConversation == null || (update.message.conversation_id != Conversation.data.selectedConversation.id)) {
            Conversation.data.conversations[i].unread = true;
            Conversation.data.conversations.unshift(Conversation.data.conversations.splice(i, 1)[0]);
          }
          break;
        }
      }
      $scope.$apply();
    };
    var newNotificationReadCountHandler = function(update) {
      $scope.session.user.unread_notifications_count = update.count;
      $scope.$apply();
    };
    var newConversationReadCountHandler = function(update) {
      $scope.session.user.unread_conversations_count = update.count;
      $scope.$apply();
    };
    var handleMessageSocketReconnect = function() {
      $rootScope.$broadcast('reloadConversations');
    };
    var askForDesktopNotificationPermission = function() {
      if (Notify.needsPermission && Notify.permissionLevel == 'default') {
        // Ask for 
        Notify.requestPermission( function() {
          // alertsService.add('success', 'Well done! You will get desktop notifications when you receive a new message.');
          $scope.$apply();
        }, function() { });
        // alertsService.add('info', 'To get desktop notifications when you receive a new message, please select Allow when your browser asks for authorization.');
      }
    };
    User.getData()
      .then( function(userData) {
        $scope.session.user = userData;
        $scope.session.connected = true;
        hasToGetUserData = false;
        // authService.watchWith(userData.email);
        $scope.isRetrievingProfile = false;
        $rootScope.$broadcast('user-loaded');
        $scope.connectToWebSocket();
        askForDesktopNotificationPermission();
      }, function(message) {
        hasToGetUserData = true;
        authService.watchWith(undefined);
        $scope.isRetrievingProfile = false;
      });

    var wsInitialTime = 5;
    var wsCurrentTime = wsInitialTime;
    $scope.remainingSeconds = wsInitialTime;
    $scope.wsIsReconnecting = false;
    var messageTemplate = '<div><span ng-hide="wsIsReconnecting" ng-bind-html="\'session.reconnecting_in\' | t:{remainingSeconds: remainingSeconds}"></span> <span ng-hide="wsIsReconnecting"><a href ng-click="connectToWebSocket()">' + I18n.t("session.retry") + '</a></span><span ng-show="wsIsReconnecting">' + I18n.t("session.trying_reconnect") + '</span></div>';
    notify.config( {duration: 0} );
        
    $rootScope.$on('socket-connexion', function(event, args) {
      $rootScope.isMessagingAvailable = args.connected;
      $scope.wsIsReconnecting = false;
      if (angular.isDefined(wsReconnectPromise)) {
        $interval.cancel(wsReconnectPromise);
      }
      if (args.connected) {
        notify.closeAll();
        wsCurrentTime = wsInitialTime;
        $rootScope.$broadcast('reloadConversations');
        isInitialSocketConnexion = false;
      } else {
        if (args.mustReconnect) {
          if (wsCurrentTime == wsInitialTime*2) {
            notify({
              messageTemplate: messageTemplate,
              scope: $scope
            });
          }
          
          $scope.remainingSeconds = wsCurrentTime;
          console.info("WebSocket: reconnecting in " + wsCurrentTime + "s");
          wsReconnectPromise = $interval(checkConnectWebSocketInterval, 1000, wsCurrentTime);
          if (wsCurrentTime < 300) {
            wsCurrentTime = wsCurrentTime*2;
          }
        }
      }
    });
    var checkConnectWebSocketInterval = function() {
      $scope.remainingSeconds--;
      if ($scope.remainingSeconds == 0) {
        $scope.connectToWebSocket();
      }
    };
    $scope.connectToWebSocket = function() {
      if (angular.isDefined(wsReconnectPromise)) {
        $interval.cancel(wsReconnectPromise);
        $scope.wsIsReconnecting = true;
      }
      if ($scope.session.connected) {
        SocketMessages.connect($scope.session.user.id, $scope.session.user.socket_key, handleUsersOnlineStatus, connectedUserHandler, disconnectedUserHandler, newMessageHandler, newConversationHandler, userTypingHandler, newConversationReadCountHandler, newNotificationReadCountHandler);
      }
    };
    $rootScope.$on('connecting', function(event, args) {
      $scope.session.isSigningIn = true;
    });
    $rootScope.$on('connexion-change', function(event, args) {
      if (args.signedIn) {
        $scope.session.connected = true;
        if (hasToGetUserData) {
          $scope.isRetrievingProfile = true;
          User.getData()
            .then( function(userData) {
              if ( $rootScope.redirectTo && $rootScope.redirectTo != '' ){
                $state.go( $rootScope.redirectTo );
              }
              $scope.session.user = userData;
              $scope.connectToWebSocket();
              $scope.isRetrievingProfile = false;
              askForDesktopNotificationPermission();
            }, function(message) {
              $scope.session.connected = false;
              alertsService.add('danger', message);
              $scope.signOut(false);
              $scope.isRetrievingProfile = false;
            })
        }
      } else {
        $scope.session.connected = false;
        User.resetData();
        Contact.resetData();
        $scope.session.user = User.data;
      }
      $scope.session.isSigningIn = false;
      hasToGetUserData = true;
    });
    // $scope.signIn = function( redirectTo ) {
    //   alertsService.clear();
    //   authService.signIn()
    //     .then(function() {
    //       $rootScope.redirectTo = redirectTo;
    //       // Wait for Persona event
    //     }, function(message) {
    //       alertsService.add('danger', message);
    //     });
    // };
    $scope.signOut = function(clearAlerts) {
      if (clearAlerts) {
        alertsService.clear();
      }
      if (angular.isDefined(wsReconnectPromise)) {
        $timeout.cancel(wsReconnectPromise);
      }
      notify.closeAll();
      wsCurrentTime = wsInitialTime;
		  authService.signOut().then(function(){
        SocketMessages.disconnect();
        $state.go('home.index');
        window.location.reload();      
      });

    };
    $scope.$watch('session.user.unread_notifications_count', function(newValue, oldValue) {
      updateTitleCount();
    });
    $scope.$watch('session.user.unread_conversations_count', function(newValue, oldValue) {
      updateTitleCount();
    });
    var updateTitleCount = function(){
      var new_count = 0;
      if ($scope.session.user.unread_notifications_count != null){
        new_count += $scope.session.user.unread_notifications_count;
      } 
      if ($scope.session.user.unread_conversations_count != null){
        new_count += $scope.session.user.unread_conversations_count;
      }
      if ($rootScope.title != null) {
        var new_count = $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count;
        var exprToFind = /^\([0-9]{1,4}\)\s/;
        if ( exprToFind.test($rootScope.title) ) {
          var replacement;
          if ($scope.session.connected) {
            replacement = (new_count == 0 ? '' : '(' + new_count + ') ');
          } else {
            replacement = '';
          }
          $document[0].title = $rootScope.title.replace(exprToFind, replacement);
        } else if (new_count > 0) {
          $document[0].title = $rootScope.title = '(' + new_count + ') ' + $rootScope.title;
        }
      }
    };

    $scope.toggleSidebar = function(){
      $document.find("#sidebar").toggleClass("open");
    };

    $scope.hideSidebar = function(){
      $document.find("#sidebar").removeClass("open");
    };

    $scope.setting = function(setting){
      return settings[setting];
    };
    $scope.isChina = function(){
      return settings['CHINA'] == 1;
    }
    $scope.isPrivate = function(){
      return settings['PRIVATE'] == 1;
    }
    $scope.localizeSetting = function(setting){
      if (I18n.locale == settings["LOCALE_SECONDARY"]){
        return settings[setting+"_SECONDARY"];        
      } else {
        return settings[setting+"_PRIMARY"];
      }
    };

    $scope.newRequestVisible = false;
    $scope.newRequestTag = '';
    $scope.setNewRequestVisibility = function(visible, tag){
      $scope.newRequestVisible = visible;
      $scope.newRequestTag = tag;
    }

  }])

  .controller('SigninSelectionController', ['$rootScope', '$scope', '$uibModalInstance', '$window', '$state', 'redirectTo', 'type', 'Authentication', 'Alerts', 'GoogleAuthentication', 'LinkedinAuthentication', 'FacebookAuthentication', function($rootScope, $scope, $uibModalInstance, $window, $state, redirectTo, type, Authentication, Alerts, GoogleAuthentication, LinkedinAuthentication, FacebookAuthentication) {
    $scope.signinType = type;
    $scope.cancel = function () {
      $uibModalInstance.close();
    };
    $scope.signinWithPersona = function() {
      Alerts.clear();
      Authentication.watchWith(undefined);
      Authentication.signIn($scope.signinType)
        .then(function() {
          $uibModalInstance.close();
          $rootScope.redirectTo = redirectTo;
          // Wait for Persona event
        }, function(message) {
          Alerts.add('danger', message);
        });
    };
    $scope.signInWithGoogle = function() {
      Alerts.clear();
      var pathToRedirect;
      if (redirectTo) {
        pathToRedirect = $state.href(redirectTo);
      } else {
        pathToRedirect = $state.href($state.current.name);
      }
      $window.location.href = GoogleAuthentication.getAuthenticationURL(pathToRedirect, $scope.signinType);
    };
    $scope.signInWithLinkedin = function() {
      Alerts.clear();
      var pathToRedirect;
      if (redirectTo) {
        pathToRedirect = $state.href(redirectTo);
      } else {
        pathToRedirect = $state.href($state.current.name);
      }
      $window.location.href = LinkedinAuthentication.getAuthenticationURL(pathToRedirect, $scope.signinType);
    };
    $scope.signInWithFacebook = function() {
      signInWithFacebook($scope, Alerts, $state, $window, FacebookAuthentication, redirectTo);
    };
    $scope.noAccountSignUp = function(){
      $uibModalInstance.close();
      $scope.signIn(null, 'signup');
    };
    $scope.isChina = function(){
      return settings['CHINA'] == 1;
    }
    $scope.isPrivate = function(){
      return settings['PRIVATE'] == 1;
    }
  }])

  .controller('modalCancelController', ['$rootScope', '$scope', '$uibModalInstance', function($rootScope, $scope, $uibModalInstance) {
    $scope.cancel = function () {
      $uibModalInstance.close();
    };
  }])

  .controller('UnsubscribeController', ['$rootScope', '$scope', 'Analytics', function($rootScope, $scope, Analytics) {
    setTitle($rootScope, I18n.t("unsubscribe.header"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
  }])

  .controller('PageController', ['$scope', '$rootScope', '$stateParams', 'Analytics', 'Alerts', 'Page', function($scope, $rootScope, $stateParams, Analytics, Alerts, Page){
    Page.getById($stateParams.id)
      .then( function(page) {
        setTitle($rootScope, page.header, $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
        $scope.page = page;
      }, function(message) {
        $rootScope.title = I18n.t("page.not_found");
        Alerts.add('danger', message);
      });
  }])

  ;
