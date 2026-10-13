module Api
  module V1
    module Public
      class GameEntitiesController < ApplicationController
        def index
          entities = GameEntity.publicly_visible.where(entity_type: params[:entity_type]).order(:slug)
          render json: entities.map { |entity| serialize_entity(entity) }
        end

        private

        def serialize_entity(entity)
          { entity_type: entity.entity_type, slug: entity.slug, source_data: entity.source_data }
        end
      end
    end
  end
end
