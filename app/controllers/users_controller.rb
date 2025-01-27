class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :update]

    def index
        @users = User.all 
    end

    def show
        @users = User.find(params[:id])
    end

    
end