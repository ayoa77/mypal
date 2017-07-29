var RETRY_INTERVAL = 30000;

angular.module('blnkk.controllers')

  .controller('RequestShowController', ['$scope', '$rootScope', '$state', '$stateParams', '$filter', '$timeout', '$interval', '$location', 'Analytics', 'Alerts', 'User', 'Request', 'Tag', 'Rating', function($scope, $rootScope, $state, $stateParams, $filter, $timeout, $interval, $location, Analytics, Alerts, User, Request, Tag, Rating){
    Request.getById($stateParams.id)
      .then( function(request) {
        setTitle($rootScope, request.content.truncate(95), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
        $scope.request = request;
        // Comment.getAllRequest($scope.request.id).then(function(comments){
        //   $scope.request.comments = comments;
        // },function(message){
        //   Alerts.add('danger', message);
        // });
        populateRequests([request], Rating, Alerts, $scope.session.connected, $filter);
      }, function(message) {
        Alerts.add('danger', message);
      });
  }])

  .controller('CopyRequestLinkController', ['$scope', '$rootScope', '$timeout', 'linkToCopy',  '$uibModalInstance', function($scope, $rootScope, $timeout, linkToCopy, $uibModalInstance){
    $scope.isLoadingUser = false;
    $scope.user = null;
    
    $scope.linkToCopy = linkToCopy;

    $scope.close = function () {
      $uibModalInstance.close();
    };

    $timeout(function () {
      $('textarea.request-link')[0].focus();
      $('textarea.request-link')[0].select();
      document.execCommand('copy');
    },100);

  }])

  .controller('RequestNewController', ['$scope', '$rootScope', '$state', '$timeout', '$uibModalInstance', '$filter', 'tag', 'Tag', 'MyRequest', 'Alerts', function($scope, $rootScope, $state, $timeout, $uibModalInstance, $filter, the_tag, Tag, MyRequest, Alerts){

    $scope.isPosting = false;
    $scope.newRequestData = { subject: '', content: '', reward: '', tag: (angular.isDefined(the_tag) ? the_tag : '') };

    $scope.cancel = function () {
      $scope.newTag = newRequestData = { subject: '', content: '', reward: '', tag: '' };
      $uibModalInstance.close();
    };

    $scope.postRequest = function() {
      $scope.isPosting = true;
      var cleanedRequestData = { subject: $filter('htmlToPlaintext')($scope.newRequestData.subject),
                                 content: $filter('htmlToPlaintext')($scope.newRequestData.content),
                                 reward: $filter('htmlToPlaintext')($scope.newRequestData.reward),
                                 tag: $scope.newRequestData.tag };
      MyRequest.post({request: cleanedRequestData})
        .then( function(request) {
          $scope.newRequestData = { subject: '', content: '', reward: '', tags: '' };
          $scope.isPosting = false;
          $scope.session.user.request_count ++;
          Alerts.add('success', I18n.t("new_request_directive.blink_posted"));
          $state.go('requestSingle', {id: request.id});
        }, function(message) {
          $scope.isPosting = false;
          Alerts.add('danger', message);
        })
    };

    $timeout(function () {
      $('input#request-subject').focus();
      $('input#request-subject').select();
    },100);

  }])


  ;