class ResponsesController < ApplicationController
    before_action :authenticate_user! # Ensuring user is signed in
    before_action :authorize_admin!, only: [:upvote, :downvote, :like, :toggle_approval, :toggle_flag]
    before_action :set_response, only: [:destroy, :upvote, :downvote, :like, :toggle_approval, :toggle_flag]
  
    # GET /responses
    def index
      
      @responses = Response.includes(:user, :query, :tags).kept.paginate(page: params[:page], per_page: 6)
    end
  
    # PATCH /responses/:id/upvote
    def upvote
      @response = Response.find(params[:id])
      @response.increment!(:upvotes)
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Upvotes updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", 
          partial: "responses/response", 
          locals: { response: @response })
        end
      end
    end
  
    # PATCH /responses/:id/downvote
    def downvote
      @response = Response.find(params[:id])
      @response.increment!(:downvotes)
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Downvotes updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", partial: "responses/response", locals: { response: @response })
        end
      end
    end
  
    # PATCH /responses/:id/like
    def like
      @response = Response.find(params[:id])
      @response.increment!(:likes)
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Likes updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", partial: "responses/response", locals: { response: @response })
        end
      end
    end
  
    # PATCH /responses/:id/toggle_app val
    def toggle_approval
      @response = Response.find(params[:id])
      @response.update(approval: !@response.approval)
      if @response.approval?
        log = ModerationLog.create(response_id: @response.id, action: :approve)
        unless log.persisted?
          Rails.logger.error "Failed to save ModerationLog: #{log.errors.full_messages.join(", ")}"
        end
      end
      if @response.approval?
        @response.query.update!(status: :true) 
      else
        @response.query.update!(status: :false)
      end
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Flag status updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", partial: "responses/response", locals: { response: @response })
        end
      end
    end
  
    # PATCH /responses/:id/toggle_flag
    def toggle_flag
      @response = Response.find(params[:id])
      @response.update(flagged: !@response.flagged)
      if @response.flagged?
        log = ModerationLog.create(response_id: @response.id, action: :flag)
        unless log.persisted?
          Rails.logger.error "Failed to save ModerationLog: #{log.errors.full_messages.join(", ")}"
        end
      end
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Flag status updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", partial: "responses/response", locals: { response: @response })
        end
      end
    end
  
    # DELETE /responses/:id
    def destroy
      @response.discard
      log = ModerationLog.find_or_initialize_by(response_id: @response.id, action: :soft_delete)
      log.update(updated_at: Time.current)
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Response deleted." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("response-#{@response.id}")
        end
      end
    end

    def restore
      @response = Response.find(params[:id])
      @response.update(discarded_at: nil)
      redirect_to moderation_logs_path, notice: "Response restored successfully."
    end
    
  
    private
  
    def set_query
      @query = Query.find(params[:query_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to queries_path, alert: 'Query not found.'
    end
  
    def set_response
      @response = Response.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to responses_path, alert: 'Response not found.'
    end
  
    def response_params
      params.require(:response).permit(:content, :approval, :flagged, :likes, :upvotes, :downvotes, tag_ids: [])
    end

    def authorize_admin!
        unless current_user.admin_user? # Check if the user is an admin
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
    end
    
  
    def render_response_partial
      respond_to do |format|
        format.html { render partial: 'responses/response', locals: { response: @response } }
        format.html { redirect_to responses_path }
      end
    end
  end
  