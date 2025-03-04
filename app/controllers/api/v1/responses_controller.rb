class Api::V1::ResponsesController < ApplicationController
  before_action :authenticate_user! # Ensure user is authenticated
  before_action :set_query, only: [:create]
  before_action :set_response, only: [:show, :update, :destroy, :upvote, :downvote, :like, :toggle_approval, :toggle_flag]
  #before_action :authorize_admin!, only: [:upvote, :downvote, :like, :toggle_approval, :toggle_flag]

  # GET /api/v1/responses
  def index
    responses = Response.includes(:tags, :query, :user).kept
    render json: { 
      message: I18n.t('api.success.fetched', resource: 'Responses'),
      responses: responses.as_json(include: { 
        tags: { only: [:id, :name] }, 
        query: { only: [:id, :title] }, 
        user: { only: [:id, :first_name, :last_name] } 
      })
    }
  end
  

  # GET /api/v1/responses/:id
  def show
    render json: { 
      message: I18n.t('api.success.fetched', resource: 'Response'),
      response: @response.kept.as_json(include: { tags: { only: [:id, :name] }, query: { only: [:id, :title, :content] } })
    }
  end

  # POST /api/v1/queries/:query_id/responses
  def create
    response = current_user.responses.new(response_params)
    response.query = @query

    if response.save
      response.tags << @query.tags # Attach existing query tags
      response.tags << Tag.where(id: params[:tag_ids]) if params[:tag_ids] # Attach selected tags

      # Create and attach a new tag if provided
      if params[:new_tag].present?
        new_tag = Tag.create(name: params[:new_tag])
        response.tags << new_tag if new_tag.persisted?
      end

      render json: { 
        message: I18n.t('api.success.created', resource: 'Response'),
        response: response.as_json(include: { tags: { only: [:id, :name] } })
      }, status: :created
    else
      render json: { error: I18n.t('api.errors.invalid_data'), errors: response.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/responses/:id
  def update
    permitted_params = response_params
    permitted_params.except(:approval, :flagged, :likes, :upvotes, :downvotes) unless current_user.admin_user?

    if @response.update(permitted_params)
      render json: { 
        message: I18n.t('api.success.updated', resource: 'Response'),
        response: @response.as_json(include: { tags: { only: [:id, :name] } })
      }
    else
      render json: { error: I18n.t('api.errors.invalid_data'), errors: @response.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/responses/:id/upvote
  def upvote
    @response.increment!(:upvotes)
    render json: { message: I18n.t('api.success.action_performed', action: 'Upvote'), response: @response }
  end

  # PATCH /api/v1/responses/:id/downvote
  def downvote
    @response.increment!(:downvotes)
    render json: { message: I18n.t('api.success.action_performed', action: 'Downvote'), response: @response }
  end

  # PATCH /api/v1/responses/:id/like
  def like
    @response.increment!(:likes)
    render json: { message: I18n.t('api.success.action_performed', action: 'Like'), response: @response }
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

    render json: { message: I18n.t('api.success.action_performed', action: 'Approval toggled'), response: @response }
  end

  # PATCH /api/v1/responses/:id/toggle_flag
  def toggle_flag
    @response.update(flagged: !@response.flagged)

    if @response.flagged?
      log = ModerationLog.create(response_id: @response.id, action: :flag)
      Rails.logger.error "Failed to save ModerationLog: #{log.errors.full_messages.join(", ")}" unless log.persisted?
    end

    render json: { message: I18n.t('api.success.action_performed', action: 'Flag status toggled'), response: @response }
  end

  # DELETE /api/v1/responses/:id
  def destroy
    @response.discard
    log = ModerationLog.find_or_initialize_by(response_id: @response.id, action: :soft_delete)
    log.update(updated_at: Time.current)

    render json: { message: I18n.t('api.success.deleted', resource: 'Response') }, status: :ok
  end

  # PATCH /api/v1/responses/:id/restore
  def restore
    @response.update(discarded_at: nil)
    render json: { message: I18n.t('api.success.action_performed', action: 'Response restored'), response: @response }
  end

  private

  def set_query
    @query = Query.find_by(id: params[:query_id])
    render json: { error: I18n.t('api.errors.not_found') }, status: :not_found unless @query
  end

  def set_response
    @response = Response.find_by(id: params[:id])
    render json: { error: I18n.t('api.errors.not_found') }, status: :not_found unless @response
  end

  def response_params
    params.require(:response).permit(:content, :approval, :flagged, :likes, :upvotes, :downvotes,  :new_tag, tag_ids: [])
  end

  def authorize_admin!
    unless current_user.admin_user?
      render json: { error: I18n.t('api.errors.unauthorized') }, status: :unauthorized
    end
  end
  
end
