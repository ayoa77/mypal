'use strict';

/* Services */

var authService = null;

var parseErrorMessages = function(errors) {
	var messages = [];
	for (var fieldName in errors) {
		var currentArray = errors[fieldName];
		for (var i=0; i<currentArray.length; i++) {
			messages.push(fieldName.charAt(0).toUpperCase() + fieldName.slice(1) + " " + currentArray[i] );
		}
	}
	return messages;
};
var postErrorFunction = function(dataReturned, status, deferred) {
	switch (status) {
		case 0:
			deferred.reject(I18n.t("services.unavailable"));
			break;
		case 422:
			if (dataReturned && dataReturned.errors && parseErrorMessages(dataReturned.errors).length > 0){
				deferred.reject(parseErrorMessages(dataReturned.errors)[0]);
			} else {
				deferred.reject(I18n.t("services.unknown"));
			}
			break;
		case 401:
			authService.signedOutByServer();
			deferred.reject(I18n.t("services.need_sign_in"));
			break;
		case 404:
			deferred.reject(I18n.t("services.not_found"));
			break;
		default:
			deferred.reject(I18n.t("services.unknown"));
			break;
	}
}

var getErrorFunction = function(message, status, deferred){
	switch (status) {
		case 0:
			deferred.reject(message + ' ' + I18n.t("services.unavailable"));
			break;
		case 401:
			authService.signedOutByServer();
			deferred.reject(message + ' ' + I18n.t("services.sign_in"));
			break;
		case 404:
			deferred.reject(message + ' ' + I18n.t("services.info_not_found"));
			break;
		default:
			deferred.reject(message + ' ' + I18n.t("services.unknown"));
			break;
	}
}

