class ResponsesController < ApplicationController
    before_action :set_query, only: [:new, :create]
    before_action :set_response, only: [:edit, :update, :destroy]
    
    # GET /responses
    def index
        @responses = Response.includes(:tags).all
    end
    
    # GET /responses/new
    def new
        @response = @query.responses.new
        @available_tags = Tag.all # Fetch all available tags
    end
    
    # POST /responses
    def create
        @response = current_user.responses.new(response_params)
        @response.query = @query
    
        if @response.save
        # Attach all existing tags from the associated query
        @response.tags << @query.tags
    
        # Attach selected tags
        if params[:tag_ids]
            @response.tags << Tag.where(id: params[:tag_ids])
        end
    
        # Create and attach a new tag if provided
        if params[:new_tag].present?
            new_tag = Tag.create(name: params[:new_tag])
            @response.tags << new_tag if new_tag.persisted?
        end
    
        redirect_to responses_path, notice: 'Response was successfully created.'
        else
        @available_tags = Tag.all
        render :new
        end
    end
    
    # GET /responses/:id/edit
    def edit
        @available_tags = Tag.all
    end
    
    # PATCH/PUT /responses/:id
    def update
        if @response.update(response_params)
        redirect_to responses_path, notice: 'Response was successfully updated.'
        else
        @available_tags = Tag.all
        render :edit
        end
    end
    
    # DELETE /responses/:id
    def destroy
        @response.destroy
        redirect_to responses_path, notice: 'Response was successfully deleted.'
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
        params.require(:response).permit(:content, tag_ids: [])
    end
        
end
