'use strict';

/* Directives */

function newRequest(){
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/new-request.html',
		controller: [ '$scope', '$rootScope', '$uibModal', function($scope, $rootScope, $uibModal) {

	    $scope.start = function(){
	    	if (!$rootScope.session.connected){
	    		$rootScope.signIn();
	    	} else {
	    		$uibModal.open({
		        templateUrl: 'modals/new-request.html',
		        controller: 'RequestNewController',
		        resolve: {
		          tag: function () {
		            return $scope.newRequestTag;
		          }
		        }
		      });
	    	}
	      
	    };
		}]
	}
}

function linkFacebook(){
	return {
		restrict: 'EA',
		replace: true,
		transclude: true, 
		template: '<a ng-click="$event.preventDefault();loadFacebookProfile();" href="" ng-transclude></a>',
		controller: [ '$scope', '$rootScope', '$state', '$window', 'FacebookAuthentication', 'User', 'Alerts', function($scope, $rootScope, $state, $window, FacebookAuthentication, User, Alerts) {
			$scope.loadFacebookProfile = function() {
				var pathToRedirect = $state.href($state.current.name);

				if ( $state.current.name == 'home.users-edit' ) {
		      User.saveData($scope.session.user)
		        .then(function(newUser) {
		          $window.location.href = FacebookAuthentication.getAuthenticationURL(pathToRedirect, 'info');
		        }, function(message) {
		          Alerts.add('danger', message);
		        });
				} else {
				  $window.location.href = FacebookAuthentication.getAuthenticationURL(pathToRedirect, 'info');
				}
			};
		}]
	};
}

function linkLinkedin(){
	return {
		restrict: 'EA',
		replace: true,
		transclude: true, 
		template: '<a ng-click="$event.preventDefault();loadLinkedinProfile();" href="" ng-transclude></a>',
		controller: [ '$scope', '$rootScope', '$state', '$window', 'LinkedinAuthentication', 'User', 'Alerts', function($scope, $rootScope, $state, $window, LinkedinAuthentication, User, Alerts) {
			$scope.loadLinkedinProfile = function() {
				var pathToRedirect = $state.href($state.current.name);

				if ( $state.current.name == 'home.users-edit' ) {
		      User.saveData($scope.session.user)
		        .then(function(newUser) {
		          $window.location.href = LinkedinAuthentication.getAuthenticationURL(pathToRedirect, 'info');
		        }, function(message) {
		          Alerts.add('danger', message);
		        });
				} else {
				  $window.location.href = LinkedinAuthentication.getAuthenticationURL(pathToRedirect, 'info');
				}
			};
		}]
	};
}

function tagItem() {
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/tag-item.html',
		controller: [ '$scope', '$rootScope', '$uibModal', '$state', 'Tag', 'User', 'Alerts', function($scope, $rootScope, $uibModal, $state, Tag, User, Alerts) {
			
			$scope.isDestroying = false;

			$scope.editTag = function(){
				$uibModal.open({
	        templateUrl: 'modals/edit-tag.html',
	        controller: 'TagEditController',
		        resolve: {
		          tag: function () {
		            return $scope.tag;
		          }
		        }
	      });
			}
			$scope.stickifyRequest = function(requestId){
				Tag.update($scope.tag.id, {request_id: requestId}).then(
	        function(tag) {
	        	Alerts.add('success', I18n.t("tag_item_directive.sticky_post_changed"));
	          $state.go('home.tagSingle', {tag: $scope.tag.name}, {reload: true});
	        }, function(error) {
	          Alerts.add('danger', error);
	        });
	    }
			$scope.destroyTag = function(){
				if (confirm(I18n.t("tag_item_directive.delete_tag_question") )){
					$scope.isDestroying = true;
	      	Tag.destroy($scope.tag.id)
		        .then( function(comment) {
		          $scope.isDestroying = false;
		          Alerts.add('success', I18n.t("tag_item_directive.tag_deleted"));
	          	$state.go('tags', {}, {reload: true});
	          	User.getData().then(function(new_user){
		            $scope.session.user.tags = new_user.tags;
		            $scope.session.user.tag_list = new_user.tag_list;
		          });
		        }, function(message) {
		          $scope.isDestroying = false;
		          Alerts.add('danger', message);
		        })
				}
			}

		}]
	}
}

