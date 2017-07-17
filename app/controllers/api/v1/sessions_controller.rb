require 'custom_logger'
class Api::V1::SessionsController < ApiController

  skip_before_action :verify_authenticity_token

  def signin_persona
    persona_handler 'signin'
  end

  def signup_persona
    persona_handler 'signup'
  end

  def signout_persona
    if session[:provider].present? && session[:provider] == 'google'
      sign_out_from_google
    end
    sign_out
    render json: nil, status: 200
  end

  private

  def persona_handler type
    verification_data = nil
    status = :ok
    user = nil
    if params[:assertion]
      response = authenticate_with_persona(params[:assertion])
      case response
      when Net::HTTPSuccess then
        verification_data = JSON.parse(response.body())
        email = verification_data['email']
        user = User.find_by(email: email)
        if type == 'signin'
          if user.present? && user.enabled?
            sign_in user.id, 'persona'
          else
            status = :not_found # user not found
          end
        else #signup
          if user.present?
            sign_in user.id, 'persona'
          else # !user.present?
            user = User.new(email: email, name: email[/[^@]+/])
            if user.save
              user.reload
              sign_in user.id, 'persona'
            else
              status = :forbidden # probably not invited
            end
          end
        end
      else
        status = :internal_server_error # no persona response
      end
    else
      status = :unprocessable_entity # assertion missing
    end
    render json: nil, status: status
  end

  def sign_out_from_google
    http = Net::HTTP.new('accounts.google.com', 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new("/o/oauth2/revoke?token=#{session[:g_access_token]}")
    response = http.request(request)
    return response
  end

  def authenticate_with_persona(assertion)
    audience = root_url
    http = Net::HTTP.new('verifier.login.persona.org', 443)
    http.use_ssl = true
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    data = "audience=#{audience}&assertion=#{assertion}"
    response = http.post("/verify", data, headers)
    return response
  end

end