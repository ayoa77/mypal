angular.module('blnkk.controllers')

  .controller('NewMessageController', ['$scope', '$rootScope', 'userId', 'requestId', '$filter', '$state', '$uibModalInstance', 'User', 'Rating', 'Alerts', 'SocketMessages', function($scope, $rootScope, userId, requestId, $filter, $state, $uibModalInstance, User, Rating, Alerts, SocketMessages){
    $scope.isLoadingUser = false;
    $scope.user = null;
    $scope.newMessage = '';
    $scope.isPosting = false;
    
    this.getUser = function(){
      $scope.isLoadingUser = true;
      User.getById(userId)
        .then( function(user) {
          $scope.user = user;
          $scope.isLoadingUser = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoadingUser = false;
        });
      }
      this.getUser();

      $scope.cancel = function () {
        $scope.newMessage = '';
        $uibModalInstance.close();
      };


      $scope.sendMessage = function() {
        $scope.isPosting = true;

        var conversationData = {};
        if (requestId && angular.isDefined(requestId)){
          conversationData = { message: {content: $filter('htmlToPlaintext')($scope.newMessage)}, request_id: requestId };
        } else {
          conversationData = { message: {content: $filter('htmlToPlaintext')($scope.newMessage)}, user_id: userId };
        }
        SocketMessages.postMessage(conversationData,
          function(conversationId) {
            $scope.newMessage = '';
            $scope.isPosting = false;
            $state.go('home.conversation', {id: conversationId});
          }, function() {
            $scope.isPosting = false;
            Alerts.add('danger', I18n.t("conversations.send_failed"));
          });
      };


  }])