function followTag(){
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/follow-tag.html',
		controller: [ '$scope', '$rootScope', 'User', 'Alerts', function($scope, $rootScope, User, Alerts) {
			$scope.isBusy = false;
			$scope.toggleFollowing = function(tag){
				if (!$rootScope.session.connected){
	    		$rootScope.signIn();
	    		return;
	    	}
	    	populateTags([tag], $scope.session.user.tag_list);
    		if (tag.member && !confirm(I18n.t("follow_tag_directive.unfollow_question", { tag: tag.display_name }) )){
    			return;
    		}
	    	$scope.isBusy = true;
	    	if (tag.member){
		      User.removeTag(tag.name).then( function(new_user) {
		      	$scope.session.user.tags = new_user.tags;
		      	$scope.session.user.tag_list = new_user.tag_list;
	    			$scope.tag.user_count = $scope.tag.user_count - 1;
		      	
		        // var indexOfTag = $scope.session.user.tag_list.indexOf(tag.name);
		        // if (indexOfTag >= 0){
		        //   $scope.session.user.tag_list.splice(indexOfTag,1);
		        //   tag.user_count = tag.user_count - 1;
		        // }
		        populateTags([tag], $scope.session.user.tag_list);
		        $scope.isBusy = false;
		      }, function(message) {
		        Alerts.add('danger', message);
		        $scope.isBusy = false;
		      });
	    	} else {
		      User.addTag(tag.name).then( function(new_user) {
		      	$scope.session.user.tags = new_user.tags;
		      	$scope.session.user.tag_list = new_user.tag_list;
		      	$scope.tag.user_count = $scope.tag.user_count + 1;
		      	// $scope.session.user.tag_list.push(tag.name);
		       //  tag.user_count = tag.user_count + 1;
		        populateTags([tag], $scope.session.user.tag_list);
		        $scope.isBusy = false;
		      }, function(message) {
		        Alerts.add('danger', message);
		        $scope.isBusy = false;
		      });
	    	}
			}
		}]
	}
}

function widgetMainMenu(){
	return {
		restrict: 'EA',
		// scope: {
		// 	userConnected: '='
		// },
		replace: true,
		templateUrl: 'directives/widget-main-menu.html',
		controller: ['$rootScope', '$scope', '$window', '$uibModal', 'Tag', function($rootScope, $scope, $window, $uibModal, Tag) {
			if (!$scope.session.connected) {
				Tag.getAll()
					.then(function(tags) {
	          $scope.tags = tags;
	        }, function(message) {
	          Alerts.add('danger', message);
	        });
			}
			$scope.showLanguage = function(lng){
				return I18n.locale != lng && (settings["LOCALE_PRIMARY"] == lng || settings["LOCALE_SECONDARY"] == lng);
			}
			$scope.switchLanguage = function(lng) {
				$window.location.replace($window.location.pathname + '?ln=' + lng);
				console.log($window.location.pathname)
			};
			$scope.start = function(){
	      $uibModal.open({
	        templateUrl: 'modals/new-request.html',
	        controller: 'RequestNewController',
	        resolve: {
	          tag: function () {
	            return $scope.newRequestTag;
	          }
	        }
	      });
	    }
		}]

	}
}

function userCard(){
	return {
		restrict: 'EA',
		scope: {
			user: '='
		},
		replace: true,
		templateUrl: 'directives/user-card.html'
	}	
}

function userLink(){
  return {
    restrict: 'EA',
    scope: {
    	user: '='
    },
    transclude: true,
    replace: true,
    template: '<a class="user-link" ng-click="$event.preventDefault();showUser();" ui-sref="home.userSingle({id: user.id})" ng-transclude></a>',
		controller: ['$scope', '$rootScope', '$state', '$uibModal', function($scope, $rootScope, $state, $uibModal){
			$scope.showUser = function(){
				if (!$rootScope.session.connected){
	    		$rootScope.signIn();
	    		return;
	    	}
				if($(".modal").length > 0){
					$state.go('home.userSingle',{id: $scope.user.id});
				} else {
					$uibModal.open({
		        templateUrl: 'modals/profile-summary.html',
		        controller: 'ProfileSummaryController',
		        resolve: {
		          userId: function () {
		            return $scope.user.id;
		          }
		        }
		      });
				}

			}
		}]
  }
}

