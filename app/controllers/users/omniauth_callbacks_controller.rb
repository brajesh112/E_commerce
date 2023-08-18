class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
   def google_oauth2
   	
     user = User.from_google(uid: auth.uid, email: auth.info.email, avatar: auth.info.image)

     if user.present?
       sign_out_all_scopes
       flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
       sign_in_and_redirect user, event: :authentication
     else
       flash[:alert] = t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
       redirect_to new_user_session_path
     end
    end

   #  def facebook
   #  	debugger
   #  	@user = User.from_omniauth(uid: auth.uid, email: auth.info.email, avatar: auth.info.image)
			# if @user.present?
			# 	flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Facebook'
   #    	sign_in_and_redirect @user, event: :authentication
   #    	# set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
   #  	else
   #  		 # flash[:alert] = t 'devise.omniauth_callbacks.failure', kind: 'Facebook', reason: "#{auth.info.email} is not authorized."
   #     # redirect_to new_user_session_path
   #    	session["devise.facebook_data"] = request.env['omniauth.auth']
   #    	redirect_to new_user_registration_url
   #  	end
  	# end

  	# def failure
   #  	redirect_to root_path
  	# end

    def from_google_params
    	
      @from_google_params ||= {
        uid: auth.uid,
        email: auth.info.email,
        avatar: auth.info.image
      }
    end
    def auth
      @auth ||= request.env['omniauth.auth']
    end
end