class Api::V1::QueriesController < ApplicationController
    
    #before_action :authenticate_user! # Ensures only authenticated users can access
    # skip_before_action :authenticate_user!, only: [:index, :show]
    before_action :set_query, only: [:show, :update, :destroy]
    
    # GET /api/queries
    def index
        queries = Query.includes(:tags, :responses).all
        render json: queries.as_json(include: { 
        tags: { only: [:id, :name] }, 
        responses: { only: [:id, :content] }
        })
    end
    
    # GET /api/queries/:id
    def show
        render json: @query.as_json(include: { 
        tags: { only: [:id, :name] }, 
        responses: { only: [:id, :content] }
        })
    end
    
    # POST /api/queries
    def create
        query = current_user.queries.new(query_params)
        
        if query.save
        # Attach existing tags or create a new tag
        if params[:tag_ids]
            query.tags << Tag.where(id: params[:tag_ids])
        end
        if params[:new_tag].present?
            new_tag = Tag.create(name: params[:new_tag])
            query.tags << new_tag if new_tag.persisted?
        end
    
        render json: query.as_json(include: { tags: { only: [:id, :name] } }), status: :created
        else
        render json: { errors: query.errors.full_messages }, status: :unprocessable_entity
        end
    end
    
    # PUT /api/queries/:id
    def update
        if @query.update(query_params)
        render json: @query.as_json(include: { tags: { only: [:id, :name] } })
        else
        render json: { errors: @query.errors.full_messages }, status: :unprocessable_entity
        end
    end
    
    # DELETE /api/queries/:id
    def destroy
        @query.destroy
        render json: { message: "Query deleted successfully" }, status: :ok
    end
    
    private
    
    def set_query
        @query = Query.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Query not found" }, status: :not_found
    end
    
    def query_params
        params.require(:query).permit(:title, :content, tag_ids: [])
    end
    
      
end