function requestItem() {
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/request-item.html',
		controller: ['$scope', '$element', '$timeout', function($scope, $element, $timeout){
			// $scope.isExpandable = $element.hasClass('expandable');
			// $scope.showingAllComments = $element.hasClass('expanded');
			$scope.commentsAreCollapsed = false;

			$scope.showAllComments = function(){
				$scope.showingAllComments = true;
			}

			// $scope.collapse = function(){
			// 	if (!$scope.isExpandable || !$element.hasClass('expanded')){
			// 		return;
			// 	}
			// 	console.log("collapse!!");
			// 	$element.removeClass('expanded');

			// 	$element.find('.show-expanded').slideUp(260);
			// 	$element.find('.hide-expanded').slideDown(260)
				

			// 	$scope.showingAllComments = false;
			// }

			// $scope.expand = function(){
			// 	if (!$scope.isExpandable || $element.hasClass('expanded')){
			// 		return;
			// 	}
			// 	console.log("expand!!");
			// 	$('.expandable').removeClass('expanded');
			// 	$('.show-expanded').slideUp(260);
			// 	$('.hide-expanded').slideDown(260);

			// 	$element.addClass('expanded');
			// 	$element.find('.hide-expanded').slideUp(260);
			// 	$element.find('.show-expanded').slideDown(260);
			// }

			// $scope.toggle = function(){
			// 	console.log("toggle!!");
			// 	if ($element.hasClass('expanded')){
			// 		$scope.collapse();
			// 	} else {
			// 		$scope.expand();
			// 	}
			// }

			$scope.expand = function() {
				$scope.commentsAreCollapsed = !$scope.commentsAreCollapsed;
			}

			$scope.stop = function($event){
				console.log("stop!!");
				$event.stopPropagation();
			}
		}]
		// ,
		// link: function (scope, element, timeout) {
		// 	var content = element.find('.auto-folded');
		// 	var init = function() {
  //       var contentHeight = content.outerHeight();
  //       if (contentHeight > 200) {
  //       	if (scope.isExpanded){
  //         	content.addClass('auto-folded--unfolded');
  //         } else {
  //         	content.addClass('auto-folded--folded');
  //         }
  //       }
  //       content.show();
  //     };

  //     var contentHeight = 0;
		// 	var checkforContent = setInterval(function() {
		// 		var newContentHeight = content.outerHeight();
		// 	  if(newContentHeight > contentHeight) {
		//       clearInterval(checkforContent);
		//       init();
		// 	  }
		// 	}, 100);
  //   }
	}
}

function requestItemActions(){
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/request-item-actions.html',
		controller: [ '$scope', '$rootScope', '$element', '$state', '$filter', '$timeout', '$uibModal', 'Request', 'MyRequest', 'Comment', 'Alerts', function($scope, $rootScope, $element, $state, $filter, $timeout, $uibModal, Request, MyRequest, Comment, Alerts) {
			$scope.isRating = false;
			$scope.isCommenting = false;
			$scope.isDestroying = false;
			$scope.isPosting = false;
			$scope.newComment = '';

	    $scope.rateRequest = function(new_rating){
	    	if (!$scope.session.connected){
	    		$scope.signIn();
	    		return;
	    	}
	    	var old_rating = angular.isDefined($scope.request.user_rating) ? $scope.request.user_rating : 0;
	    	if (old_rating != new_rating){
	    		if (new_rating == -2 && !confirm(I18n.t("request_item_directive.report_post_question"))){
	    			return;
	    		}
	    		$scope.isRating = true;
		      Request.rate($scope.request.id,new_rating).then( function(dataReturned) {
		      	// $scope.request = dataReturned.request;
		      	$scope.request.like_count = dataReturned.request.like_count;
		      	$scope.request.report_count = dataReturned.request.report_count;
		      	$scope.request.likers = dataReturned.request.likers;
		      	$scope.request.user_rating = new_rating;
						$scope.isRating = false;
						if (new_rating == -2){
		    			Alerts.add('success', I18n.t("request_item_directive.post_reported"));
		    		}
					}, function(message) {
						Alerts.add('danger', message);
						$scope.isRating = false;
					});
		    }
	    }
			$scope.destroyRequest = function(){
				if (confirm(I18n.t("request_item_directive.delete_post_question") )){
					$scope.isDestroying = true;
	      	MyRequest.destroy($scope.request.id)
		        .then( function(request) {
		          $scope.isDestroying = false;
		          if ($scope.request.user.id == $scope.session.user.id){
		          	$scope.session.user.request_count --;
		          }
		          Alerts.add('success', I18n.t("request_item_directive.post_deleted"));
		          if (angular.isDefined($scope.requests)){
		          	var indexOfRequest = $scope.requests.indexOf($scope.request);
		        		if (indexOfRequest >= 0){
		          		$scope.requests.splice(indexOfRequest,1);
		        		}
		          } else {
		          	$state.go('index');
		          }
		        }, function(message) {
		          $scope.isDestroying = false;
		          Alerts.add('danger', message);
		        })
				}
			}
	    $scope.copyLink = function(){
	    	$uibModal.open({
	        templateUrl: 'modals/copy-request-link.html',
	        controller: 'CopyRequestLinkController',
	        resolve: {
	          linkToCopy: function () {
	            return $state.href('requestSingle', {id: $scope.request.id}, {absolute: true});
	          }
	        }
	      });
	    }
	    $scope.converse = function(){
	    	if (!$scope.session.connected){
	    		$scope.signIn();
	    		return;
	    	}
    		$scope.isCommenting = true;
    		$timeout(function () {
          $element.find('textarea:first').focus();
      	});
	    }
	    $scope.stopConverse = function(){
	    	$scope.newComment = '';
	    	$scope.isCommenting = false;
	    }
	    $scope.sendPM =function(){
	    	if (!$scope.session.connected){
	    		$scope.signIn();
	    		return;
	    	}
	    	$uibModal.open({
	        templateUrl: 'modals/new-message.html',
	        controller: 'NewMessageController',
	        resolve: {
	          userId: function () {
	            return $scope.request.user.id;
	          },
	          requestId: function () {
	            return $scope.request.id;
	          }
	        }
	      });
	    }
	    $scope.replyToRequest = function(){
	       $scope.isPosting = true;
	       var commentData = { comment: {content: $filter('htmlToPlaintext')($scope.newComment)}, request_id: $scope.request.id };	    		
				 Comment.post(commentData)
	        .then( function(comment) {
	          $scope.newComment = '';
	          $scope.isPosting = false;
	          $scope.isCommenting = false;
	          Alerts.add('success', I18n.t("request_item_actions_directive.comment_posted") );
	          if (angular.isDefined($scope.request.comments)){
	          	$scope.request.comments.push(comment);
	          } else {
	          	$scope.request.comments = [comment];
	          }
	          $scope.request.comment_count ++;
	          $timeout(function () {
	            $element.find('.commentReply').keyup();
	          },100);
	        }, function(message) {
	          $scope.isPosting = false;
	          Alerts.add('danger', message);
	          $timeout(function () {
	            $element.find('.commentReply').keyup();
	          },100);
	        })
	    }

	    $element.find('.commentReply').keyup(function(event) {
	      var messageReply = $element.find('.commentReply')[0];
	      $(messageReply).height( 0 );
	      var newHeight = Math.min(100, Math.max(20, messageReply.scrollHeight-12));
	      $(messageReply).height( newHeight );
	    });

	    $element.find('.commentReply').keydown(function(event) {
	      if (event.keyCode == 13 && !event.ctrlKey && !event.shiftKey) { // Enter pressed without control
	        if ($scope.newComment.length > 0){
	          $scope.replyToRequest();
	        }
	        return false;
	      }
	      if ((event.keyCode == 13 || event.keyCode == 10) && (event.ctrlKey || event.shiftKey)) { // Ctrl+Enter or Shift+Enter pressed
	        var messageReply = $element.find('.commentReply')[0];
	        var val = messageReply.value;
	        if (typeof messageReply.selectionStart == "number" && typeof messageReply.selectionEnd == "number") {
	            var start = messageReply.selectionStart;
	            messageReply.value = val.slice(0, start) + "\n" + val.slice(messageReply.selectionEnd);
	            messageReply.selectionStart = messageReply.selectionEnd = start + 1;
	        } else if (document.selection && document.selection.createRange) {
	            messageReply.focus();
	            var range = document.selection.createRange();
	            range.text = "\r\n";
	            range.collapse(false);
	            range.select();
	        }
	        return false;
	      }
	    });
	    $element.find('.commentReplySubmit').click(function(event){
	      if ($scope.newComment.length > 0){
	        $scope.replyToRequest();
	      }
	      return false;
	    });
		}]
	}
}

