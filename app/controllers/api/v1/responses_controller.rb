class Api::V1::ResponsesController < ApplicationController
  before_action :authenticate_user! # Ensure user is authenticated
  before_action :set_query, only: [:create]
  before_action :set_response, only: [:show, :update, :destroy, :upvote, :downvote, :like, :toggle_approval, :toggle_flag]
  before_action :authorize_admin!, only: [:upvote, :downvote, :like, :toggle_approval, :toggle_flag]

  # GET /api/v1/responses
  def index
    responses = Response.includes(:tags, :query).kept
    render json: responses.as_json(include: {
      tags: { only: [:id, :name] },
      query: { only: [:id, :title] }
    })
  end

  # GET /api/v1/responses/:id
  def show
    render json: @response.as_json(include: {
      tags: { only: [:id, :name] },
      query: { only: [:id, :title, :content] }
    })
  end

  # POST /api/v1/queries/:query_id/responses
  def create
    response = current_user.responses.new(response_params)
    response.query = @query

    if response.save
      response.tags << @query.tags # Attach all existing tags from query

      # Attach selected tags
      response.tags << Tag.where(id: params[:tag_ids]) if params[:tag_ids]

      # Create and attach a new tag if provided
      if params[:new_tag].present?
        new_tag = Tag.create(name: params[:new_tag])
        response.tags << new_tag if new_tag.persisted?
      end

      render json: response.as_json(include: { tags: { only: [:id, :name] } }), status: :created
    else
      render json: { errors: response.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/responses/:id
  def update
    # Allow users to update only content and tags, while approval and flagged are admin-controlled
    permitted_params = response_params
    permitted_params.except!(:approval, :flagged, :likes, :upvotes, :downvotes) unless current_user.admin_user?

    if @response.update(permitted_params)
      render json: { message: "Response updated successfully", response: @response.as_json(include: { tags: { only: [:id, :name] } }) }
    else
      render json: { errors: @response.errors.full_messages }, status: :unprocessable_entity
    end
  end


  # PATCH /api/v1/responses/:id/upvote
  def upvote
    @response.increment!(:upvotes)
    render json: { message: "Upvote successful", response: @response }
  end

  # PATCH /api/v1/responses/:id/downvote
  def downvote
    @response.increment!(:downvotes)
    render json: { message: "Downvote successful", response: @response }
  end

  # PATCH /api/v1/responses/:id/like
  def like
    @response.increment!(:likes)
    render json: { message: "Like successful", response: @response }
  end

  # PATCH /api/v1/responses/:id/toggle_approval
  def toggle_approval
    @response.update(approval: !@response.approval)

    if @response.approval?
      log = ModerationLog.create(response_id: @response.id, action: :approve)
      Rails.logger.error "Failed to save ModerationLog: #{log.errors.full_messages.join(", ")}" unless log.persisted?

      @response.query.update!(status: true)
    else
      @response.query.update!(status: false)
    end

    render json: { message: "Approval toggled", response: @response }
  end

  # PATCH /api/v1/responses/:id/toggle_flag
  def toggle_flag
    @response.update(flagged: !@response.flagged)

    if @response.flagged?
      log = ModerationLog.create(response_id: @response.id, action: :flag)
      Rails.logger.error "Failed to save ModerationLog: #{log.errors.full_messages.join(", ")}" unless log.persisted?
    end

    render json: { message: "Flag status toggled", response: @response }
  end

  # DELETE /api/v1/responses/:id
  def destroy
    @response.discard
    log = ModerationLog.find_or_initialize_by(response_id: @response.id, action: :soft_delete)
    log.update(updated_at: Time.current)

    render json: { message: "Response deleted successfully" }, status: :ok
  end

  # PATCH /api/v1/responses/:id/restore
  def restore
    @response.update(discarded_at: nil)
    render json: { message: "Response restored successfully", response: @response }
  end

  private

  def set_query
    @query = Query.find(params[:query_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Query not found" }, status: :not_found
  end

  def set_response
    @response = Response.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Response not found" }, status: :not_found
  end

  def response_params
    params.require(:response).permit(:content, :approval, :flagged, :likes, :upvotes, :downvotes, tag_ids: [])
  end

  def authorize_admin!
    unless current_user.admin_user?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
