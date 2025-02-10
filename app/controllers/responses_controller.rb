class ResponsesController < ApplicationController
    before_action :authenticate_user! # Ensure user is signed in
    before_action :authorize_admin!, only: [:upvote, :downvote, :like, :toggle_approval, :toggle_flag]
    before_action :set_response, only: [:destroy, :upvote, :downvote, :like, :toggle_approval, :toggle_flag]
  
    # GET /responses
    def index
      @responses = Response.includes(:user, :query, :tags).kept
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
  
    # PATCH /responses/:id/toggle_approval
    def toggle_approval
      @response = Response.find(params[:id])
      @response.update(approval: !@response.approval)
      @response.query.update!(status: true) if @response.approval
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Approval status updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", partial: "responses/response", locals: { response: @response })
        end
      end
    end
  
    # PATCH /responses/:id/toggle_flag
    def toggle_flag
      @response = Response.find(params[:id])
      @response.update(flagged: !@response.flagged)
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Approval status updated." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("response-#{@response.id}", partial: "responses/response", locals: { response: @response })
        end
      end
    end
  
    # DELETE /responses/:id
    def destroy
      @response.destroy
      respond_to do |format|
        format.html { redirect_to responses_path, notice: "Response deleted." }
        format.turbo_stream # No need to manually create a Turbo Stream view!
      end
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
  