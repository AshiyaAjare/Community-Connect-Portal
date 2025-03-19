module Api
    module V1
      class QueriesController < ApplicationController
        # before_action :set_query, only: %i[show update destroy update_status update_flag]
        before_action :authenticate_user! 
  
        # GET /api/v1/queries
        def index
          @queries = if params[:search].present?
                       Query.kept.joins(:tags).where("tags.name LIKE ?", "%#{params[:search]}%").order(id: :desc).distinct
                     else
                       Query.includes(:tags, :responses, :user).order(id: :desc).kept
                     end
                     
          render json: {
            message: I18n.t('api.queries.index.success'),
            queries: @queries.as_json(
              only: [:id, :title, :content, :created_at, :status],
              include: {
                user: { only: [:id, :first_name, :last_name] },
                tags: { only: [:id, :name] },
                responses: {
                  only: [:id, :content, :upvotes, :downvotes, :likes, :flagged, :approval, :created_at],
                  include: {
                    user: { only: [:id, :first_name, :last_name] }
                  }
                }
              }
            )
          }, status: :ok
        end
        
        
        

      # GET /api/v1/queries/:id
      def show
        render json: {
            message: I18n.t('api.queries.index.success'),
            query: query.as_json(
              only: [:id, :title, :content, :created_at, :status],
              include: {
                user: { only: [:id, :first_name, :last_name] },
                tags: { only: [:id, :name] },
                responses: {
                  only: [:id, :content, :upvotes, :downvotes, :likes, :flagged, :approval, :created_at],
                  include: {
                    user: { only: [:id, :first_name, :last_name] }
                  }
                }
              }
            )
          }, status: :ok
      end

      # POST /api/v1/queries
      def create
        Rails.logger.info "Received query params: #{params.inspect}" # Log incoming params
      
        @query = Query.new(query_params.except(:tag_ids, :new_tag)) # Ensure correct params
      
        if @query.save!
          if params[:tag_ids].present?
            @query.tags = Tag.where(id: params[:tag_ids]) # Assign existing tags
          end
      
          if params[:new_tag].present? && params[:new_tag].strip != ""
            new_tag = Tag.find_or_create_by(name: params[:new_tag].strip) # Prevent duplicates
            @query.tags << new_tag
          end
      
          @query.save 
      
          Rails.logger.info "Query tags after saving: #{@query.tags.inspect}" # Debugging log
          render json: { message: I18n.t('api.queries.create.success'), query: @query }, status: :created
        else
          Rails.logger.error "Query Save Failed: #{@query.errors.full_messages}"
          render json: { errors: @query.errors.full_messages, message: I18n.t('api.queries.create.failure') }, status: :unprocessable_entity
        end
      end
      
      
      
      

      # PATCH/PUT /api/v1/queries/:id
      def update
        @query = Query.kept.find(id: params[:id]) 
      
        return render json: { error: "Query not found" }, status: :not_found unless @query
      
        if current_user.admin_user?
          @query.assign_attributes(status: params[:query][:status], flagged: params[:query][:flagged])
        end
      
        if @query.update(query_params)
          add_tags_to_query
          render json: { message: I18n.t('api.queries.update.success'), query: @query }, status: :ok
        else
          render json: { errors: @query.errors.full_messages, message: I18n.t('api.queries.update.failure') }, status: :unprocessable_entity
        end
      end
      

      # PATCH /api/v1/queries/:id/status
      def update_status
        if current_user.admin_user?
          @query.update(status: !@query.status)
          render json: { message: I18n.t('api.queries.update_status.success'), query: @query }, status: :ok
        else
          render json: { error: I18n.t('api.queries.update_status.forbidden') }, status: :forbidden
        end
      end

      # PATCH /api/v1/queries/:id/flag
      def update_flag
        if current_user.admin_user?
          @query.update(flagged: !@query.flagged)
          log_flag_status if @query.flagged?
          render json: { message: I18n.t('api.queries.update_flag.success'), query: @query }, status: :ok
        else
          render json: { error: I18n.t('api.queries.update_flag.forbidden') }, status: :forbidden
        end
      end

      # DELETE /api/v1/queries/:id
      def destroy
        @query.discard
        ModerationLog.find_or_initialize_by(query_id: @query.id, action: :soft_delete).update(updated_at: Time.current)
        render json: { message: I18n.t('api.queries.destroy.success') }, status: :ok
      end

      # POST /api/v1/queries/:id/restore
      def restore
        @query.update(discarded_at: nil)
        render json: { message: I18n.t('api.queries.restore.success'), query: @query }, status: :ok
      end

      private

      def query
        @query ||= Query.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: I18n.t('api.queries.not_found') }, status: :not_found
      end

      def query_params
        params.permit(:title, :content, :user_id, :new_tag, tag_ids: [])
      end

      def add_tags_to_query
        if params[:query][:tag_ids].present?
          @query.tag_ids = params[:query][:tag_ids] 
        end
      
        if params[:query][:new_tag].present? && params[:query][:new_tag].strip != ""
          new_tag = Tag.create(name: params[:query][:new_tag])
          @query.tags << new_tag
        end
      
        @query.save 
      end
      

      def log_flag_status
        ModerationLog.find_or_initialize_by(query_id: @query.id, action: :flag).update(updated_at: Time.current)
      end

      end
    end
  end
  