angular.module('blnkk.services', [ 'persona' ])
	.service('Alerts', ['$http', '$location', '$window', '$rootScope', '$interval', function($http, $location, $window, $rootScope, $interval){
		var theService = this;
		var ALERT_LIFETIME = 7000;
		var ALERT_CHECK_INTERVAL = 10000;
		theService.alerts = [];
		$interval( function() {
			var now = new Date().getTime();
			for (var i= theService.alerts.length-1; i>=0; i--) {
				if (theService.alerts[i].expiry < now) {
					theService.removeAt(i);
				}
			}
		}, ALERT_CHECK_INTERVAL);
		theService.get = function() {
			return theService.alerts;
		};
		theService.add = function(type, msg) {
			var newAlert = {type: type, msg: msg, expiry: new Date().getTime()+ALERT_LIFETIME};
			if (!theService.alertIsPresent(newAlert)) {
				theService.alerts.push(newAlert);
			}
		};
		theService.removeAt = function(index) {
			theService.alerts.splice(index, 1);
		};
		theService.clear = function() {
			theService.alerts = [];
		};
		theService.alertIsPresent = function(alert) {
			var found = false;
			angular.forEach(theService.alerts, function(value, key) {
				if (value.type == this.type && value.msg == this.msg) {
					found = true;
				}
			}, alert);
			return found;
		};
	}])

	.service('Authentication', ['$rootScope', '$http', '$q', '$location', 'Persona', function($rootScope, $http, $q, $location, Persona){
		var signinDeferred = $q.defer();
		var theService = this;
		var isSignin;
		authService = this;

		this.watchWith = function(email) {
			theService.state.signedIn = angular.isDefined(email);
			Persona.watch({
				loggedInUser: email,
				onlogin: function(assertion) {
					// $rootScope.isSigningIn = true;
					$rootScope.$broadcast('connecting');
					var endPoint = isSignin ? '/api/v1/auth/persona/login' : '/api/v1/auth/persona/signup';
					$http.post( endPoint, {assertion: assertion})
						.success(function(dataReturned, status) {
							theService.state.signedIn = true;
							dispatchConnexionChange(true);
        			signinDeferred.resolve();
        			// $rootScope.isSigningIn = false;
						})
						.error(function(dataReturned, status) {
							Persona.logout();
							theService.state.signedIn = false;
							dispatchConnexionChange(false);
							if (status == 404) {
								signinDeferred.reject(I18n.t("services.auth_user_not_found"));
							}else if (status == 409) {
								signinDeferred.reject(I18n.t("services.auth_user_already_exists"));
							}else if (status == 403) {
								signinDeferred.reject(I18n.t("services.auth_user_forbidden"));
							} else {
								signinDeferred.reject(I18n.t("services.auth_error"));
							}
							// $rootScope.isSigningIn = false;
						});
				},
				onlogout: function() {
					// theService.state.signedIn = false;
					// dispatchConnexionChange(false);
					// $http.post(
					// 	'/api/v1/auth/persona/logout'
					// 	).then(function () {
					// })
				}
			});
		}

		var dispatchConnexionChange = function( state ) {
			$rootScope.$broadcast('connexion-change', { signedIn: state });
		};

		this.state = { signedIn: false};
		var requestPersona = function() {
			var logoPath = '';
			if ($location.protocol() == 'https') {
				logoPath = settings["FAVICON"];
			}
			Persona.request({siteName: settings["SUBSITE"]+" "+settings["SITE_NAME"], siteLogo: logoPath});
		};
		this.signIn = function(type) {
			isSignin = type == 'signin';
			signinDeferred = $q.defer();
			requestPersona();
			return signinDeferred.promise;
		};
		this.signOut = function() {
			Persona.logout();
			var deferred = $q.defer();
			$http.post('/api/v1/auth/persona/logout')
				.success(function(dataReturned, status) {
					theService.state.signedIn = false;
					dispatchConnexionChange(false);
    			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					deferred.reject(I18n.t("services.error_signed_out"));
				});
			return deferred.promise;
		};
		this.signedOutByServer = function() {
			Persona.logout();
			theService.state.signedIn = false;
			dispatchConnexionChange(false);
		}
	}])

	.service('User', ['$http', '$q', '$rootScope', 'SocketMessages', function($http, $q, $rootScope, SocketMessages){
		var theService = this;
		this.getAll = function(page, searchQuery, order, serializer){
			var deferred = $q.defer();
			var url = '/api/v1/users?page='+page;
			if (searchQuery && angular.isDefined(searchQuery)){
				url = url + "&q=" +encodeURIComponent(searchQuery);
			}
			if (order && angular.isDefined(order)){
				url = url + "&order=" +encodeURIComponent(order);
			}
			if (serializer && angular.isDefined(serializer)){
				url = url + "&serializer=" +encodeURIComponent(serializer);
			}
			$http.get( url )
				.success(function(dataReturned, status) {
					theService.data.users = dataReturned.users;
    			deferred.resolve(theService.data.users);
				})
				.error(function(dataReturned, status) {
					theService.resetData();
					deferred.reject(I18n.t("services.error_get_users"));
				});
			return deferred.promise;
		}
		this.getById = function(id) {
			var deferred = $q.defer();
			$http.get( '/api/v1/users/' + id )
				.success(function(dataReturned, status) {
					theService.data.user = dataReturned.user;
	    			deferred.resolve(theService.data.user);
				})
				.error(function(dataReturned, status) {
					deferred.reject(I18n.t("services.error_get_user", {id: id}) );
				});
			return deferred.promise;
		};

		this.update = function(id, data){
			var deferred = $q.defer();
			$http.put( '/api/v1/users/' + id, {user: data})
				.success(function(dataReturned, status) {
					theService.data = dataReturned.user;
    			deferred.resolve(theService.data);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		}

		this.saveData = function(userData) {
			var deferred = $q.defer();
			$http.put( '/api/v1/users/' + userData.id, {user: {name: userData.name, avatar: userData.avatar, biography: userData.biography, website: userData.website, email_setting_attributes: userData.email_setting}})
				.success(function(dataReturned, status) {
					theService.data = dataReturned.user;
    			deferred.resolve(theService.data);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.rate = function(id,rating) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/'+ id +'/rate', {rating: rating})
				.success(function(dataReturned, status) {
	     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.promote = function(id) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/'+ id +'/promote')
				.success(function(dataReturned, status) {
	     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.demote = function(id) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/'+ id +'/demote')
				.success(function(dataReturned, status) {
	     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.enable = function(id) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/'+ id +'/enable')
				.success(function(dataReturned, status) {
	     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.disable = function(id) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/'+ id +'/disable')
				.success(function(dataReturned, status) {
	     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.addTag = function(tag) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/addTag', {tag: tag})
				.success(function(dataReturned, status) {
					theService.data = dataReturned.user;
    			deferred.resolve(theService.data);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.removeTag = function(tag) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/removeTag', {tag: tag})
				.success(function(dataReturned, status) {
					theService.data = dataReturned.user;
    			deferred.resolve(theService.data);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.getData = function() {
			var deferred = $q.defer();
			$http.get( '/api/v1/users/me')
				.success(function(dataReturned, status) {
					theService.data = dataReturned.user;
    			deferred.resolve(theService.data);
					// SocketMessages.connect(theService.data.id);
				})
				.error(function(dataReturned, status) {
					theService.resetData();
					deferred.reject(I18n.t("services.error_get_user_data"));
				});
			return deferred.promise;
		};
		this.inviteByEmail = function(emails) {
			var deferred = $q.defer();
			$http.post( '/api/v1/users/invite', {receivers: emails})
				.success(function(dataReturned, status) {
     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		}


		this.resetData = function() {
			theService.data = { id: null, name: '', biography: '', startup: '', contacts: [], email: ''};
		};
		this.resetData();
	}])

  .service('MyRequest', ['$http', '$q', function($http, $q){
		var theService = this;
		this.post = function(requestData) {
			var deferred = $q.defer();
			$http.post( '/api/v1/requests/', requestData)
				.success(function(dataReturned, status) {
    			deferred.resolve(dataReturned.request);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.destroy = function(id) {
			var deferred = $q.defer();
			$http.delete( '/api/v1/requests/' + id )
				.success(function(dataReturned, status) {
        	deferred.resolve(dataReturned.request);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
	}])


  .service('Comment', ['$http', '$q', function($http, $q){
		var theService = this;
			// this.getAllRequest = function(requestId) {
			// 	var deferred = $q.defer();
			// 	$http.get( '/api/v1/comments?request_id='+requestId )
			// 		.success(function(dataReturned, status) {
	  //   			deferred.resolve(dataReturned.comments);
			// 		})
			// 		.error(function(dataReturned, status) {
			// 			getErrorFunction('Failed to get comments.', status, deferred);
			// 		});
			// 	return deferred.promise;
			// };
		this.post = function(commentData) {
			var deferred = $q.defer();
			$http.post( '/api/v1/comments',commentData)
				.success(function(dataReturned, status) {
    			deferred.resolve(dataReturned.comment);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.destroy = function(id) {
			var deferred = $q.defer();
			$http.delete( '/api/v1/comments/' + id )
				.success(function(dataReturned, status) {
        	deferred.resolve(dataReturned.comment);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.rate = function(id,rating) {
			var deferred = $q.defer();
			$http.post( '/api/v1/comments/'+ id +'/rate', {rating: rating})
				.success(function(dataReturned, status) {
	   			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
	}])


	.service('Contact', ['$http', '$q', function($http, $q){
		var theService = this;

		this.getGoogleContacts = function() {
			var deferred = $q.defer();
			$http.get( '/api/v1/contacts?type=gmail')
				.success(function(dataReturned, status) {
					theService.gmailContacts = dataReturned.contacts;
    			deferred.resolve(theService.gmailContacts);
				})
				.error(function(dataReturned, status) {
					theService.resetData();
					getErrorFunction(I18n.t("services.error_google_contacts"), status, deferred);
				});
		return deferred.promise;
	};

		this.getManualContacts = function() {
			var deferred = $q.defer();
			var url = '/api/v1/contacts?type=manual';
			$http.get( url )
				.success(function(dataReturned, status) {
					theService.manualContacts = dataReturned.contacts;
    			deferred.resolve(theService.manualContacts);
				})
				.error(function(dataReturned, status) {
					theService.manualContacts = [];
					getErrorFunction(I18n.t("services.error_contacts"), status, deferred);
				});
			return deferred.promise;
		}
		this.resetData = function() {
			theService.manualContacts = [];
			theService.gmailContacts = [];
		};
		this.resetData();
	}])

	.service('Rating', ['$http', '$q', function($http, $q){
		var theService = this;
		this.getRatings = function(type, ids) {
			var deferred = $q.defer();
			var url = '/api/v1/ratings?rateable_type=' + type + '&rateable_ids=' + ids;
			$http.get( url )
				.success(function(dataReturned, status) {
    			deferred.resolve(dataReturned.ratings);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_ratings"), status, deferred);
				});
			return deferred.promise;
		};
	}])

	.service('Request', ['$http', '$q', 'Contact', function($http, $q, Contact){
		var theService = this;
		this.getNewsfeed = function(page, order){
			return this.getAllPublic(null,page,order,false);
		}
		this.getDiscoverFeed = function(page, order){
			return this.getAllPublic(null,page,order,true);
		}
		this.getAllPublic = function(tag, page, order, discover) {
			var deferred = $q.defer();
			var url = '/api/v1/requests?page=' + page + '&order=' + order;
			if (tag && angular.isDefined(tag)){
				url = url + "&tag=" +encodeURIComponent(tag);
			}
			if (discover && angular.isDefined(discover)){
				url = url + "&discover=1";
			}
			$http.get( url )
				.success(function(dataReturned, status) {
    			deferred.resolve(dataReturned.requests);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_news_feed"), status, deferred);
				});
			return deferred.promise;
		};
		this.getAllUser = function(user_id, page, order, filter) {
			var deferred = $q.defer();
			var url = '/api/v1/requests?user_id=' + user_id + '&page=' + page + '&order=' + order + '&filter=' + filter;
			$http.get( url )
				.success(function(dataReturned, status) {
    			deferred.resolve(dataReturned.requests);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_user_blinks"), status, deferred);
				});
			return deferred.promise;
		};
		this.getById = function(id) {
			var deferred = $q.defer();
			$http.get( '/api/v1/requests/' + id )
				.success(function(dataReturned, status) {
	   			deferred.resolve(dataReturned.request);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_blink", {id: id}), status, deferred);
				});
			return deferred.promise;
		};
		this.rate = function(id,rating) {
			var deferred = $q.defer();
			$http.post( '/api/v1/requests/'+ id +'/rate', {rating: rating})
				.success(function(dataReturned, status) {
	   			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
	}])

	.service('Tag', ['$http', '$q', function($http, $q){
		var theService = this;

		this.getByName = function(name){
			var deferred = $q.defer();
			$http.get( '/api/v1/tags/' + name )
				.success(function(dataReturned, status) {
	    		deferred.resolve(dataReturned.tag);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_tag", {name: name}), status, deferred);
				});
			return deferred.promise;
		}

		this.getAll = function(searchQuery) {
			var deferred = $q.defer();
			var url = '/api/v1/tags';
			if (searchQuery && angular.isDefined(searchQuery)){
				url = url + "?q=" +encodeURIComponent(searchQuery);
			}
			$http.get(url)
				.success(function(dataReturned, status) {
					deferred.resolve(dataReturned.tags);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_tags"), status, deferred);
				});
			return deferred.promise;
		};
		this.create = function(tagName, tagIcon){
			var deferred = $q.defer();
			$http.post( '/api/v1/tags/', {name: tagName, icon: tagIcon})
				.success(function(dataReturned, status) {
	    		deferred.resolve(dataReturned.tag);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		}

		this.update = function(tagId, params){
			var deferred = $q.defer();
			$http.put( '/api/v1/tags/'+tagId, params)
				.success(function(dataReturned, status) {
	    		deferred.resolve(dataReturned.tag);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		}

		this.destroy = function(id) {
			var deferred = $q.defer();
			$http.delete( '/api/v1/tags/' + id )
				.success(function(dataReturned, status) {
        	deferred.resolve(dataReturned.tag);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
	}])

	.service('Conversation', ['$http', '$q', function($http, $q){
		var theService = this;
		this.getAll = function() {
			var deferred = $q.defer();
			$http.get( '/api/v1/conversations' )
				.success(function(dataReturned, status) {
					theService.data.conversations = dataReturned.conversations;
    			deferred.resolve(theService.data.conversations);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_conversations"), status, deferred);
					// if (status == 401) {
					// 	deferred.resolve([]);
					// } else {
					// 	deferred.reject('Failed to get conversations');
					// }
				});
			return deferred.promise;
		};
		this.getById = function(conversationId) {
			var deferred = $q.defer();
			$http.get( '/api/v1/conversations/' + conversationId )
				.success(function(dataReturned, status) {
					theService.data.selectedConversation = dataReturned.conversation;
	    		deferred.resolve(dataReturned.conversation);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_conversation", {conversationId: conversationId}), status, deferred);
					// if (status == 401) {
					// 	deferred.resolve([]);
					// } else {
					// 	deferred.reject('Failed to get conversation #' + conversationId);
					// }
				});
			return deferred.promise;
		};
		this.addMessage = function(conversationData) {
			var deferred = $q.defer();
			$http.post( '/api/v1/conversations/', conversationData)
				.success(function(dataReturned, status) {
	    			deferred.resolve();
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		}
		this.resetData = function() {
			theService.data = {conversations: [], selectedConversation: null};
		};
		this.rate = function(id,rating) {
			var deferred = $q.defer();
			$http.post( '/api/v1/conversations/'+ id +'/rate', {rating: rating})
				.success(function(dataReturned, status) {
	     			deferred.resolve(dataReturned);
				})
				.error(function(dataReturned, status) {
					postErrorFunction(dataReturned, status, deferred);
				});
			return deferred.promise;
		};
		this.resetData();
	}])

	.service('Page', ['$http', '$q', function($http, $q){
		var theService = this;
		this.getById = function(id) {
			var deferred = $q.defer();
			$http.get( '/api/v1/pages/' + id )
				.success(function(dataReturned, status) {
	    			deferred.resolve(dataReturned.page);
				})
				.error(function(dataReturned, status) {
					getErrorFunction(I18n.t("services.error_page", {id: id}), status, deferred);
				});
			return deferred.promise;
		};
		this.resetData = function() {
			theService.data = [];
		};
		this.resetData();
	}])

  .service('Notification', ['$http', '$q', function($http, $q){
    var theService = this;
    this.getMine = function(page){
      var deferred = $q.defer();
      var url = '/api/v1/notifications?page=' + page;
      $http.get( url )
        .success(function(dataReturned, status) {
          deferred.resolve(dataReturned.notifications);
        })
        .error(function(dataReturned, status) {
          getErrorFunction(I18n.t("services.error_notifications"), status, deferred);
        });
      return deferred.promise;
    };

    this.markDone = function(id){
      var url = '/api/v1/notifications/' + id + '/done';
      $http.post( url );
    };

  }])

	// .service('PaypalPayment', ['$http', '$q', function($http, $q){
	// 	var theService = this;
	// 	this.execute = function( token, payerId ) {
	// 		var deferred = $q.defer();
	// 		$http.post( '/api/v1/payments/authorize/', { token: token, payer_id: payerId})
	// 			.success(function(dataReturned, status) {
 //     				deferred.resolve(dataReturned.request_id);
	// 			})
	// 			.error(function(dataReturned, status) {
	// 				postErrorFunction(dataReturned, status, deferred);
	// 			});
	// 		return deferred.promise;
	// 	};
	// 	this.getRedirectURL = function( meetingId ) {
	// 		var deferred = $q.defer();
	// 		$http.get( '/api/v1/payments/redirect_url/?meeting_id=' + meetingId)
	// 			.success(function(dataReturned, status) {
 //     				deferred.resolve(dataReturned.redirect_url);
	// 			})
	// 			.error(function(dataReturned, status) {
	// 				deferred.reject('Payment authorize error.');
	// 			});
	// 		return deferred.promise;
	// 	};
	// 	this.getRequestIdByToken = function( token ) {
	// 		var deferred = $q.defer();
	// 		$http.get( '/api/v1/payments/request_id/?token=' + token)
	// 			.success(function(dataReturned, status) {
 //     				deferred.resolve(dataReturned.request_id);
	// 			})
	// 			.error(function(dataReturned, status) {
	// 				deferred.reject('Request can not be found.');
	// 			});
	// 		return deferred.promise;
	// 	};
	// }])

	.service('GoogleContacts', ['$http', '$q', '$location', 'User', function($http, $q, $location, User){
		var theService = this;
		var clientId;
		var redirect;
		if ($location.host() == 'localhost') {
			clientId = '374169068036-faqvcqq455p063h927rjiv418ehbff9u.apps.googleusercontent.com';
			redirect = encodeURIComponent("http://localhost:3000/oauth2callback");

		} else {
			clientId = '1091581472494-e7f88u0gfjpmdshk8ftdhbbmcd51uuc7.apps.googleusercontent.com';
			redirect = encodeURIComponent($location.protocol() + '://' + $location.host() + '/oauth2callback');
		}
		this.getAuthenticationURL = function() {
			return "https://accounts.google.com/o/oauth2/auth?response_type=code&scope=" + encodeURIComponent("https://www.googleapis.com/auth/contacts.readonly") + "&client_id=" + clientId + "&login_hint=" + User.data.email + "&redirect_uri=" + redirect;
		}

	}])

	.service('FacebookAuthentication', ['$http', '$q', '$location', 'User', function($http, $q, $location, User){
		var theService = this;
		var clientId;
		var redirect;
		if ($location.host() == 'localhost') {
			clientId = '221821404959944';
			// clientId = '108627286462499';
			// redirect = encodeURIComponent("http://globetutoring.com/oauth2authentication");
			redirect = encodeURIComponent("http://localhost:3000/oauth2authentication");
		} else {
			clientId = '108627286462499';
			console.log(clientId);
			redirect = encodeURIComponent("http://globetutoring.com/oauth2authentication");
			// redirect = encodeURIComponent($location.protocol() + '://' + $location.host() + '/oauth2authentication');
		}
		this.getAuthenticationURL = function(redirectTo, requestType) {
			if (requestType == null)
				requestType = 'signin';
			redirectTo = redirectTo.split('?')[0];
			return "https://www.facebook.com/dialog/oauth?client_id=" + clientId + "&response_type=code&scope=public_profile%2cemail&redirect_uri=" + redirect + "&state=" + encodeURIComponent("redirect=" + redirectTo + "&provider=facebook&type=" + requestType + "&ln=" + I18n.locale);
		}

	}])

	.service('GoogleAuthentication', ['$http', '$q', '$location', 'User', function($http, $q, $location, User){
		var theService = this;
		var clientId;
		var redirect;
		if ($location.host() == 'localhost') {
			clientId = '374169068036-faqvcqq455p063h927rjiv418ehbff9u.apps.googleusercontent.com';
			redirect = encodeURIComponent("http://localhost:3000/oauth2authentication");
		} else {
			clientId = '1091581472494-e7f88u0gfjpmdshk8ftdhbbmcd51uuc7.apps.googleusercontent.com';
			redirect = encodeURIComponent($location.protocol() + '://' + $location.host() + '/oauth2authentication');
		}
		this.getAuthenticationURL = function(redirectTo, requestType) {
			if (requestType == null)
				requestType = 'signin';
			redirectTo = redirectTo.split('?')[0];
			return "https://accounts.google.com/o/oauth2/auth?client_id=" + clientId + "&response_type=code&scope=openid%20email&redirect_uri=" + redirect + "&state=" + encodeURIComponent("redirect=" + redirectTo + "&provider=google&type=" + requestType + "&ln=" + I18n.locale);
		}

	}])

	.service('LinkedinAuthentication', ['$http', '$q', '$location', 'User', function($http, $q, $location, User){
		var theService = this;
		var clientId;
		var redirect;
		if ($location.host() == 'localhost') {
			clientId = '75ap9kmjwh1saq';
			redirect = encodeURIComponent("http://localhost:3000/oauth2authentication");
		} else {
			clientId = '75grdrw2yddh6s';
			redirect = encodeURIComponent($location.protocol() + '://' + $location.host() + '/oauth2authentication');
		}
		this.getAuthenticationURL = function(redirectTo, requestType) {
			if (requestType == null)
				requestType = 'signin';
			redirectTo = redirectTo.split('?')[0];
			return "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=" + clientId + "&redirect_uri=" + redirect + "&state=" + encodeURIComponent("redirect=" + redirectTo + "&provider=linkedin&type=" + requestType + "&ln=" + I18n.locale);
		}

	}]);
