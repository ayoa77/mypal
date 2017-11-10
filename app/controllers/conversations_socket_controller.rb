require 'custom_logger'

class ConversationsSocketController < WebsocketRails::BaseController

  before_filter :select_database

  def initialize_session
    begin
      # connected_users will store the connected users ID
      controller_store[:connected_users] = Hash.new(0)
      ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
        controller_store[:connected_users][db[0]] = Hash.new(0)
      end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  def post_message
    begin
    	if signed_in?
        # find or create the conversation
        conversation = nil
        is_new_conversation = false
        system_message = nil
        if message['message'].present? && message['message']['conversation_id'].present?
          # message for existing conversation
          conversation = Conversation.find_by(id: message['message']['conversation_id']);
        else
          # message for new conversation
          if message['request_id'].present?
            request = Request.find_by(id: message['request_id'])
            # We should check that request.user is not current_user and return an error if it is the case
            if request.present? && request.user != current_user
              # must_add_system_message = !request.users.include?(current_user)
              conversation = request.user.conversations.where( id: current_user.conversations.pluck(:id) ).first
              if !conversation.present?
                is_new_conversation = true
                conversation = Conversation.create
                conversation.users << current_user # add the message poster to this conversation
                conversation.users << request.user # add the request starter to this conversation
              end
              # if must_add_system_message
              system_message = Message.create(conversation: conversation, user: current_user, system_generated: true, content: { type: "message_from_request", requestId: request.id, requestContent: request.real_subject.truncate(140) }.to_json )
              # end
              request.users << current_user unless request.users.include?(current_user) # add current user to request users (needed for adding a request to this user's dashboard)
              request.update_score(:comment)
            end
          elsif message['user_id'].present?
            other_user = User.find(message['user_id'])
            if other_user.present?
              conversation = other_user.conversations.where( id: current_user.conversations.pluck(:id) ).first
              if !conversation.present?
                is_new_conversation = true
                conversation = Conversation.create
                conversation.users << current_user # add the message poster to this conversation
                conversation.users << other_user # add the target user to this conversation
              end
            end
          end
        end
        # add the message
        if conversation.present? && conversation.users.include?(current_user)
          last_message = conversation.messages.last
          if last_message.present? && last_message.user == current_user && last_message.content == message['message']['content']
            trigger_failure status: :conflict
          else
            new_message = Message.create(conversation: conversation, user: current_user, content: message['message']['content'])
            if new_message.present?
            	online_users = get_online_users_ids
              if current_user.avatar_stored?
                user_avatar = Dragonfly.app.fetch(current_user.avatar_uid).url
              else
                user_avatar = nil
              end
              if is_new_conversation
              	conversation.users.each { |user|
              		if current_user.id == user.id || online_users.include?(user.id)
                    Fiber.new do
    		              WebsocketRails["#{@websocket_prefix}_user_#{user.id}"].trigger(:conversation_new, { conversation_id: conversation.id, content: new_message.content, from_user: current_user.name, user_avatar: user_avatar, from_self: current_user == user, unread_conversations_count: ConversationUser.where( user: user, unread: true).count })
                    end.resume
    	            elsif current_user != user
    	            	notify_by_email user, new_message, conversation
    	            end
                }
              else
              	conversation.users.each { |user|
              		if current_user.id == user.id || online_users.include?(user.id)
                    if system_message.present?
                      Fiber.new do
                        WebsocketRails["#{@websocket_prefix}_user_#{user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: system_message, from_user: current_user.name, user_avatar: user_avatar, from_self: current_user == user, unread_conversations_count: ConversationUser.where( user: user, unread: true).count })
                      end.resume
                    end
                    Fiber.new do
                  		WebsocketRails["#{@websocket_prefix}_user_#{user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: new_message, from_user: current_user.name, user_avatar: user_avatar, from_self: current_user == user, unread_conversations_count: ConversationUser.where( user: user, unread: true).count })
                    end.resume
              		elsif current_user.id != user.id
    	            	notify_by_email user, new_message, conversation
                	end
              	}
              end
              
              trigger_success status: :created, id: conversation.id
            else
              trigger_failure errors: new_message.errors, status: :unprocessable_entity
            end
          end
        else
          trigger_failure status: :not_found
        end

      else
        trigger_failure status: :unauthorized
      end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  def conversation_read
    begin
    	user = User.find_by( id: message['user_id'] )
    	conversation = Conversation.find_by( id: message['conversation_id'] )
    	if user.present?
        if conversation.present?
          conversation.mark_read(user)
        end
        Fiber.new do
          # ConversationUser.uncached do
          begin
            WebsocketRails["#{@websocket_prefix}_user_#{user.id}"].trigger(:conversation_read_update, { count: ConversationUser.where( user: user, unread: true).count })
          rescue
          end
          # end
          begin
            WebsocketRails["#{@websocket_prefix}_user_#{current_user.id}"].trigger(:notification_read_update, { count: Notification.where( user: current_user, read: false).count })
          rescue
          end
          trigger_success
        end.resume
    	end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  def watch_users_status
    begin
    	if signed_in?
    		online_users = get_online_users_ids
    		watched_online_users = Array.new
    		connection_store.clear
        if message['user_ids'].present?
    	  	message['user_ids'].each { |user_id|
    	  		connection_store[user_id] = current_user.id
    	  		if online_users.include? user_id
    	  			watched_online_users << user_id
    	  		end
    	  	}
        end
  	  	send_users_online_status_update watched_online_users
  		end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  def is_typing
    begin
      if signed_in?
        conversation = Conversation.find_by( id: message['conversation_id'] )
        if conversation.present?
          other_user = nil
          conversation.users.each { |user|
            other_user = user if user.id != current_user.id
          }
          Fiber.new do
            WebsocketRails["#{@websocket_prefix}_user_#{other_user.id}"].trigger(:user_is_typing, { conversation_id: conversation.id, is_typing: message['is_typing'] })
            trigger_success
          end.resume
        else
          trigger_failure status: :not_found
        end
      end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  def user_connected
    begin
      user_key = params[:key]
      session[:user_id] ||= params[:user_id]
    	if signed_in? && user_key.present? && user_key == current_user.socket_key
    		# if controller_store[:connected_users].index(current_user.id) == nil
  		  # 	controller_store[:connected_users] << current_user.id
  		  # end
        controller_store[:connected_users][@websocket_prefix][current_user.id] = controller_store[:connected_users][@websocket_prefix][current_user.id] + 1;
        current_user.update_columns(online: true)
  	  	users_watching_me = get_users_watching_me
  	  	users_watching_me.each { |user_id|
          Fiber.new do
    	  		WebsocketRails["#{@websocket_prefix}_user_#{user_id}"].trigger(:user_status_connected, { user_id: current_user.id })
          end.resume
  	  	}
        trigger_success #needed?

      else
        CustomLogger.add(__FILE__, __method__, {connection: "closed", user: (current_user.to_json rescue nil), session_user_id: session[:user_id], key: user_key, websocket_prefix: @websocket_prefix })
        connection.close!
  		end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  def user_disconnected
    begin
    	if signed_in?
  	  	# controller_store[:connected_users].delete current_user.id
        controller_store[:connected_users][@websocket_prefix][current_user.id] = controller_store[:connected_users][@websocket_prefix][current_user.id] - 1;
        if controller_store[:connected_users][@websocket_prefix][current_user.id] <= 0
          controller_store[:connected_users][@websocket_prefix][current_user.id] = 0
          current_user.update_columns(online: false, last_seen_at: Time.now)
    	  	users_watching_me = get_users_watching_me
    	  	users_watching_me.each { |user_id|
            Fiber.new do
      	  		WebsocketRails["#{@websocket_prefix}_user_#{user_id}"].trigger(:user_status_disconnected, { user_id: current_user.id })
            end.resume
    	  	}
        end
  		end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
    end
  end

  private

  	def notify_by_email user, message, conversation
      begin
      	cu = ConversationUser.where( user: user, conversation: conversation ).first
      	if !cu.notified
  	  		GunMailer.send_conversation_reply user, message
  	    	cu.notified = true
  	    	cu.save
  	    end
      rescue => err
        CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
      end
    end

  	def get_users_watching_me
      begin
  		  connection_store.collect_all(current_user.id).compact # Benji: This was compact!, changed for bugfix, is that okay?
      rescue => err
        CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
      end
  	end

  	def get_online_users_ids
      online_users = []
      begin
    		# online_users = controller_store.collect_all(:connected_users)
    		# online_users.flatten!.compact
        online_users = controller_store[:connected_users][@websocket_prefix].select { |user_id, count|
          count > 0
        }
      rescue => err
        CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
      end
      return online_users
  	end

  	def send_users_online_status_update online_users
      begin
        Fiber.new do
      		WebsocketRails["#{@websocket_prefix}_user_#{current_user.id}"].trigger(:users_status_updates, { users_id: online_users })
        end.resume
      rescue => err
        CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
      end
  	end

		def current_user
      begin
			  @_current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
      rescue => err
        CustomLogger.add(__FILE__, __method__, {websocket_prefix: @websocket_prefix }, err)
      end
      return @_current_user
		end

		def signed_in?
			!!current_user
		end

  def select_database
    @default_config ||= ActiveRecord::Base.connection.instance_variable_get("@config").dup
    begin
      if request.subdomain.empty?
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      else
        ActiveRecord::Base.establish_connection(@default_config.dup.update(:database => "blnkk_#{request.subdomain}"))
      end
      ActiveRecord::Base.connection.active? #raises expection if database does not exist
    rescue
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
    @websocket_prefix = ActiveRecord::Base.connection.current_database
  end

end