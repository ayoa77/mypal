var html5ModeEnabled;

angular
    .module('blnkk', [
        'ngAnimate',
        'ngCookies',
        'ui.router',
        'ui.bootstrap',
        'persona',
        'ngTagsInput',
        'angularMoment',
        'ngSanitize',
        'btford.markdown',
        'rzModule',
        'xeditable',
        'infinite-scroll',
        'angular-google-analytics',
        'cgNotify',
        'angularFileUpload',
        'ngImgCrop',
        'templates',
        'blnkk.services',
        'blnkk.controllers',
        'blnkk.directives',
        'blnkk.filters'
    ])
    .run(
      [          '$rootScope', '$state', '$stateParams', '$window', '$uibModalStack', '$location', 'editableOptions', 'Analytics', 'amMoment', 
        function ($rootScope,   $state,   $stateParams, $window, $uibModalStack, $location, editableOptions, Analytics, amMoment) {
            $rootScope.$state = $state;
            $rootScope.$stateParams = $stateParams;
            $rootScope.$on('$stateChangeStart', function(event, toState, toStateParams) {
              $window.scrollTo(0,0);
              if (html5ModeEnabled) {
                toStateParams.ln = I18n.locale;
                $location.search('ln', I18n.locale);
              }
              amMoment.changeLocale(I18n.locale);
            });
            $rootScope.$on('$stateChangeSuccess', function(event, toState, toStateParams) {
                $rootScope.currentURLWithParams = $state.href($state.current.name, toStateParams, {absolute: true});
                $rootScope.currentURL = $rootScope.currentURLWithParams.split('?')[0];
                $uibModalStack.dismissAll();
            });
            editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
        }
      ]
    )
    .config( 
        [        '$stateProvider', '$urlRouterProvider', '$locationProvider', '$compileProvider', 'AnalyticsProvider',
        function ($stateProvider,   $urlRouterProvider,   $locationProvider, $compileProvider, AnalyticsProvider) {

          console.log();

          var domain = settings["CHINA"] == 1 ? "xiaoquan.co" : "doers.io";

          AnalyticsProvider.setAccount('UA-61416425-1');
          AnalyticsProvider.setDomainName(domain);
          AnalyticsProvider.setPageEvent('$stateChangeSuccess');
          AnalyticsProvider.trackPages(false);
          AnalyticsProvider.trackUrlParams(true);
          AnalyticsProvider.ignoreFirstPageLoad(true);
          AnalyticsProvider.useAnalytics(true);
          AnalyticsProvider.setCookieConfig({
            cookieDomain: domain,
            cookieName: 'blnkkga',
            cookieExpires: 20000
          });

          $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|whatsapp|mailto|chrome-extension):/);

          $urlRouterProvider.otherwise("/");

          $stateProvider
            .state('home',{
              abstract: true,
              url: "/home?ln",
              templateUrl: "home.html"
            })
              .state('home.index',{
                url: "^/?ln&auth_result",
                templateUrl: "index.html"
              })
              .state('home.discover',{
                url: "^/discover?ln",
                templateUrl: "discover.html"
              })
              .state('home.users',{
                url: "^/users?ln&q",
                templateUrl: "users/index.html"
              })
              .state('home.conversation', {
                url: "^/conversation/:id?ln",
                templateUrl: "users/conversation.html"
                // reloadOnSearch: false
              })
              .state('home.notifications', {
                url: "^/u/notifications?ln",
                templateUrl: "users/notifications.html"
              })
              .state('home.users-edit',{
                url: "^/u/edit?ln",
                templateUrl: "users/edit.html"
              })
              .state('home.users-invite',{
                url: "^/u/invite?gresult&ln",
                templateUrl: "users/invite.html",
                controller: "UserInviteController"
              })
            .state('requestSingle', {
              url: "/b/:id?ref&ln",
              templateUrl: "requests/show.html",
              controller: "RequestShowController"
            })
            // .state('page',{
            //   url: "/p/:id?ln",
            //   templateUrl: "page.html",
            //   controller: "PageController"
            // })
            .state('payments-authorized', {
              url: "/payments/authorized?paymentId&token&PayerID&ln",
              templateUrl: "payments/authorized.html"
            })
            .state('payments-cancelled', {
              url: "/payments/cancelled?token",
              templateUrl: "payments/cancelled.html"
            })
            .state('oauth-callback', {
              url: "/oauth2callback?ln",
              templateUrl: "callbacks/oauth2.html"
            })
            .state('unsubscribe',{
              url: "/unsubscribe/:token?ln",
              templateUrl: "unsubscribe.html",
              controller: "UnsubscribeController"
            })
            .state('home.tags',{
              url: "^/categories?ln",
              templateUrl: "tags/index.html",
              controller: "TagIndexController"
            })
            .state('home.tagSingle',{
              url: "^/category/:tag?ln",
              templateUrl: "tags/show.html",
              controller: "TagShowController"
            })
            .state('home.userSingle', {
              url: "^/u/:id?ln",
              templateUrl: "users/show.html",
              controller: "UserShowController"
            })
            .state('terms',{
              url: "/terms",
              templateUrl: "terms.html"
            })
          // enable HTML5 Mode for SEO
          // $locationProvider.html5Mode(true);

          if (window.history && window.history.pushState) {
            $locationProvider.html5Mode(true);
            html5ModeEnabled = true;
          } else {

            html5ModeEnabled = false;
          }
    }]);