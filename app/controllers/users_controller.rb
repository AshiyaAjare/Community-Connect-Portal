class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :update]

    def index
        @users = User.all 
    end

    def show
        @users = User.find(params[:id])
    end

    def new
        @user = User.new
      end
    
      def create
        params[:user][:role] = params[:user][:role].to_i
    
        @user = User.new(user_params)
        #Due to strong parameters
        
        if @user.save
          redirect_to user_path(@user) , notice: "User created"
        else
          render :new
        end
    end

    def update
        if @user.update(user_params)
          redirect_to users_path, notice: "User updated successfully."
        else
          render :edit
        end
    end
    
      # Set user based on ID from params
    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        #byebug
        params.require(:user).permit(:first_name, :last_name, :email, :password_digest, :profile_image_url, :role)
    end

end