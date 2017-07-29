require 'paypal_payment'
require 'gun_mailer'
class Api::V1::PaymentsController < ApiController

	def authorize
		payment = PaypalPayment.execute( params[:token], params[:payer_id])
		if defined? payment.meeting.conversation.request.id
			request_id = payment.meeting.conversation.request.id
			render json: { request_id: request_id}, status: :ok
		else
			render json: payment, status: :not_found
		end
	end

	def redirect_url
		payment = Payment.find_by( meeting_id: params[:meeting_id])
		payment.destroy if payment.present?
		meeting = Meeting.find_by(id: params[:meeting_id])
		conversation = Conversation.find_by(id: meeting.conversation_id)
		payment = PaypalPayment.create( sprintf( "%.02f", conversation.request.reward), "Meeting on Blnkk", meeting, request.protocol() + request.host_with_port())
		if defined? payment.redirect_url
			render json: { redirect_url: payment.redirect_url}, status: :created
		else
			render json: payment, status: :unprocessable_entity
		end
	end

	def request_id
		payment = Payment.find_by( token: params[:token])
		if defined? payment.meeting.conversation.request.id
			render json: { request_id: payment.meeting.conversation.request.id }, status: :ok
		else
			render json: nil, status: :not_found
		end
	end

end