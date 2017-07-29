var RETRY_INTERVAL = 30000;

angular.module('blnkk.controllers')

  .controller('UserIndexController', ['$scope', '$rootScope', '$state', '$location', '$timeout', '$filter', 'Analytics', 'User', 'Request', 'Rating', 'Alerts', function($scope, $rootScope, $state, $location, $timeout, $filter, Analytics, User, Request, Rating, Alerts){  
    var self = this;
    var currentPage = 1;

    setTitle($rootScope, I18n.t("users.title"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);    

    $scope.searchQuery = $state.params.q;

    $scope.order = "relevance";
    $scope.users = []
    $scope.isLoadingUsers = false;
    $scope.isEndOfUsers = false;

    $scope.search = function(){
      $location.search('q', $scope.searchQuery);
      $scope.reloadUsers();
    }

    $scope.getNextUsers = function() {
      if (!$scope.isLoadingUsers && !$scope.isEndOfUsers) {
        self.getUsers();
      }
    };
    $scope.setOrder = function(new_order) {
      $scope.order = new_order;
      $scope.reloadUsers();
    };
    $scope.reloadUsers = function(){
      currentPage = 1;
      $scope.isEndOfUsers = false;
      $scope.users = [];
      self.getUsers();      
    }
    this.getUsers = function() {
      $scope.isLoadingUsers = true;
      User.getAll(currentPage,$scope.searchQuery,$scope.order,undefined)
        .then( function(users) {
          $scope.users = $scope.users.concat(users);
          currentPage++;
          if (users.length == 0) {
            $scope.isEndOfUsers = true;
          }
          populateUsers(users, Rating, Alerts, $scope.session.connected, $filter);
          $timeout( function() { $scope.isLoadingUsers = false; });
        }, function(message) {
          Alerts.add('danger', message);
          $timeout( function() { $scope.isLoadingUsers = false; }, RETRY_INTERVAL);
      });
    };    

  }])

  .controller('ProfileController', ['$rootScope', '$scope', '$state', 'Analytics', 'User', 'Alerts', function($rootScope, $scope, $state, Analytics, User, Alerts) {
    setTitle($rootScope, I18n.t("user.edit"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
    $scope.isSavingProfile = false;
    $scope.updated = { avatar: { cropped: null, input: null } };

    $scope.saveProfile = function() {
      $scope.isSavingProfile = true;
      if ($scope.updated.avatar.input && $scope.updated.avatar.cropped) {
        $scope.session.user.avatar = $scope.updated.avatar.cropped.substr($scope.updated.avatar.cropped.indexOf(','));
      }
      Alerts.clear();
      User.saveData($scope.session.user)
        .then(function(newUser) {
          $scope.isSavingProfile = false;
          $scope.session.user = newUser;
          $state.go('home.index');
          Alerts.add('success', "Profile saved");
        }, function(message) {
          $scope.isSavingProfile = false;
          Alerts.add('danger', message);
        });
    };

  }])

  .controller('ProfileSummaryController', ['$scope', '$rootScope', 'userId', '$filter', '$modalInstance', 'User', 'Rating', 'Alerts', function($scope, $rootScope, userId, $filter, $modalInstance, User, Rating, Alerts){
    $scope.isLoadingUser = false;
    $scope.user = null;
    
    this.getUser = function(){
      $scope.isLoadingUser = true;
      User.getById(userId)
        .then( function(user) {
   
          $scope.user = user;
          $scope.isLoadingUser = false;
          populateUsers([user], Rating, Alerts, $scope.session.connected, $filter);
   
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoadingUser = false;
        });
      }
      this.getUser();

      $scope.cancel = function () {
        $modalInstance.close();
      };


  }])
  

  .controller('UserShowController', ['$scope', '$rootScope', '$stateParams', '$timeout', '$filter', 'Analytics', 'User', 'Request', 'Rating', 'Alerts', function($scope, $rootScope, $stateParams, $timeout, $filter, Analytics, User, Request, Rating, Alerts){
    var self = this;

    var currentPage = 1;
    var isInitiallyConnected = $scope.session.connected;
    $scope.order = "recommended";
    $scope.filter = "mine";
    $scope.requests = [];
    $scope.isLoadingRequests = false;
    $scope.isEndOfRequests = false;

    User.getById($stateParams.id)
      .then( function(user) {
        setTitle($rootScope, user.name, $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics);
        $scope.user = user;
        populateUsers([user], Rating, Alerts, $scope.session.connected, $filter);
      }, function(message) {
        Alerts.add('danger', message);
      });

    $scope.getNextRequests = function() {
      if (!$scope.isLoadingRequests && !$scope.isEndOfRequests) {
        self.getRequests();
      }
    };
    $scope.setOrder = function(new_order) {
      $scope.order = new_order;
      $scope.reloadRequests();
    };
    $scope.setFilter = function(new_filter) {
      $scope.filter = new_filter;
      $scope.reloadRequests();
    };
    $scope.reloadRequests = function(){
      currentPage = 1;
      $scope.isEndOfRequests = false;
      $scope.requests = [];
      self.getRequests();      
    }
    this.getRequests = function() {
      $scope.isLoadingRequests = true;
      Request.getAllUser($stateParams.id,currentPage,$scope.order,$scope.filter)
        .then( function(requests) {
          $scope.requests = $scope.requests.concat(requests);
          currentPage++;
          if (requests.length == 0) {
            $scope.isEndOfRequests = true;
          } else if ($scope.session.connected) {
            isInitiallyConnected = true;
          }
          populateRequests(requests, Rating, Alerts, $scope.session.connected, $filter);
          $timeout( function() { $scope.isLoadingRequests = false; });
        }, function(message) {
          Alerts.add('danger', message);
          $timeout( function() { $scope.isLoadingRequests = false; }, RETRY_INTERVAL);
      });
    };
    $rootScope.$on('connexion-change', function(event, args) {
      if (args.signedIn && !isInitiallyConnected) {
        $scope.reloadRequests();
      }
    });

  }])

  .controller('UserInviteController', ['$scope', '$rootScope', '$stateParams', '$q', '$filter', '$window', '$state', '$location', '$timeout', 'Analytics', 'Alerts', 'User', 'GoogleContacts', 'Contact', 'Rating', function($scope, $rootScope, $stateParams, $q, $filter, $window, $state, $location, $timeout, Analytics, Alerts, User, GoogleContacts, Contact, Rating){
    $scope.gcontactsSelection = [];
    $scope.gcontactsFiltered = [];
    $scope.isPosting = false;
    $scope.emailList = [];
    $scope.isGettingGoogleContacts = false;
    $scope.gcontactAllSelected = false;
    $scope.searchCriteria = '';

    setTitle($rootScope, I18n.t("user.invite.title"), $scope.session.user.unread_notifications_count + $scope.session.user.unread_conversations_count, Analytics, $location.path());

    var getContacts = function() {
      Contact.getManualContacts()
        .then( function(manualContacts) {
          $scope.session.contacts.manual = manualContacts;
        }, function(message) {
          Alerts.add('danger', message);
        });
      Contact.getGoogleContacts()
        .then( function(gmailContacts) {
          $scope.session.contacts.gmail = gmailContacts;
          for (var i=0; i<gmailContacts.length; i++) {
            $scope.gcontactsSelection.push({ name: gmailContacts[i].name, email: gmailContacts[i].email, selected: false });
            $scope.updateFilter();
          }
        }, function(message) {
          Alerts.add('danger', message);
        });
    };
    if ($scope.session.connected) {
      getContacts();
    }
    $rootScope.$on('user-loaded', function(event, args) {
      getContacts();
    });
    $scope.updateFilter = function() {
      $scope.gcontactsFiltered = $filter('filter')($scope.gcontactsSelection, $scope.searchCriteria);
    }
    $scope.searchEmails = function(query) {
      return $q(function(resolve, reject) {
        resolve($filter('filter')($scope.session.contacts.manual, query));
      });
    };

    $scope.sendEmails = function() {
      $timeout( function() { $scope.actualSendEmails() }, 100);
    }

    $scope.actualSendEmails = function() {
      var selectedGoogleContacts = $filter('filter')($scope.gcontactsSelection, { selected: true }, true);
      $scope.isPosting = true;
      var emails = [];
      var i;
      for (i=0; i<$scope.emailList.length; i++) {
        emails.push({name: null, email: $scope.emailList[i].email, source: 'manual'});
      }
      for (i=0; i<selectedGoogleContacts.length; i++) {
        emails.push({name: selectedGoogleContacts[i].name, email: selectedGoogleContacts[i].email, source: 'gmail'});
      }
      User.inviteByEmail(emails)
      .then( function(result) {
        $scope.isPosting = false;
        $scope.emailList = [];
        angular.forEach($scope.gcontactsSelection, function(value, key) {
          value.selected = false;
        });
        $scope.session.user.invitation_count += emails.length;
        Alerts.add('success', I18n.t("user.invite.sent_success"));
        $state.go('home.index');
      }, function(message) {
        $scope.isPosting = false;
        Alerts.add('danger', message);
      });
    };

    $scope.onAllSelectedChange = function() {
      if ($scope.gcontactAllSelected){
        if (!confirm(I18n.t("user.invite.all_gmail_question"))){
          $scope.gcontactAllSelected = false;
          return;
        }
      }
      angular.forEach($scope.gcontactsSelection, function(value, key) {
        value.selected = $scope.gcontactAllSelected;
      });
    };

    $scope.getGoogleContacts = function() {
      $scope.isGettingGoogleContacts = true;
      $window.location.href = GoogleContacts.getAuthenticationURL();
    }
    switch ($stateParams.gresult) {
      case 'error':
        Alerts.add('danger', I18n.t("user.invite.contact_error"));
        break;
      case 'unknown':
        Alerts.add('danger', I18n.t("services.unknown"));
        break;
      case 'success':
        // User.getData(true)
        //   .then( function(userData) {
        //     console.log(userData.contacts);
        //   }, function(message) {
        //     console.log('user error');
        //   });
        break;
    }

  }])
  ;