module Api
  module V1
    class UsersController < BaseController
      #skip_before_action :authenticate_user!

      def index
        users = User.select(:id, :first_name, :last_name, :email, :role, :profile_image_url)
        render json: { message: I18n.t('api.success.fetched', resource: 'Users'), users: users }
      end

      def show
        user = User.find_by(id: params[:id])
        if user
          render json: { message: I18n.t('api.success.fetched', resource: 'User'), user: user }
        else
          render json: { error: I18n.t('api.errors.not_found') }, status: :not_found
        end
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: { message: I18n.t('api.success.created', resource: 'User'), user: user }, status: :created
        else
          render json: { error: I18n.t('api.errors.invalid_data'), errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :profile_image, :role)
      end
      
    end
  end
end
