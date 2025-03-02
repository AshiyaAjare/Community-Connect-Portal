class Users::InvitationsController < Devise::InvitationsController
    # before_action :authenticate_user!  
    before_action :configure_permitted_parameters, only: [:create]
    respond_to :json
    skip_before_action :verify_authenticity_token, only: [:update]
  
    def create
      super do |resource|
        if resource.errors.empty?
          redirect_to letter_opener_web.letters_path and return
        end
      end
    end

    def after_accept_path_for(resource)
      "#{ENV['FRONTEND_URL']}/accept-invite?email=#{resource.email}&token=#{params[:invitation_token]}"
    end
  
    # def update
    #   super
    # end
  
    private
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [:role])
    end
end
  