function comment() {
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/comment.html',
		controller: [ '$scope', '$rootScope', 'Comment', 'Alerts', function($scope, $rootScope, Comment, Alerts) {
			$scope.isRating = false;
			$scope.isDestroying = false;
	    $scope.rateComment = function(new_rating){
	    	if (!$scope.session.connected){
	    		$scope.signIn();
	    		return;
	    	}
	    	var old_rating = angular.isDefined($scope.comment.user_rating) ? $scope.comment.user_rating : 0;
	    	if (old_rating != new_rating){
	    		if (new_rating == -2 && !confirm(I18n.t("comment_directive.report_comment_question"))){
	    			return;
	    		}
	    		$scope.isRating = true;
		      Comment.rate($scope.comment.id,new_rating).then( function(dataReturned) {
		      	$scope.comment.like_count = dataReturned.comment.like_count;
		      	$scope.comment.report_count = dataReturned.comment.report_count;
		      	// $scope.request.likers = dataReturned.request.likers;
		      	$scope.comment.user_rating = new_rating;
						$scope.isRating = false;
						if (new_rating == -2){
		    			Alerts.add('success', I18n.t("comment_directive.comment_reported"));
		    		}
					}, function(message) {
						Alerts.add('danger', message);
						$scope.isRating = false;
					});
		    }
	    }

			$scope.destroyComment = function(){
				if (confirm(I18n.t("comment_directive.delete_comment_question") )){
					$scope.isDestroying = true;
	      	Comment.destroy($scope.comment.id)
		        .then( function(comment) {
		          $scope.isDestroying = false;
		          Alerts.add('success', I18n.t("comment_directive.comment_deleted"));
		          if (angular.isDefined($scope.request.comments)){
		          	var indexOfComments = $scope.request.comments.indexOf($scope.comment);
		        		if (indexOfComments >= 0){
		          		$scope.request.comments.splice(indexOfComments,1);
		        		}
		          } else {
		          	$state.go('home.index');
		          }
		        }, function(message) {
		          $scope.isDestroying = false;
		          Alerts.add('danger', message);
		        })
				}
			}

		}],
		link: function (scope, element, timeout) {
			var content = element.find('.auto-folded');
			var init = function() {
        var contentHeight = content.outerHeight();
        if (contentHeight > 200) {
          if (scope.isExpanded){
          	content.addClass('auto-folded--unfolded');
          } else {
          	content.addClass('auto-folded--folded');
          }
        }
      };

      var contentHeight = 0;
			var checkforContent = setInterval(function() {
				var newContentHeight = content.outerHeight();
			  if(newContentHeight > contentHeight) {
		      clearInterval(checkforContent);
		      init();
			  }
			}, 100);
    }
	}
}

