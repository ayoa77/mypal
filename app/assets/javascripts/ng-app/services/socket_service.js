angular.module('blnkk.services')
	.service('SocketMessages', ['$timeout', '$location', '$rootScope', function($timeout, $location, $rootScope) {
		var host = $location.host();
		var prefix = host == 'localhost' ? host + ':3001' : host + ':3001';
		var dispatcher;
		var theService = this;
		var userId;
    var channel;
    var userIdsToWatch = [];
    var mustTryToReconnectOnDisconnect = true;

    this.disconnect = function() {
    	if (dispatcher != null) {
        console.info("WebSocket: disconnecting ...");
    		mustTryToReconnectOnDisconnect = false;
    		dispatcher.disconnect();
    	}
    };

    this.connect = function(newUserId, socketKey, userIdsStatusCallback, connectedUserCallback, disconnectedUserCallback, newMessageCallback, newConversationCallback, userTypingCallback, conversationReadCallback, notificationReadCallback) {
      console.info("WebSocket: connecting ...");
      userId = newUserId;
      mustTryToReconnectOnDisconnect = true;
			// dispatcher = new WebSocketRails( prefix + ':3001?user_id=' + userId + '&key=' + socketKey );
			dispatcher = new WebSocketRails( prefix + '/websocket?user_id=' + userId + '&key=' + socketKey );
      var channelName = settings["WEBSOCKET_PREFIX"] + '_user_' + userId;
      channel = dispatcher.subscribe(channelName);
  		channel.bind('message_new', newMessageCallback);
  		channel.bind('conversation_new', newConversationCallback);
  		channel.bind('users_status_updates', userIdsStatusCallback);
  		channel.bind('user_status_connected', connectedUserCallback);
  		channel.bind('user_status_disconnected', disconnectedUserCallback);
      channel.bind('user_is_typing', userTypingCallback);
      channel.bind('conversation_read_update', conversationReadCallback);
      channel.bind('notification_read_update', notificationReadCallback);
  		dispatcher.bind('connection_closed', function() {
        console.info("WebSocket: connection closed");
  	    $rootScope.$broadcast('socket-connexion', { connected: false, mustReconnect: mustTryToReconnectOnDisconnect });
  		});
  		dispatcher.on_open = function(data) {
        console.info("WebSocket: connection opened");
        $rootScope.$broadcast('socket-connexion', { connected: true });
        theService.notifyConversationRead(userId, null);
  			theService.dispatchGetUsersStatus();
			}
    };

    this.sendIsTypingMessage = function(conversationId, isTyping, successCallback, errorCallback) {
        dispatcher.trigger('is_typing', { conversation_id: conversationId, is_typing: isTyping},
        function(response) {
          successCallback();
        },
        function(error) {
          errorCallback();
        } );
    };

    this.notifyConversationRead = function(userId, conversationId) {
    	dispatcher.trigger('conversation_read', { user_id: userId, conversation_id: conversationId},
    		function(response) {
	    	},
	    	function(error) {

	    	} );
    };

    this.getUsersOnlineStatus = function(userIds) {
    	userIdsToWatch = userIds;
    	if (dispatcher.state == 'connected') {
    		theService.dispatchGetUsersStatus();
    		userIdsToWatch = [];
    	}
    };

    this.dispatchGetUsersStatus = function() {
      if (userIdsToWatch.length > 0) {
    	 dispatcher.trigger('watch_users_status', { user_ids: userIdsToWatch} );
      }
    };

    this.postMessage = function(messageData, successCallback, errorCallback) {
    	dispatcher.trigger('post_message', messageData,
    		function(response) {
	    		if (response.status == 'created') {
	    			successCallback(response.id);
	    		} else {
	    			errorCallback();
	    		}
	    	},
	    	function(error) {
	    		errorCallback(error);
	    	});
    };
	}]);
