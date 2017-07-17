class CanAccessKibana
	def self.matches?(request)
	    request.session[:user_id].present? and User.find_by(id: request.session[:user_id]).super_admin?
	end
end