function conversationRating() {
	return {
		restrict: 'EA',
		scope: {
			conversation: '=',
			showHeader: '='
		},
		replace: true,
		templateUrl: 'directives/conversation-rating.html',
		controller: [ '$scope', '$rootScope', 'Conversation', 'Alerts', function($scope, $rootScope, Conversation, Alerts) {
			$scope.isRating = false;
	    $scope.rateConversation = function(new_rating){
	    	var old_rating = angular.isDefined($scope.conversation.user_rating) ? $scope.conversation.user_rating : 0;
	    	if (old_rating != new_rating){
	    		$scope.isRating = true;
		      Conversation.rate($scope.conversation.id, new_rating).then( function(result_rating) {
		      	$scope.conversation.user_rating = new_rating;
						// Alerts.add('success', 'Conversation rated');
						$scope.isRating = false;
					}, function(message) {
						Alerts.add('danger', message);
						$scope.isRating = false;
					});
		    }
	    }
		}]
	}
}

function userItem() {
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/user-item.html',
		controller: [ '$scope', '$rootScope',  '$uibModal', '$modalStack', 'User', 'Alerts', function($scope, $rootScope, $uibModal, $modalStack, User, Alerts) {
			$scope.displayUrl = function(url,l) {
				if (typeof(url) == "undefined" || url == null) return "";
		    return url.replace("http://www.","").replace("https://www.","").replace("http://","").replace("https://","");
			}
	    $scope.sendPM =function(){
	    	if (!$scope.session.connected){
	    		$scope.signIn();
	    		return;
	    	}
	    	$uibModal.open({
	        templateUrl: 'modals/new-message.html',
	        controller: 'NewMessageController',
	        resolve: {
	          userId: function () {
	            return $scope.user.id;
	          },
	          requestId: function () {
	            return null;
	          }
	        }
	      });
	    }

	    $scope.promote = function(){
	    	User.promote($scope.user.id).then(function(user){
	    		$scope.user.admin = true;
	    		Alerts.add('success', I18n.t("user_directives.promote_success"));
	    	}, function(message){
	    		Alerts.add('danger', message);
	    	});
	    }

			$scope.demote = function(){
	    	User.demote($scope.user.id).then(function(user){
	    		$scope.user.admin = false;
	    		Alerts.add('success', I18n.t("user_directives.demote_success"));
	    	}, function(message){
	    		Alerts.add('danger', message);
	    	});
	    }

	    $scope.enable = function(){
		    User.enable($scope.user.id).then(function(user){
	    		$scope.user.enabled = true;
	    		Alerts.add('success', I18n.t("user_directives.enable_success"));
	    	}, function(message){
	    		Alerts.add('danger', message);
	    	});    	
	    }

	    $scope.disable = function(){
		    User.disable($scope.user.id).then(function(user){
	    		$scope.user.enabled = false;
	    		Alerts.add('success', I18n.t("user_directives.disable_success"));
	    	}, function(message){
	    		Alerts.add('danger', message);
	    	});    	
	    }

		}]
	}
}

function followUser(){
	return {
		restrict: 'EA',
		replace: true,
		templateUrl: 'directives/follow-user.html',
		scope: {
			user: '=',
			session: '='
		},
		controller: [ '$scope', '$rootScope', 'User', 'Alerts', function($scope, $rootScope, User, Alerts) {
			$scope.isRating = false;
	    $scope.rateUser = function(new_rating){
	    	if (!$scope.session.connected){
	    		$rootScope.signIn();
	    		return;
	    	}
	    	var old_rating = angular.isDefined($scope.user.user_rating) ? $scope.user.user_rating : 0;
	    	if (old_rating != new_rating){
	    		if (new_rating != 1 && !confirm(I18n.t("follow_user_directive.unfollow_question", {name: $scope.user.name}))){
	    			return;
	    		}
	    		$scope.isRating = true;
		      User.rate($scope.user.id,new_rating).then( function(dataReturned) {
		      	// $scope.user = dataReturned.user;
		      	$scope.user.follower_count = dataReturned.user.follower_count;
		      	$scope.user.followers = dataReturned.user.followers;
		      	$scope.session.user.following_count = $scope.session.user.following_count + (new_rating - old_rating);
		      	$scope.user.user_rating = new_rating;
						$scope.isRating = false;
					}, function(message) {
						Alerts.add('danger', message);
						$scope.isRating = false;
					});
		    }
	    }
		}]
	}
}

