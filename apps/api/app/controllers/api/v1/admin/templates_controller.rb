module Api
  module V1
    module Admin
      class TemplatesController < BaseController
        before_action -> { require_permission!(:manage_templates) }

        def index
          templates = Template.includes(template_revisions: :template_blocks).order(:name)
          render json: templates.map { |template| serialize_template(template) }
        end

        def create
          template = Template.new(template_params.merge(created_by: current_user))
          revision = template.template_revisions.build(version: 1, status: "draft", created_by: current_user)
          block_params.each { |block| revision.template_blocks.build(block) }

          Template.transaction do
            template.save!
            revision.save!
          end

          render json: serialize_template(template), status: :created
        rescue ActiveRecord::RecordInvalid => error
          render_validation_error(error.record)
        end

        def create_revision
          template = Template.find(params[:id])
          revision = template.template_revisions.build(version: template.next_revision_version, status: "draft", created_by: current_user)
          source_revision = source_template_revision(template)
          blocks_for_new_revision(source_revision).each { |block| revision.template_blocks.build(block) }
          Template.transaction { revision.save! }

          render json: serialize_template(template.reload), status: :created
        rescue ActiveRecord::RecordNotFound
          head :not_found
        rescue ActiveRecord::RecordInvalid => error
          render_validation_error(error.record)
        end

        def publish_revision
          require_permission!(:publish_content)
          return if performed?

          revision = Template.find(params[:id]).template_revisions.find(params[:revision_id])
          revision.publish!
          render json: serialize_template(revision.template)
        rescue ActiveRecord::RecordNotFound
          head :not_found
        rescue ActiveRecord::RecordInvalid => error
          render_validation_error(error.record)
        end

        private

        def template_params
          params.require(:template).permit(:name, :slug, :description)
        end

        def block_params
          params.fetch(:blocks, []).map { |block| block.permit(:position, :block_type, configuration: {}) }
        end

        def revision_params
          params.fetch(:revision, {}).permit(:source_revision_id, blocks: [ :position, :block_type, { configuration: {} } ])
        end

        def source_template_revision(template)
          return if revision_params[:source_revision_id].blank?

          template.template_revisions.find(revision_params[:source_revision_id])
        end

        def blocks_for_new_revision(source_revision)
          return revision_params[:blocks] if revision_params.key?(:blocks)
          return [] unless source_revision

          source_revision.template_blocks.map do |block|
            { position: block.position, block_type: block.block_type, configuration: block.configuration.deep_dup }
          end
        end

        def serialize_template(template)
          {
            id: template.id,
            name: template.name,
            slug: template.slug,
            description: template.description,
            revisions: template.template_revisions.map do |revision|
              {
                id: revision.id,
                version: revision.version,
                status: revision.status,
                blocks: revision.template_blocks.map { |block| serialize_block(block) }
              }
            end
          }
        end

        def serialize_block(block)
          { id: block.id, position: block.position, block_type: block.block_type, configuration: block.configuration }
        end

        def render_validation_error(record)
          render json: { error: { code: "validation_failed", details: record.errors.to_hash } }, status: :unprocessable_content
        end
      end
    end
  end
end
