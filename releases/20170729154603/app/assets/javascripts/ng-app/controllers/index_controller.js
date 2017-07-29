var RETRY_INTERVAL = 30000;

angular.module('blnkk.controllers')

  .controller('IndexController', ['$scope', '$rootScope', '$state', '$stateParams', '$timeout', '$filter', '$uibModal', '$cookies', 'Analytics', 'Alerts', 'Request', 'Tag', 'Rating', function($scope, $rootScope, $state, $stateParams, $timeout, $filter, $uibModal, $cookies, Analytics, Alerts, Request, Tag, Rating) {
    var self = this;
    var currentPage = 1;
    var initialized = false;
    $scope.requests = [];
    $scope.isLoadingRequests = false;
    $scope.isEndOfRequests = false;

    setTitle($rootScope, "", $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);

    $scope.order = "recommended";

    this.initializePage = function(){
      console.log("Initializing newsfeed");
      $scope.setNewRequestVisibility(true, '');
      if ($scope.session.connected){
        $scope.order = "recommended";
        if (angular.isDefined($cookies['requests_sort_order'])){
          $scope.order = $cookies['requests_sort_order']
        }
      } else {
        $scope.order = "top";
      }
      initialized = true;
      this.reloadRequests();
    }

    $scope.setOrder = function(new_order) {
      if ($scope.session.connected){
        $scope.order = new_order;
        setCookie('requests_sort_order', new_order);
        self.reloadRequests();
      }
    };

    $scope.getNextRequests = function(){
      if (initialized && !$scope.isLoadingRequests && !$scope.isEndOfRequests) {
        self.getRequests();
      } 
    }

    this.reloadRequests = function(){
      if (!initialized || $scope.isLoadingRequests) {
        return;
      }
      console.info('Newsfeed: Reloading blinks');
      currentPage = 1;
      $scope.isEndOfRequests = false;

      $scope.requests = [];
      self.getRequests();
    }
    
    this.getRequests = function() {
      $scope.isLoadingRequests = true;
      console.info("Newsfeed: Getting blinks page "+currentPage);
      Request.getNewsfeed(currentPage, $scope.order)
        .then( function(requests) {
          $scope.requests = $scope.requests.concat(requests);
          currentPage++;
          if (requests.length == 0) {
            $scope.isEndOfRequests = true;
          }
          populateRequests(requests, Rating, Alerts, $scope.session.connected, $filter);
          $timeout( function() { $scope.isLoadingRequests = false; });
        }, function(message) {
          Alerts.add('danger', message);
          $timeout( function() { $scope.isLoadingRequests = false; }, RETRY_INTERVAL);
      });
    };

    $scope.$watch('isRetrievingProfile', function(newValue, oldValue) {
      if (oldValue != newValue && !newValue){
        console.log("Retrieving profile done!");
        self.initializePage();
      }
    });

    $scope.$watch('session.connected', function(newValue, oldValue) {
      if (oldValue != newValue && !newValue){
        console.log("Session disconnected!");
        self.initializePage();
      }
    });

    if (!$scope.isRetrievingProfile){
      console.log("Profile already retrieved");
      this.initializePage();
    }

    $scope.$on("$destroy", function() {
      $scope.setNewRequestVisibility(false, '');
    });

  }])