function messages($timeout) {
	return {
		restrict: 'EA',
		scope: {
			messages: '='
		},
		replace: true,
		templateUrl: 'directives/messages.html',
		controller: [ '$scope', '$compile', function($scope, $compile) {
    	$scope.translateSystemMessage = function( systemMessage ) {
				var translatedMessage = '';
				if (systemMessage.system_generated) {
					var messageContent = JSON.parse(systemMessage.content);
					switch ( messageContent.type ) {
						case 'message_from_request':
							translatedMessage = '<a class=\"main\" href=\"/b/' + messageContent.requestId + '\">' + messageContent.requestContent + '</a>';
							break;
					}
				}
				return translatedMessage;
			};
  	}],
    link: function (scope, element) {
			scope.$watch('messages.length', function() {
				$timeout( function() {element.scrollTop(element[0].scrollHeight);}, 100);
			});
    }
	}
}

function socialShareButtons() {
	return {
		restrict: 'EA',
		replace: true,
		scope: {
			request: '='
		},
		templateUrl: 'directives/social-share-buttons.html',
    controller: [ '$scope', '$state', '$location', '$element', function($scope, $state, $location, $element) {
    	var self = this;

    	this.urlToShare = window.location.href;
    	this.textToShare = document.title;

			this.setSharingContent = function(){
  			// $scope.safeUrl = encodeURIComponent(this.urlToShare + this.urlHash);
  			$scope.safeUrl = encodeURIComponent(this.urlToShare);
  			$scope.safeTitle = encodeURIComponent(this.textToShare);
			}
			this.setSharingContent();

			$scope.$watch('request', function() {
				if ($scope.request && angular.isDefined($scope.request)){
    			// self.urlToShare = $state.href('requestSingle', {id: $scope.request.id}, {absolute: true});
    			self.urlToShare = $location.protocol() + '://' + $location.host() + '/b/' + $scope.request.id;
    			var siteName = settings["SUBSITE"] + " " + settings["SITE_NAME"];

    			self.textToShare = $scope.request.subject.truncate(110 - siteName.length) + " - " + siteName;
					self.setSharingContent();
				}
			});

    }]
	}
}

// function socialShareCount(){
// 	return {
// 		restrict: 'EA',
// 		replace: true,
// 		scope: {
// 			request: '=',
// 			user: '='
// 		},
// 		template: '<span ng-show="shareCount > 0 && fetchCount > 2">{{ shareCount }}</span>',
// 		controller: [ '$scope', '$state', '$http', function($scope, $state, $http) {
// 			$scope.shareCount = 0;

// 			$scope.fetchCount = 0;

// 			var self = this;

//     	this.url = window.location.href;

// 			$scope.$watch('request', function() {
// 				if ($scope.request && angular.isDefined($scope.request)){
//     			self.url = $state.href('requestSingle', {id: $scope.request.id}, {absolute: true});
// 					self.setSharingCount();
// 				}
// 			});

// 			$scope.$watch('user', function() {
// 				if ($scope.user && angular.isDefined($scope.user)){
//     			self.url = $state.href('home.userSingle', {id: $scope.user.id}, {absolute: true});
// 					self.setSharingCount();
// 				}
// 			});

// 			this.setSharingCount = function(){
// 				$scope.fetchCount = 0;
// 				if (document.location.hostname == "localhost"){
// 					return;
// 				}
// 		   	var safeUrl = encodeURIComponent(this.url);
// 		    $.getJSON( '//graph.facebook.com/?id=' + safeUrl, function( fbdata ) {
// 		    	if (fbdata.shares){
// 		    		$scope.shareCount += fbdata.shares;
// 		    	}
// 		    	$scope.fetchCount ++;
// 		    });
// 		    $.getJSON( '//cdn.api.twitter.com/1/urls/count.json?url=' + safeUrl + '&callback=?', function( twitdata ) {
// 		    	if (twitdata.count){
// 			    	$scope.shareCount +=	twitdata.count;
// 			    }
// 		    	$scope.fetchCount ++;
// 		    });
// 		    $.getJSON( '//www.linkedin.com/countserv/count/share?url=' + safeUrl + '&callback=?', function( linkdindata ) {
// 		    	if (linkdindata.count){
// 			    	$scope.shareCount += linkdindata.count;
// 			    }
// 		    	$scope.fetchCount ++;
// 		    });				
// 			}
//     }]
// 	}	
// }

