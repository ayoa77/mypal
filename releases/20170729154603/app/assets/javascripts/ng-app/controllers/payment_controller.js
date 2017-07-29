angular.module('blnkk.controllers')
  
  .controller('AuthorizedPaymentController', ['$scope', '$rootScope', '$stateParams', '$state', 'PaypalPayment', 'Alerts', function($scope, $rootScope, $stateParams, $state, PaypalPayment, Alerts){
    $rootScope.title = 'Redirecting...';
    $scope.token = $stateParams.token;
    $scope.payerId = $stateParams.PayerID;
    PaypalPayment.execute( $stateParams.token, $stateParams.PayerID)
      .then( function(requestId) {
        $state.go('requestSingle', {id: requestId});
      }, function(message) {
        Alerts.add('danger', message);
      })
  }])

  .controller('CancelledPaymentController', ['$scope', '$rootScope', '$stateParams', '$state', 'PaypalPayment', 'Alerts', function($scope, $rootScope, $stateParams, $state, PaypalPayment, Alerts){
    $rootScope.title = 'Oh noes!';
    $scope.token = $stateParams.token;
    $scope.requestId = '';
    PaypalPayment.getRequestIdByToken( $stateParams.token)
      .then( function(incomingRequestId) {
        $scope.requestId = incomingRequestId;
      }, function(message) {
        Alerts.add('danger', message);
      });
    $scope.goToRequest = function() {
      if ($scope.requestId != '') {
        $state.go('requestSingle', {id: $scope.requestId});
      }
    }
  }]);