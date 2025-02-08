class QueriesController < ApplicationController
    before_action :set_query, only: %i[show edit update destroy update_status update_flag]
  
    # GET /queries
    def index
      @queries = Query.includes(:tags, :responses).all
    end
  
    # GET /queries/1
    def show
      @responses_count = @query.responses.count
    end
  
    # GET /queries/new
    def new
      @query = Query.new
      @tags = Tag.all
    end
  
    # POST /queries
    def create
      @query = Query.new(query_params)
      @tags = Tag.all
  
      if @query.save
        # Add selected tags
        add_tags_to_query
        redirect_to @query, notice: 'Query was successfully created.'
      else
        render :new
      end
    end
  
    # GET /queries/1/edit
    def edit
      @tags = Tag.all
    end
  
    # PATCH/PUT /queries/1
    def update
        # @query = Query.find(params[:id])

        # # Allow only admins to change status and flag
        # if current_user.admin_user?
        #   @query.update(status: params[:query][:status], flagged: params[:query][:flagged])
        # else
        #   flash[:alert] = "You are not authorized to perform this action."
        # end
      
        # respond_to do |format|
        #   format.html { redirect_to queries_path, notice: 'Query updated successfully.' }
        #   format.turbo_stream
        # end
    end

    # PATCH /queries/:id/status
    def update_status
        @query = Query.find(params[:id])

        if current_user.admin_user?
            @query.update(status: !@query.status)
            flash.now[:notice] = "Query status updated successfully."
        else
            flash.now[:alert] = "You are not authorized to perform this action."
        end

        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("query_#{@query.id}", partial: 'queries/query_row', locals: { query: @query }) }
          format.html { redirect_to queries_path }
        end 
    end

        # PATCH /queries/:id/flag
    def update_flag
        @query = Query.find(params[:id])

        if current_user.admin_user?
            @query.update(flagged: !@query.flagged)
            flash.now[:notice] = "Query flag status updated successfully."
        else
            flash.now[:alert] = "You are not authorized to perform this action."
        end

        respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace("query_#{@query.id}", partial: 'queries/query_row', locals: { query: @query }) }
            format.html { redirect_to queries_path }
        end
    end
    
    
  
    # DELETE /queries/1
    def destroy
      @query.destroy
      redirect_to queries_url, notice: 'Query was successfully destroyed.'
    end
  
    private
      def set_query
        @query = Query.find(params[:id])
      end
  
      def query_params
        params.require(:query).permit(:title, :content, :user_id, tag_ids: [], new_tag: {})
      end
  
      # Adds selected tags or creates new tag and adds it
      def add_tags_to_query
        if params[:query][:tag_ids].present?
          @query.tag_ids = params[:query][:tag_ids]
        end
        if params[:query][:new_tag].present? && params[:query][:new_tag].strip != ""
          new_tag = Tag.create(name: params[:query][:new_tag])
          @query.tags << new_tag
        end
      end
  end
  