class Api::V1::TagsController < ApplicationController
    # skip_before_action :authenticate_user!, only: [:index, :show]
    before_action :set_tag, only: [:show, :update, :destroy]

    # GET /api/v1/tags
    def index
      tags = Tag.all
      render json: {
        message: I18n.t('api.success.fetched', resource: 'Tags'), 
        tags: tags.as_json(only: [:id, :name]) 
        }, status: :ok
    end

    # GET /api/v1/tags/:id
    def show
      render json: { message: I18n.t('api.success.fetched', resource: 'Tag'), tag: @tag }
    end

    # POST /api/v1/tags
    def create
      tag = Tag.new(tag_params)
      if tag.save
        render json: { message: I18n.t('api.success.created', resource: 'Tag'), tag: tag }, status: :created
      else
        render json: { error: I18n.t('api.errors.invalid_data'), errors: tag.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/tags/:id
    def update
      if @tag.update(tag_params)
        render json: { message: I18n.t('api.success.updated', resource: 'Tag'), tag: @tag }
      else
        render json: { error: I18n.t('api.errors.invalid_data'), errors: @tag.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/tags/:id
    def destroy
      @tag.destroy
      render json: { message: I18n.t('api.success.deleted', resource: 'Tag') }, status: :ok
    end

    private

    def set_tag
      @tag = Tag.find(id: params[:id])
      render json: { error: I18n.t('api.errors.not_found') }, status: :not_found unless @tag
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
    
end
