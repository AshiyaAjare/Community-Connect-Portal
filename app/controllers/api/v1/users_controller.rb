module Api
  module V1
    class UsersController < BaseController
      def index
        users = User.select(:id, :first_name, :last_name, :email, :role, :password_digest, :profile_image_url)
        render json: users
      end

      def show
        user = User.find(params[:id])
        render json: user
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :profile_image, :role)
      end
    end
  end
end
