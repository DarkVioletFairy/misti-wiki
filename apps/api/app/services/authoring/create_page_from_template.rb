module Authoring
  class CreatePageFromTemplate
    def self.call(template_revision:, creator:, slug:, locale:, title:, summary:)
      new(template_revision:, creator:, slug:, locale:, title:, summary:).call
    end

    def initialize(template_revision:, creator:, slug:, locale:, title:, summary:)
      @template_revision = template_revision
      @creator = creator
      @slug = slug
      @locale = locale
      @title = title
      @summary = summary
    end

    def call
      raise ArgumentError, "template revision must be published" unless @template_revision.status == "published"

      Page.transaction do
        page = Page.create!(template: @template_revision.template, created_by: @creator, slug: @slug, locale: @locale)
        revision = page.page_revisions.create!(
          template_revision: @template_revision,
          created_by: @creator,
          version: page.next_revision_version,
          status: "draft",
          title: @title,
          summary: @summary
        )

        @template_revision.template_blocks.order(:position).each do |block|
          revision.page_blocks.create!(
            position: block.position,
            block_type: block.block_type,
            configuration: block.configuration.deep_dup
          )
        end

        page
      end
    end
  end
end
