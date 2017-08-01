require 'custom_logger'

class OauthServicesController < BaseController
	def callback
		if params[:error].present?
			CustomLogger.add(__FILE__, __method__, { }, params[:error])
			redirect_to invite_users_path
		elsif params[:code].present?
			begin
				access_token = authenticate_at_google( params[:code], root_url + 'oauth2callback' )

				# access_token = JSON.parse(response.body)["access_token"]
				contactsResponse = RestClient.get "https://www.google.com/m8/feeds/contacts/default/full",
					{ params: { alt: 'json', :'max-results' => '1000', v: '3' }, :'Authorization' => "Bearer #{access_token}" }
				entries = JSON.parse(contactsResponse)["feed"]["entry"]
				save_contacts entries
				redirect_to invite_users_path(gresult: 'success')
			rescue => err
				# Log error
				CustomLogger.add(__FILE__, __method__, {google: { code: params[:code] }}, err.inspect)
				redirect_to invite_users_path(gresult: 'error')
			end
		else
			redirect_to invite_users_path(gresult: 'unknown')
		end
	end

	def authentication
		if params[:error].present?
			CustomLogger.add(__FILE__, __method__, { }, params[:error])
			redirect_to "/?auth_result=error"
		elsif params[:code].present?
			begin
				state_params = params[:state].split(/&/)
				state_params = Hash[state_params.map {|state_param| [state_param.split(/\=/)[0], state_param.split(/\=/)[1]]}]
				client_redirect = "/"
				if state_params["redirect"].present?
					client_redirect = state_params["redirect"]
				end
				redirect_path = client_redirect + "?ln=#{state_params['ln']}"
				provider = state_params["provider"]
				email = ''
				if (provider == 'google')
					user_info = authenticate_at_google( params[:code], root_url + 'oauth2authentication' )
				elsif provider == 'facebook'
					user_info = authenticate_at_facebook( params[:code], 'http://globetutoring.com/' + 'oauth2authentication', state_params["type"] )