// function autoFolded($window) {
//   return {
//     restrict: 'E',
//     transclude: true,
//     template: '<div class="auto-folded"><div ng-transclude></div><div class="auto-folded--more"><a class="btn btn-primary" href ng-click="toggleFoldedState()"></a></div></div>',
//     link: function(scope, element, attrs) {
//       var content = $(element).find('.auto-folded');
//       var toggleFoldedState = function() {
//         if (content.hasClass('auto-folded--folded')) {
//           content.removeClass('auto-folded--folded').addClass('auto-folded--unfolded');
//         } else if (content.hasClass('auto-folded--unfolded')) {
//           content.removeClass('auto-folded--unfolded').addClass('auto-folded--folded');
//         }
//       };
//       scope.toggleFoldedState = toggleFoldedState;
//       var didFoldOnce = false;
//       var init = function() {
//         var contentHeight = content.outerHeight();
//         if (contentHeight > 200 && !didFoldOnce) {
//         	didFoldOnce = true;
//           content.addClass('auto-folded--folded');
//         }
//         content.show();
//       };

//       var contentHeight = 0;
// 			var checkforContent = setInterval(function() {
// 				var newContentHeight = content.outerHeight();
// 			  if(newContentHeight > contentHeight) {
// 		      clearInterval(checkforContent);
// 		      init();
// 			  }
// 			}, 100);
//     }
//   };
// }

function widgetUsersToFollow(){
	return {
		restrict: 'EA',
		replace: true,
		scope: {
			session: '=',
			showWidget: '='
		},
		templateUrl: 'directives/widget-users-to-follow.html',
		controller: ['$rootScope', '$scope', 'User', 'Tag', 'Rating', 'Alerts', '$filter', function($rootScope, $scope, User, Tag, Rating, Alerts, $filter) {
			var self = this;

    	$scope.users = [];
    	$scope.tags = [];

    	this.getUsers = function(){
	    	var searchQuery = ""
	    	if ($scope.session.connected){
	    		searchQuery = "who-to-follow";
	    	}
	    	User.getAll(1, searchQuery, "last_seen", "user_card").then( function(users){
		      $scope.users = $scope.users.concat(users);
		      populateUsers(users,  Rating, Alerts, $scope.session.connected, $filter);
		    }, function(message) {
		    });
					User.getAll(2, searchQuery, "last_seen", "user_card").then( function(users){
		      $scope.users = $scope.users.concat(users);
		      populateUsers(users,  Rating, Alerts, $scope.session.connected, $filter);
		    }, function(message) {
		    });
	    }
	    this.getUsers();

    	this.getTags = function(){
	    	var searchQuery = ""
	    	if ($scope.session.connected){
	    		searchQuery = "what-to-follow";
	    	}

	    	Tag.getAll(searchQuery).then( function(tags){
		      $scope.tags = tags;
		      populateTags(tags, $scope.session.user.tag_list);
		    }, function(message) {
		      Alerts.add('danger',message);
		    });
	    }
	    this.getTags();

	    $scope.$watch('session.user', function(newValue, oldValue) {
	      if (oldValue != newValue){
	        self.getUsers();
	        self.getTags();
	      }
	    });
		}]
	}
}

