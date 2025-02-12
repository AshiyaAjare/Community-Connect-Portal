class Api::V1::ModerationLogsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_moderator_or_admin, only: [:index, :show, :destroy]

    def index
        moderation_logs = ModerationLog.where.not(action: 0).order(created_at: :desc)
        render json: moderation_logs, status: :ok
    end

    def show
        moderation_log = ModerationLog.find(params[:id])

        if moderation_log.query_id.present?
        query = Query.includes(:tags, :responses).find(moderation_log.query_id)
        render json: { moderation_log: moderation_log, query: query }, status: :ok
        elsif moderation_log.response_id.present?
        response = Response.find(moderation_log.response_id)
        render json: { moderation_log: moderation_log, response: response }, status: :ok
        else
        render json: { moderation_log: moderation_log }, status: :ok
        end
    end

    def create
        moderation_log = ModerationLog.new(moderation_log_params)
        moderation_log.user = current_user

        if moderation_log.save
        render json: { message: 'Moderation log created successfully.', moderation_log: moderation_log }, status: :created
        else
        render json: { errors: moderation_log.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        moderation_log = ModerationLog.find(params[:id])
        if moderation_log.destroy
        render json: { message: 'Moderation log deleted successfully.' }, status: :ok
        else
        render json: { errors: 'Failed to delete moderation log.' }, status: :unprocessable_entity
        end
    end

    def restore
        moderation_log = ModerationLog.find(params[:id])

        if moderation_log.query_id.present?
        query = Query.find(moderation_log.query_id)
        query.update(discarded_at: nil)
        elsif moderation_log.response_id.present?
        response = Response.find(moderation_log.response_id)
        response.update(discarded_at: nil)
        end

        moderation_log.update(action: :restore)

        render json: { message: 'Restoration successful.', moderation_log: moderation_log }, status: :ok
    end

    private

    def moderation_log_params
        params.require(:moderation_log).permit(:action, :description, :target_type, :target_id)
    end

    def authorize_moderator_or_admin
        unless current_user.admin_user? || current_user.moderator_user?
        render json: { error: 'Access denied.' }, status: :forbidden
        end
    end
      
end
