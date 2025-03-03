module Api
    module V1
      class QueriesController < ApplicationController
        before_action :set_query, only: %i[show update destroy update_status update_flag]
        before_action :authenticate_user! # Ensure API authentication
  
        # GET /api/v1/queries
        def index
          @queries = if params[:search].present?
                       Query.kept.joins(:tags).where("tags.name LIKE ?", "%#{params[:search]}%").distinct
                     else
                       Query.includes(:tags, :responses, :user).kept
                     end
        
          render json: {
            message: I18n.t('api.queries.index.success'),
            queries: @queries.as_json(
              only: [:id, :title, :content, :created_at],
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
            query: @query.as_json(
              only: [:id, :title, :content, :created_at],
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
        @query = Query.new(query_params)

        if @query.save
          add_tags_to_query
          render json: { message: I18n.t('api.queries.create.success'), query: @query }, status: :created
        else
          render json: { errors: @query.errors.full_messages, message: I18n.t('api.queries.create.failure') }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/queries/:id
      def update
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

      def set_query
        @query = Query.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: I18n.t('api.queries.not_found') }, status: :not_found
      end

      def query_params
        params.require(:query).permit(:title, :content, :user_id, tag_ids: [], new_tag: {})
      end

      def add_tags_to_query
        @query.tag_ids = params[:query][:tag_ids] if params[:query][:tag_ids].present?
        if params[:query][:new_tag].present? && params[:query][:new_tag].strip != ""
          new_tag = Tag.create(name: params[:query][:new_tag])
          @query.tags << new_tag
        end
      end

      def log_flag_status
        ModerationLog.find_or_initialize_by(query_id: @query.id, action: :flag).update(updated_at: Time.current)
      end

      end
    end
  end
  