function formattedMessage(){
	return {
		restrict: 'EA',
		replace: true,
		scope: {
			text: '='
		},
		template: '<div ng-bind-html="formatText(text)"></div>',
		controller: [ '$scope', '$compile', function($scope, $compile) {
    	$scope.formatText = function( text ) {
  			var urlRegex = /(((https?:\/\/)|(www\.))\S+\b)/g;

	      if (text) {
  				text = text.replace(urlRegex, function(url,b,c) {
						var goodUrl = (c == 'www.') ?  'http://' +url : url;
						var prettyUrl = url.replace(/^https?:\/\//,'').replace(/\/$/, "");
					  return '<a href="' + goodUrl + '" target="_blank">' + prettyUrl + '</a>';
					});
	        text = text.replace(/(?:\r\n|\r|\n)/g, '<br />');
	      }
	      return text;
    	}
    }]
	}
}

function attachment(){
	return {
		restrict: 'EA',
		replace: true,
		scope: {
			text: '='
		},
		template: '<div class="item attachment" ng-show="foundAttachments">'+
		            '<iframe class="video stop-event" ng-repeat="youtubeAttachment in youtubeAttachments" ng-src="{{youtubeAttachment}}" frameborder="0" allowfullscreen></iframe>'+
								'<a class="image stop-event" ng-repeat="imageAttachment in imageAttachments" ng-href="{{imageAttachment.origUrl}}" target="_blank" style="background-image: url(\'{{imageAttachment.loadUrl}}\')"; /></a>'+
							'</div>',
		controller: [ '$scope', '$compile', '$sce', function($scope, $compile, $sce) {

			$scope.foundAttachments = false;
			$scope.imageAttachments = [];
			$scope.youtubeAttachments = [];

    	$scope.$watch('text', function() {
  			var urlRegex = /(((https?:\/\/)|(www\.))\S+\b)/g;
  			var imageRegex = /\.(jpg|png|gif)/g;
  			var youtubeRegex = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    

	      if ($scope.text) {
  				$scope.text.replace(urlRegex, function(url) {
  					if (url.match(imageRegex)) {
     			    $scope.foundAttachments = true;
     			    $scope.imageAttachments.push({origUrl: url, loadUrl: "/img?url="+url});
     			    // $scope.imageAttachments.push({origUrl: url.truncate(20), loadUrl: url});
    				}
    				var youtubeMatch = url.match(youtubeRegex)
  					if (youtubeMatch && youtubeMatch[2].length == 11) {
     			    $scope.foundAttachments = true;
     			    $scope.youtubeAttachments.push($sce.trustAsResourceUrl("https://www.youtube.com/embed/"+youtubeMatch[2]));
    				}
					});
	      }
			});
    }]
	}
}

function avatarUpload() {
  return {
    restrict: 'EA',
    scope: {
      user: '=',
      imageEdit: '='
    },
    replace: true,
    templateUrl: 'directives/avatar-upload.html',
    controller: [ '$scope', '$rootScope', '$cookies', 'FileUploader', 'User', function($scope, $rootScope, $cookies, FileUploader, User) {
    	$scope.imageEdit = { input: null, cropped: null };
      $scope.uploader = new FileUploader({ queueLimit: 1, alias: 'avatar', method: 'PATCH', removeAfterUpload: true});
      
      $scope.uploader.onAfterAddingFile = function(itemFile) {
      	$scope.imageEdit.cropped = '';
		    var reader = new FileReader();
		    reader.onload = function(event) {
		      $scope.$apply(function(){
		        $scope.imageEdit.input = event.target.result;
		      });
		    };
		    reader.readAsDataURL(itemFile._file);
      };

      $scope.cancel = function() {
        $scope.uploader.clearQueue();
        $scope.imageEdit = { input: null, cropped: null };
      }
    }]
  }
}
  /**
  * The ng-thumb directive
  * @author: nerv
  * @version: 0.1.2, 2014-01-09
  */
function ngThumb($window) {
  var helper = {
    support: !!($window.FileReader && $window.CanvasRenderingContext2D),
    isFile: function(item) {
      return angular.isObject(item) && item instanceof $window.File;
    },
    isImage: function(file) {
      var type =  '|' + file.type.slice(file.type.lastIndexOf('/') + 1) + '|';
      return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
    }
  };

  return {
    restrict: 'A',
    template: '<canvas/>',
    link: function(scope, element, attributes) {
      if (!helper.support) return;

      var params = scope.$eval(attributes.ngThumb);

      if (!helper.isFile(params.file)) return;
      if (!helper.isImage(params.file)) return;

      var canvas = element.find('canvas');
      var reader = new FileReader();

      reader.onload = onLoadFile;
      reader.readAsDataURL(params.file);

      function onLoadFile(event) {
        var img = new Image();
        img.onload = onLoadImage;
        img.src = event.target.result;
      }

      function onLoadImage() {
        var width = params.width || this.width / this.height * params.height;
        var height = params.height || this.height / this.width * params.width;
        canvas.attr({ width: width, height: height });
        canvas[0].getContext('2d').drawImage(this, 0, 0, width, height);
      }
    }
  };
}

function stopEvent() {
  return {
      restrict: 'C',
      link: function (scope, element, attr) {
          element.bind('click', function (e) {
              e.stopPropagation();
          });
      }
  };
}

function readmore($timeout) {
	return {
    restrict: 'CA',
    link: function(scope, element, attributes) {
      $timeout(function(){
      	attributes.moreLink = "<a href='#'' class='read_more_button'><i class='fa fa-caret-down'></i></a>";
      	attributes.lessLink = "<a href='#'' class='read_less_button'><i class='fa fa-caret-up'></i></a>"
	      angular.element(element).readmore(attributes);
      });

      scope.toggle = function() {
      	angular.element(element).readmore('toggle');
      }
    }
	};
}



angular.module('blnkk.directives', [ 'templates' ])
	.directive('linkFacebook', linkFacebook)
	.directive('linkLinkedin', linkLinkedin)
	.directive('newRequest', newRequest)
	.directive('tagItem', tagItem)
	.directive('followTag', followTag)
	.directive('widgetMainMenu', widgetMainMenu)
	.directive('userCard', userCard)
	.directive('requestItem', requestItem)
	.directive('requestItemActions', requestItemActions)
	.directive('comment',comment)
	.directive('userItem', userItem)
	.directive('followUser', followUser)
	.directive('userLink', userLink)
	.directive('conversationRating', conversationRating)
	.directive('socialShareButtons', socialShareButtons)
	// .directive('socialShareCount', socialShareCount)
	.directive('messageBlock', ['$timeout', messages])
	// .directive('autoFolded', ['$window', autoFolded])
	.directive('widgetUsersToFollow', widgetUsersToFollow)
	.directive('formattedMessage', formattedMessage)
	.directive('attachment', attachment)
	.directive('avatarUpload', avatarUpload)
	.directive('stopEvent', stopEvent)
	.directive('ngThumb', ['$window', ngThumb])
	.directive('readmore', ['$timeout', readmore]);

