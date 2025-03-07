class TagsController < ApplicationController
    before_action :set_tag, only: [:destroy]

    def index
        @tags = Tag.kept
    end

    # def show
    #     @tag = Tag.find(params[:id]) # Fixed variable name
    # end

    # def new
    #     @tag = Tag.new
    # end

    # def create
    #     @tag = Tag.new(tag_params)

    #     if @tag.save
    #     flash[:notice] = "Tag created successfully"
    #     respond_to do |format|
    #         format.html { redirect_to tags_path, notice: "Tag created successfully" } # Fixed redirect
    #         format.turbo_stream 
    #     end
    #     else
    #     flash[:alert] = "Error creating tag: #{@tag.errors.full_messages.join(', ')}"
    #     render :new, status: :unprocessable_entity
    #     end
    # end

    # def update
    #     if @tag.update(tag_params)
    #     redirect_to tags_path, notice: "Tag updated successfully." # Removed redundant save
    #     else
    #     render :edit
    #     end
    # end

    # Soft Delete
    def destroy
        @tag.discard
        respond_to do |format|
        format.html { redirect_to tags_path, notice: 'Tag was successfully discarded.' }
        format.json { head :no_content }
        end
    end

    private # Good practice to mark private methods explicitly

    def set_tag
        @tag = Tag.find(params[:id])
    end

    def tag_params
        params.require(:tag).permit(:name)
    end
      
end
