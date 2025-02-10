class ModerationLogsController < ApplicationController
  def index
    @moderation_logs = ModerationLog.where.not(action: 0).order(created_at: :desc)
  end
end
