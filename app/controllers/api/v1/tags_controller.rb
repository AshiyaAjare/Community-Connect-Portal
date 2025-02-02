class Api::V1::TagsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :show]
    before_action :set_tag, only: [:show, :update, :destroy]

    # GET /api/tags
    def index
      tags = Tag.all
      render json: tags
    end

    # GET /api/tags/:id
    def show
      render json: @tag
    end

    # POST /api/tags
    def create
      tag = Tag.new(tag_params)
      if tag.save
        render json: tag, status: :created
      else
        render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/tags/:id
    def update
      if @tag.update(tag_params)
        render json: @tag
      else
        render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/tags/:id
    def destroy
      @tag.destroy
      head :no_content
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Tag not found" }, status: :not_found
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
end
