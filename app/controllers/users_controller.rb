class UsersController < ApplicationController
    #skip_before_action :authenticate_request, only[:create]
    before_action :set_user, only: [:edit, :update, :show, :destroy]

    def index
        @users = User.kept
    end

    def show
        @users = User.find(params[:id])
    end

    def new
      @user = User.new
    end
    
    def create
      params[:user][:role] = params[:user][:role].to_i if params[:user][:role].present?
      
      @user = User.new(user_params)
      
      if @user.save
        if @user.profile_image.attached?
          @user.profile_image_url = url_for(@user.profile_image)
        else
          @user.profile_image_url = url_for('assets/images/default_image.png')
        end
        @user.save
        flash[:notice] = "User created successfully"
        respond_to do |format|
          format.html { redirect_to users_path, notice: "User created" }
          format.turbo_stream # This will look for create.turbo_stream.erb
        end
      else
        flash[:alert] = "Error creating user: #{@user.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    end
    
    def update
        if @user.update(user_params)
          @user.profile_image_url = url_for(@user.profile_image) if @user.profile_image.attached?
          @user.save
          redirect_to users_path, notice: "User updated successfully."
        else
          render :edit
        end
    end

    #Soft Delete
    def destroy
      @user.discard
      respond_to do |format|
        format.html { redirect_to users_path, notice: 'User was successfully discarded.' }
        format.json { head :no_content }
      end
    end
    
      # Set user based on ID from params
    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        #byebug
        params.require(:user).permit(:first_name, :last_name, :email, :password, :profile_image, :role)
    end

end