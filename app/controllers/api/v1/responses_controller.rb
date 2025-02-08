class Api::V1::ResponsesController < ApplicationController
    before_action :authenticate_user! # Ensure user is authenticated
    before_action :set_query, only: [:create]
    before_action :set_response, only: [:show, :update, :destroy]
  
    # GET /api/v1/responses
    def index
      responses = Response.includes(:tags, :query).all
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
        # Attach all existing tags from the associated query
        response.tags << @query.tags
  
        # Attach selected tags
        if params[:tag_ids]
          response.tags << Tag.where(id: params[:tag_ids])
        end
  
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
      if @response.update(response_params)
        render json: @response.as_json(include: { tags: { only: [:id, :name] } })
      else
        render json: { errors: @response.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /api/v1/responses/:id
    def destroy
      @response.destroy
      render json: { message: "Response deleted successfully" }, status: :ok
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
      params.require(:response).permit(:content, tag_ids: [])
    end
end
  