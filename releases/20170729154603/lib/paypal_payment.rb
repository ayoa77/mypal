require 'paypal-sdk-rest'
require 'uri'
require 'socket'
require 'custom_logger'
#include PayPal::SDK::REST

class PaypalPayment

	def self.create( amount, description, meeting, base_url )
		hostname = Socket.gethostname
		redirect_urls = {
			return_url: base_url + ENV['PAYPAL_RETURN_PATH'],
			cancel_url: base_url + ENV['PAYPAL_CANCEL_PATH']
		}
		paypal_payment = PayPal::SDK::REST::Payment.new({
			intent: 'authorize',
			payer: {
				payment_method: 'paypal'
			},
			transactions: {
				amount: {
					total: sprintf( "%.02f", amount),
					currency: 'USD'
				},
				description: description
			},
			redirect_urls: redirect_urls
			})
		if paypal_payment.create
			redirect_url = paypal_payment.links.find{|v| v.method == "REDIRECT" }.href
			redirect_url_query = URI.decode_www_form URI.parse(redirect_url).query
			payment = Payment.create( amount: amount, redirect_url: redirect_url, token: redirect_url_query.assoc('token').last, payment_id: paypal_payment.id, meeting: meeting)
			CustomLogger.add(__FILE__, __method__, { description: description, redirect_urls: redirect_urls, payment: payment })
			return payment
		else
			CustomLogger.add(__FILE__, __method__, { amount: amount, description: description, meeting_id: meeting.id, redirect_urls: redirect_urls }, paypal_payment.error)
			return paypal_payment.error
		end
	end

	def self.execute( token, payer_id )
		begin
			payment = Payment.find_by( token: token )
			paypal_payment = PayPal::SDK::REST::Payment.find( payment.payment_id )
			if paypal_payment.execute( payer_id: payer_id )
				user_from = payment.meeting.conversation.request.user
				payment.meeting.propose!(user_from)
				CustomLogger.add(__FILE__, __method__, { user_id: user_from.id, payment: payment })
				GunMailer.send_meeting_proposed user_from, payment.meeting.get_other_party(user_from), payment.meeting
				return payment
			else
				CustomLogger.add(__FILE__, __method__, { payment: payment }, paypal_payment.error)
				return paypal_payment.error
			end
		rescue PayPal::SDK::REST::ResourceNotFound => err
			CustomLogger.add(__FILE__, __method__, { payment: payment }, err)
			return "Payment not found"
		end
	end

	def self.capture( payment )
		begin
			paypal_payment = PayPal::SDK::REST::Payment.find( payment.payment_id )
			authorization = PayPal::SDK::REST::Authorization.find(paypal_payment.transactions[0].related_resources[0].authorization.id)
			capture = authorization.capture({
			    amount: {
					currency: 'USD',
					total: sprintf( "%.02f", payment.amount)
					},
			    is_final_capture: true
			    })
			if capture.success? # Return true or false
				payment.capture_id = capture.id
				payment.save
				CustomLogger.add(__FILE__, __method__, { payment: payment, capture: capture })
				return true
			else
				CustomLogger.add(__FILE__, __method__, { payment: payment, capture: capture }, capture.error)
				return false
			end
		rescue PayPal::SDK::REST::ResourceNotFound => err
			CustomLogger.add(__FILE__, __method__, { payment: payment }, err)
			return false
		end
	end

	def self.refund( payment, amount )
		begin
			capture = PayPal::SDK::REST::Capture.find( payment.capture_id )
			refund = capture.refund( {
				amount: {
					currency: 'USD',
					total: sprintf( "%.02f", sprintf( "%.02f", amount))
				}
			})
			if refund.success?
				CustomLogger.add(__FILE__, __method__, { payment: payment, amount_to_refund: amount })
				return true
			else
				CustomLogger.add(__FILE__, __method__, { payment: payment, amount_to_refund: amount }, refund.error)
				return false
			end
		rescue PayPal::SDK::REST::ResourceNotFound => err
			CustomLogger.add(__FILE__, __method__, { payment: payment, amount_to_refund: amount }, err)
			return false
		end
	end

	def self.void( payment )
		begin
			paypal_payment = PayPal::SDK::REST::Payment.find( payment.payment_id )
			authorization = PayPal::SDK::REST::Authorization.find(paypal_payment.transactions[0].related_resources[0].authorization.id)
			if authorization.void # Return true or false
				CustomLogger.add(__FILE__, __method__, { payment: payment })
			    return true
			else
				CustomLogger.add(__FILE__, __method__, { payment: payment }, authorization.error)
			    return false
			end
		rescue PayPal::SDK::REST::ResourceNotFound => err
			CustomLogger.add(__FILE__, __method__, { payment: payment }, err)
			return false
		end
	end
end
