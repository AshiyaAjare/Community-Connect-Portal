class ModerationLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_moderator_or_admin, only: [:index, :show, :destroy]

  def index
    @moderation_logs = ModerationLog.where.not(action: 0).order(created_at: :desc)
  end

  def show
    @moderation_log = ModerationLog.find(params[:id])
  
    if @moderation_log.query_id.present?
      @query = Query.includes(:tags, :responses).find(@moderation_log.query_id)
    elsif @moderation_log.response_id.present?
      @response = Response.find(@moderation_log.response_id)
    end
  end
  

  def create
    @moderation_log = ModerationLog.new(moderation_log_params)
    @moderation_log.user = current_user

    if @moderation_log.save
      redirect_to moderation_logs_path, notice: 'Moderation log created successfully.'
    else
      render json: { errors: @moderation_log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @moderation_log = ModerationLog.find(params[:id])
    @moderation_log.destroy
    redirect_to moderation_logs_path, notice: 'Moderation log deleted successfully.'
  end

  def restore
    @moderation_log = ModerationLog.find(params[:id])
  
    if @moderation_log.query_id.present?
      query = Query.find(@moderation_log.query_id)
      query.update(discarded_at: nil)
    elsif @moderation_log.response_id.present?
      response = Response.find(@moderation_log.response_id)
      response.update(discarded_at: nil)
    end
  
    @moderation_log.update(action: :restore)
  
    redirect_to moderation_logs_path, notice: "Restoration successful!"
  end
  

  private

  def moderation_log_params
    params.require(:moderation_log).permit(:action, :description, :target_type, :target_id)
  end

  def authorize_moderator_or_admin
    unless current_user.admin_user? || current_user.moderator_user?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
