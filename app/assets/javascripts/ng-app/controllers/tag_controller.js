var RETRY_INTERVAL = 30000;

angular.module('blnkk.controllers')

  .controller('TagIndexController', ['$scope', '$rootScope', '$uibModal', 'Tag', 'Analytics', function($scope, $rootScope, $uibModal, Tag, Analytics){
    setTitle($rootScope, I18n.t("tag.index_title"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);

    $scope.isLoadingTags = false;

    $scope.tags_to_follow = [];
    $scope.tags_already_following = [];

    this.getTags = function() {
      $scope.isLoadingTags = true;
      Tag.getAll("what-to-follow").then( function(tags){
        $scope.isLoadingTags = false;
        $scope.tags_to_follow = tags;
        populateTags(tags, $scope.session.user.tag_list);
      }, function(message) {
        $scope.isLoadingTags = false;
        Alerts.add('danger',message);
      });
      Tag.getAll("what-already-following").then( function(tags){
        $scope.tags_already_following = tags;
        populateTags(tags, $scope.session.user.tag_list);
      }, function(message) {
        Alerts.add('danger',message);
      });
    }
    this.getTags();

    $scope.newTag = function(){
      $uibModal.open({
        templateUrl: 'modals/new-tag.html',
        controller: 'TagNewController'
      });
    }

  }])

  .controller('TagShowController', ['$scope', '$rootScope', '$stateParams', '$timeout', '$filter', '$cookies', 'Analytics', 'Tag', 'Request', 'User', 'Rating', 'Alerts', function($scope, $rootScope, $stateParams, $timeout, $filter, $cookies, Analytics, Tag, Request, User, Rating, Alerts){
    var self = this;
    var currentPage = 1;
    var initialized = false;
    var isInitiallyConnected = $scope.session.connected;
    $scope.order = "recommended";

    $scope.requests = [];
    $scope.isLoadingRequests = false;
    $scope.isEndOfRequests = false;
    console.log($scope);

    this.initializePage = function(){
      console.log("Initializing tag page");

      Tag.getByName($stateParams.tag)
        .then( function(tag) {
          $scope.tag = tag;
          console.log($stateParams.tag);
          setTitle($rootScope, tag.name, $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
          populateTags([tag], $scope.session.user.tag_list);
          $scope.setNewRequestVisibility($scope.session.connected && $scope.session.user.tag_list.indexOf($scope.tag.name) >= 0, $scope.tag.name);
        }, function(message) {
          Alerts.add('danger', message);
        });
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

    $scope.getNextRequests = function() {
      if (initialized && !$scope.isLoadingRequests && !$scope.isEndOfRequests) {
        self.getRequests();
      }
    };


    this.reloadRequests = function(){
      if (!initialized || $scope.isLoadingRequests) {
        return;
      }
      console.info('Tag: Reloading blinks');
      currentPage = 1;
      $scope.isEndOfRequests = false;

      $scope.requests = [];
      self.getRequests();
    }

    this.getRequests = function() {
      $scope.isLoadingRequests = true;
      console.info("Tag: Getting blinks page "+currentPage);
      Request.getAllPublic($stateParams.tag, currentPage, $scope.order)
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

  .controller('TagNewController', ['$scope', '$rootScope', '$state', '$timeout', '$modalInstance', 'Tag', 'User', 'Alerts', function($scope, $rootScope, $state, $timeout, $modalInstance, Tag, User, Alerts){
    $scope.newTag = '';
    $scope.newIcon = 'hash';
    $scope.isCreating = false;

    $scope.cancel = function () {
      $scope.newTag = '';
      $modalInstance.close();
    };

    $scope.createTag = function() {
      $scope.isCreating = true;
      Tag.create($scope.newTag,$scope.newIcon).then(
        function(tag) {
          $scope.newTag = '';
          $scope.isCreating = false;
          $state.go('home.tagSingle', {tag: tag.name});
          User.getData().then(function(new_user){
            $scope.session.user.tags = new_user.tags;
            $scope.session.user.tag_list = new_user.tag_list;
          });
        }, function(error) {
          $scope.isCreating = false;
          Alerts.add('danger', error);
        });
    };

    $timeout(function () {
      $('input#tag-name')[0].focus();
      $('input#tag-name')[0].select();
    },100);

  }])

  .controller('TagEditController', ['$scope', '$rootScope', '$state', '$timeout', '$modalInstance', 'tag', 'Tag', 'User', 'Alerts', function($scope, $rootScope, $state, $timeout, $modalInstance, the_tag, Tag, User, Alerts){
    $scope.newTag = the_tag.display_name;
    $scope.newIcon = the_tag.icon;
    $scope.isUpdating = false;

    $scope.cancel = function () {
      $scope.newTag = '';
      $modalInstance.close();
    };

    $scope.updateTag = function() {
      $scope.isUpdating = true;
      Tag.update(the_tag.id, {name: $scope.newTag, icon: $scope.newIcon}).then(
        function(tag) {
          $scope.newTag = '';
          $scope.isUpdating = false;
          $state.go('home.tagSingle', {tag: tag.name}, {reload: true});
          User.getData().then(function(new_user){
            $scope.session.user.tags = new_user.tags;
            $scope.session.user.tag_list = new_user.tag_list;
          });
        }, function(error) {
          $scope.isUpdating = false;
          Alerts.add('danger', error);
        });
    };

    $timeout(function () {
      $('input#tag-name')[0].focus();
      $('input#tag-name')[0].select();
    },100);

  }]);
