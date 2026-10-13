module Api
  module V1
    module Public
      class PagesController < ApplicationController
        def index
          pages = Page.publicly_visible.includes(published_revision: :page_blocks).order(:slug)
          render json: pages.map { |page| serialize_page(page) }
        end

        def show
          page = Page.publicly_visible.includes(published_revision: :page_blocks).find_by!(locale: params[:locale], slug: params[:slug])
          render json: serialize_page(page)
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end

        private

        def serialize_page(page)
          revision = page.published_revision
          {
            slug: page.slug,
            locale: page.locale,
            title: revision.title,
            summary: revision.summary,
            published_at: page.published_at,
            blocks: revision.page_blocks.map do |block|
              { position: block.position, block_type: block.block_type, configuration: block.configuration }
            end
          }
        end
      end
    end
  end
end
