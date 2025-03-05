class UsersController < ApplicationController
    #skip_before_action :authenticate_request, only[:create]
    before_action :set_user, only: [:edit, :update, :show, :destroy]

    def index
        @users = User.kept.paginate(page: params[:page], per_page: 6)
    end

    def show
      Rails.logger.debug "Showing user with ID: #{params[:id]}"
      @user = User.find_by(id: params[:id])  
    
      if @user.nil?
        redirect_to users_path, alert: "User not found"
      end
    end
    

    def new
      @user = User.new
    end

    def invite
      user = User.find(id: params[:id])
      
      if current_user.admin_user?
        if user.invitation_sent_at.nil? || user.invitation_accepted_at.nil?
          user.invite! 
          respond_to do |format|
            format.js 
            format.html { redirect_to users_path, notice: "User invited" }
          end
        else
          flash[:notice] = "User already invited"
          #render json: { error: "User already invited" }, status: :unprocessable_entity
        end
      else
        Rails.logger.debug "Role: #{user.role}"
        redirect_to users_path, alert: "Only admin users can invite other users"
      end

    end
  
    
    def create
      params[:user][:role] = params[:user][:role].to_i if params[:user][:role].present?
      
      @user = User.new(user_params)
      
      if @user.save
        sign_out @user
        if params[:user][:profile_image].present?
          @user.profile_image.attach(params[:user][:profile_image])
          if @user.profile_image.attached?
            @user.profile_image_url = url_for(@user.profile_image) 
          else
            Rails.logger.debug "Image not attached successfully!"
          end
        else
          @user.profile_image_url = 'https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon'
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
      @user = User.find_by(id: params[:id])
      if @user.nil?
        redirect_to users_path, alert: "User not found"
      end
    end

    def user_params
        #byebug
        params.require(:user).permit(:first_name, :last_name, :email, :password, :profile_image, :role)
    end

end