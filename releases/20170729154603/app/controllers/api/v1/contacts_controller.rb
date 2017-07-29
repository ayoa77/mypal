class Api::V1::ContactsController < ApiUserController

  def index
    if signed_in?
      if params[:type] == 'manual'
        render json: current_user.contacts.manual.map(&:email), status: :ok
      elsif params[:type] == 'gmail'
        render json: current_user.contacts.gmail.order('ISNULL(`name`), `name` ASC'), status: :ok, each_serializer: ContactSerializer
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  private

  def contact_params
    params.require(:type)
  end

end