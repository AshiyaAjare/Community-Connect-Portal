class Users::InvitationsController < Devise::InvitationsController
    # before_action :authenticate_user!  
    before_action :configure_permitted_parameters, only: [:create]
  
    def create
      super do |resource|
        if resource.errors.empty?
          redirect_to letter_opener_web.letters_path and return
        end
      end
    end
  
    # def update
    #   super
    # end
  
    private
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [:role])
    end
end
  