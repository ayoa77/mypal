var transformTagsIntoArray = function(inputTags) {
  var tags = [];
  for (var i=0; i<inputTags.length; i++) {
    tags.push(inputTags[i].name);
  }
  return tags;
};
var transformTagsIntoString = function(inputTags) {
  return transformTagsIntoArray(inputTags).join();
};


var populateRequests = function(requests, ratingService, alertsService, connected, angularFilter) {
  if (requests.length == 0){
    return;
  }
  if (!connected){
    return;
  }
  var requestIds = [];
  var userIds = [];
  var commentIds = []
  angular.forEach(requests, function(value, key) {
    this.push(value.id);
  }, requestIds);
  angular.forEach(requests, function(value, key) {
    this.push(value.user.id);
  }, userIds);
  angular.forEach(requests, function(value, key) {
    angular.forEach(value.comments, function (value,key){
      this.push(value.id);
    }, this);
  }, commentIds);

  ratingService.getRatings('Request', requestIds)
    .then( function(ratings) {
      for (var i=0; i < requests.length; i++) {
        var ratingForRequest = angularFilter('filter')(ratings, { rateable_id: requests[i].id }, true)[0];
        if (angular.isDefined(ratingForRequest)) {
          requests[i].user_rating = ratingForRequest.rating;
        } else {
          requests[i].user_rating = null;
        }
      }
    }, function(message) {
      alertsService.add('danger', message);
    });

  ratingService.getRatings('User', userIds)
    .then( function(ratings) {
      for (var i=0; i < requests.length; i++) {
        var ratingForUser = angularFilter('filter')(ratings, { rateable_id: requests[i].user.id }, true)[0];
        if (angular.isDefined(ratingForUser)) {
          requests[i].user.user_rating = ratingForUser.rating;
        } else {
          requests[i].user.user_rating = null;
        }
      }
    }, function(message) {
      alertsService.add('danger', message);
    });
  
  ratingService.getRatings('Comment', commentIds)
    .then( function(ratings) {
      for (var i=0; i < requests.length; i++) {
        for (var j=0; j < requests[i].comments.length; j++) {
          var ratingForComment = angularFilter('filter')(ratings, { rateable_id: requests[i].comments[j].id }, true)[0];
          if (angular.isDefined(ratingForComment)) {
            requests[i].comments[j].user_rating = ratingForComment.rating;
          } else {
            requests[i].comments[j].user_rating = null;
          }
        }
      }
    }, function(message) {
      alertsService.add('danger', message);
    });


};

var populateUsers = function(users, ratingService, alertsService, connected, angularFilter) {
  if (!connected){
    return;
  }
  var userIds = [];
  angular.forEach(users, function(value, key) {
    this.push(value.id);
  }, userIds);
  ratingService.getRatings('User', userIds)
    .then( function(ratings) {
      for (var i=0; i < users.length; i++) {
        var ratingForUser = angularFilter('filter')(ratings, { rateable_id: users[i].id }, true)[0];
        if (angular.isDefined(ratingForUser)) {
          users[i].user_rating = ratingForUser.rating;
        } else {
          users[i].user_rating = null;
        }
      }
    }, function(message) {
      alertsService.add('danger', message);
    });
};

var populateTags = function(tags, memberships){
  for (var i = 0; i < tags.length; i++){
    if (angular.isDefined(memberships)){
      tags[i].member = memberships.indexOf(tags[i].name) >= 0;
    } else {
      tags[i].member = false;
    }
  }
}

var setCookie = function(cname, cvalue) {
  document.cookie = cname + "=" + cvalue + "; ";
}