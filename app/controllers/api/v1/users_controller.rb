module Api
  module V1
    class UsersController < BaseController
      before_action :authorize_admin!, only: [:index, :create]

      def index
        users = User.select(:id, :first_name, :last_name, :email, :role, :profile_image_url)
        render json: { message: I18n.t('api.success.fetched', resource: 'Users'), users: users }
      end

      def show
        user = User.find_by(id: params[:id])
        if user
          render json: {
            message: I18n.t('api.success.fetched', resource: 'User'),
            user: {
              id: user.id,
              name: "#{user.first_name} #{user.last_name}",
              email: user.email,
              role: user.role,
              profile_image_url: user.profile_image_url
            }
          }, status: :ok
        else
          render json: { error: I18n.t('api.errors.not_found') }, status: :not_found
        end
      end

      def me
        render json: {
          id: current_user.id,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          email: current_user.email,
          role: current_user.role,
          profile_image_url: current_user.profile_image.attached? ? url_for(current_user.profile_image) : nil
        }
      end

      def update
        @user = current_user
        if @user.update(user_params)
          @user.profile_image_url = url_for(@user.profile_image) if @user.profile_image.attached?
          @user.save
          Rails.logger.info "Updated user attributes: #{@user.attributes}"
          render json: { message: I18n.t('api.success.updated', resource: 'User'), user: user_response(@user) }
        else
          render json: { error: I18n.t('api.errors.invalid_data'), errors: @user.errors.full_messages }, status: :unprocessable_entity
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
        params.require(:user).permit(:first_name, :last_name, :email, :profile_image, :role).tap do |params|
          if params[:password].blank?
            params.delete(:password)
            params.delete(:password_confirmation)
          end
        end
      end

      def user_response(user)
        {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          role: user.role,
          profile_image_url: user.profile_image_url
        }
      end

      def authorize_admin!
        unless current_user.admin_user?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
