module Api
  module V1
    module Admin
      class BaseController < ApplicationController
        before_action :authenticate_user!
      end
    end
  end
end
