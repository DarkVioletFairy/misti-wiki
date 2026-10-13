module Api
  module V1
    module Admin
      class PagesController < BaseController
        before_action -> { require_permission!(:manage_content) }

        def index
          pages = Page.includes(:template, :published_revision).order(created_at: :desc)
          render json: pages.map { |page| serialize_page(page) }
        end

        def create
          template_revision = TemplateRevision.find(page_params[:template_revision_id])
          page = Authoring::CreatePageFromTemplate.call(
            template_revision: template_revision,
            creator: current_user,
            slug: page_params[:slug],
            locale: page_params[:locale].presence || "en",
            title: page_params[:title],
            summary: page_params[:summary]
          )

          render json: serialize_page(page), status: :created
        rescue ActiveRecord::RecordInvalid => error
          render_validation_error(error.record)
        rescue ActiveRecord::RecordNotFound
          head :not_found
        rescue ArgumentError => error
          render json: { error: { code: "invalid_template_revision", message: error.message } }, status: :unprocessable_content
        end

        def create_revision
          page = Page.find(params[:id])
          source_revision = page.page_revisions.find(revision_params[:source_revision_id])
          revision = Page.transaction do
            revision = page.page_revisions.create!(
              template_revision: source_revision.template_revision,
              created_by: current_user,
              version: page.next_revision_version,
              status: "draft",
              title: revision_params[:title].presence || source_revision.title,
              summary: revision_params.key?(:summary) ? revision_params[:summary] : source_revision.summary
            )
            blocks_for_new_revision(source_revision).each { |block| revision.page_blocks.create!(block) }
            revision
          end

          render json: serialize_page(page.reload), status: :created
        rescue ActiveRecord::RecordNotFound
          head :not_found
        rescue ActiveRecord::RecordInvalid => error
          render_validation_error(error.record)
        end

        def publish
          require_permission!(:publish_content)
          return if performed?

          page = Page.find(params[:id])
          revision = page.page_revisions.find(params[:revision_id])
          page.publish!(revision: revision)

          render json: serialize_page(page.reload)
        rescue ActiveRecord::RecordNotFound
          head :not_found
        rescue ArgumentError => error
          render json: { error: { code: "invalid_revision", message: error.message } }, status: :unprocessable_content
        end

        def unpublish
          require_permission!(:publish_content)
          return if performed?

          page = Page.find(params[:id])
          page.unpublish!
          render json: serialize_page(page)
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end

        private

        def page_params
          params.require(:page).permit(:template_revision_id, :slug, :locale, :title, :summary)
        end

        def revision_params
          params.require(:revision).permit(:source_revision_id, :title, :summary, blocks: [ :position, :block_type, { configuration: {} } ])
        end

        def blocks_for_new_revision(source_revision)
          return revision_params[:blocks] if revision_params.key?(:blocks)

          source_revision.page_blocks.map do |block|
            { position: block.position, block_type: block.block_type, configuration: block.configuration.deep_dup }
          end
        end

        def serialize_page(page)
          {
            id: page.id,
            slug: page.slug,
            locale: page.locale,
            status: page.status,
            template_id: page.template_id,
            published_revision_id: page.published_revision_id,
            published_at: page.published_at
          }
        end

        def render_validation_error(record)
          render json: { error: { code: "validation_failed", details: record.errors.to_hash } }, status: :unprocessable_content
        end
      end
    end
  end
end