# change for local
					if state_params["type"] == 'info'
						if signed_in?
							current_user.facebook_url = user_info[:facebook_url]
							current_user.facebook_name = user_info[:facebook_name]
							current_user.save
							redirect_to (root_url + redirect_path).gsub! %r{(?<!:)/+(?=/)}, ''
							return
						else
							redirect_to "/?auth_result=not_found" # user not found
							return
						end
					end
				else
					user_info = authenticate_at_linkedin( params[:code], root_url + 'oauth2authentication' )
					if state_params["type"] == 'info'
						if signed_in?
							current_user.linkedin_url = user_info[:linkedin_url]
							current_user.linkedin_name = user_info[:linkedin_name]
							current_user.save
							redirect_to (root_url + redirect_path).gsub! %r{(?<!:)/+(?=/)}, ''
							return
						else
							redirect_to "/?auth_result=not_found" # user not found
							return
						end
					end
				end
				if state_params["type"] == 'signin'
					user = User.find_by(email: user_info[:email])
					if !user.present? || !user.enabled?
            redirect_to "/?auth_result=not_found" # user not found
            return
          end
        else #signup
          # if user.present?
          #   sign_out
          #   redirect_to "/?auth_result=exist" # user not found
          #   return
          # else
          if !user.present?
            user = User.create(
          	email: user_info[:email],
          	name: (user_info[:name].present? ? user_info[:name] : user_info[:email][/[^@]+/]),
          	avatar_url: user_info[:avatar_url],
          	linkedin_url: user_info[:linkedin_url],
          	linkedin_name: user_info[:linkedin_name],
	          facebook_url: user_info[:facebook_url],
	          facebook_name: user_info[:facebook_name])
	          user.reload
          end
        end

        if user && user.enabled?
        	sign_in user.id, provider
          if (provider == 'google')
	          session[:g_access_token] = user_info[:access_token]
	        else
	        	session[:li_access_token] = user_info[:access_token]
	        end
					redirect_to (root_url + redirect_path).gsub! %r{(?<!:)/+(?=/)}, ''
        else
          redirect_to "/?auth_result=not_found" # user not found
        end

			rescue => err
				CustomLogger.add(__FILE__, __method__, {provider: provider, code: params[:code] }, err.inspect)
				redirect_to "/?auth_result=error"
			end
		else
			redirect_to "/?auth_result=unknown"
		end
	end

	private

	def authenticate_at_google code, redirect_uri
		response = nil
		begin
			response = RestClient.post "https://www.googleapis.com/oauth2/v3/token",
				code: code,
				client_id: Rails.application.secrets.google_client_id,
				client_secret: Rails.application.secrets.google_client_secret,
				redirect_uri: redirect_uri,
				grant_type: 'authorization_code'
		rescue => err
			CustomLogger.add(__FILE__, __method__,
				{ code: code,
				  client_id: Rails.application.secrets.google_client_id,
				  client_secret: Rails.application.secrets.google_client_secret,
				  redirect_uri: redirect_uri,
				  grant_type: 'authorization_code'
				}, err.inspect)
			raise err
		end
		json_response = JSON.parse(response.body)
		access_token = json_response["access_token"]
		id_token = json_response["id_token"]
		if id_token.present?
			jwt = JWT.decode(id_token, nil, false)

			response = RestClient.get "https://www.googleapis.com/plus/v1/people/me",
				{ :'Authorization' => "Bearer #{access_token}" }
			json_response = JSON.parse(response.body)
			avatar_url = nil
			if json_response["image"].present? && json_response["image"]["url"].present?
				avatar_url = json_response["image"]["url"].split('?')[0]
			end
			user_info = { email: jwt[0]['email'], name: json_response["displayName"], access_token: access_token, avatar_url: avatar_url }
			return user_info
		else
			return access_token
		end
	end

	def authenticate_at_linkedin code, redirect_uri
		response = nil
		begin
			response = RestClient.post "https://www.linkedin.com/uas/oauth2/accessToken",
				code: code,
				client_id: Rails.application.secrets.linkedin_client_id,
				client_secret: Rails.application.secrets.linkedin_client_secret,
				redirect_uri: redirect_uri,
				grant_type: 'authorization_code'
		rescue => err
			CustomLogger.add(__FILE__, __method__,
				{ code: code,
					client_id: Rails.application.secrets.linkedin_client_id,
					client_secret: Rails.application.secrets.linkedin_client_secret,
					redirect_uri: redirect_uri,
					grant_type: 'authorization_code'
				}, err.inspect)
			raise err
		end
		json_response = JSON.parse(response.body)
		access_token = json_response["access_token"]

		response = RestClient.get "https://api.linkedin.com/v1/people/~:(formatted-name,public-profile-url,email-address,summary,picture-url)?format=json",
			{ :'Authorization' => "Bearer #{access_token}" }
		json_response = JSON.parse(response.body)
		avatar_url = nil
		if json_response["pictureUrl"].present?
			avatar_url = json_response["pictureUrl"]
		end
		user_info = { email: json_response["emailAddress"], name: json_response["formattedName"], access_token: access_token, linkedin_url: json_response["publicProfileUrl"], linkedin_name: json_response["formattedName"], avatar_url: avatar_url }
		return user_info
	end

	def authenticate_at_facebook code, redirect_uri, connect_type
		response = nil
		begin
			response = RestClient.get "https://graph.facebook.com/v2.9/oauth/access_token", { params: {
					code: code,
					client_id: Rails.application.secrets.facebook_client_id,
					client_secret: Rails.application.secrets.facebook_client_secret,
					redirect_uri: redirect_uri
				} }
		rescue => err
			CustomLogger.add(__FILE__, __method__,
				{ code: code,
					client_id: Rails.application.secrets.facebook_client_id,
					client_secret: Rails.application.secrets.facebook_client_secret,
					redirect_uri: redirect_uri
				}, err.inspect)
			raise err
		end
		json_response = JSON.parse(response.body)
		access_token = json_response["access_token"]

		fields = connect_type == "info" ? "link,name" : "name,email,link"
		response = RestClient.get "https://graph.facebook.com/me?access_token=#{access_token}&fields=#{fields}&format=json"
		json_response = JSON.parse(response.body)
		user_info = { email: json_response["email"], name: json_response["name"], facebook_name: json_response["name"], access_token: access_token, facebook_url: json_response["link"] }

		response = RestClient.get "https://graph.facebook.com/me/picture?access_token=#{access_token}&redirect=false&format=json&type=large"

		json_response = JSON.parse(response.body)
		avatar_url = nil
		if json_response["data"]["url"].present?
			avatar_url = json_response["data"]["url"]
		end
		user_info[:avatar_url] = avatar_url
		return user_info
	end

	def save_contacts entries
		entries.each do |entry|
			emails = entry["gd$email"]
			if emails.present?
				contact_name = entry["title"]["$t"]
				email =  emails[0]["address"].downcase
				if !contact_name.present?
					contact_name = nil #email[/[^@]+/]
				end
				Contact.create(user:current_user, source: :gmail, email: email, name: contact_name)
			end
		end
	end
end
