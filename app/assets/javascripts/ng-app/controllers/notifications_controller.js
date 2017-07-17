var RETRY_INTERVAL = 30000;

angular.module('blnkk.controllers')

  .controller('NotificationsController', ['$scope', '$rootScope', '$timeout', '$state', 'Analytics', 'Alerts', 'Notification', function($scope, $rootScope, $timeout, $state, Analytics, Alerts, Notification) {

    var self = this;
    var currentPage = 1;

    $scope.notifications = [];
    $scope.isLoadingNotifications = false;
    $scope.isEndOfNotifications = false;

    setTitle($rootScope, I18n.t("notifications.title"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);

    $scope.getNextNotifications = function(){
      if (!$scope.isLoadingNotifications && !$scope.isEndOfNotifications) {
        self.getNotifications();
      } 
    }

    this.getNotifications = function() {
      $scope.isLoadingNotifications = true;
      if (currentPage == 1){
        $scope.session.user.unread_notifications_count = 0;
      }
      Notification.getMine(currentPage)
        .then( function(notifications) {
          $scope.notifications = $scope.notifications.concat(notifications);
          currentPage++;
          if (notifications.length == 0) {
            $scope.isEndOfNotifications = true;
          }
          $timeout( function() { $scope.isLoadingNotifications = false; });
        }, function(message) {
          Alerts.add('danger', message);
          $timeout( function() { $scope.isLoadingNotifications = false; }, RETRY_INTERVAL);
      });
    };

    $scope.gotoNotable = function(notification){
      if (!notification.done){
        Notification.markDone(notification.id);
      }
      if (notification.goto_type == "Request"){
        $state.go('requestSingle',{id: notification.goto_id});
      }
      if (notification.goto_type == "User"){
        $state.go('home.userSingle',{id: notification.goto_id});
      }
    }

  }]);
