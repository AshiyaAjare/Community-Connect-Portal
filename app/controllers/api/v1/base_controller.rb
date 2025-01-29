module Api
    module V1
      class BaseController < ApplicationController
        protect_from_forgery with: :null_session
  
        # Common methods for API controllers can go here
      end
    end
  end