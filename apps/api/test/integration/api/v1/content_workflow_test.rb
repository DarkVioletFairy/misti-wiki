require "test_helper"

class Api::V1::ContentWorkflowTest < ActionDispatch::IntegrationTest
  test "public pages exclude drafts and expose only the published snapshot" do
    owner = create_user(role_name: "owner")
    template_revision = create_template_revision(owner)
    draft_page = create_page(template_revision, owner, "draft-guide")
    published_page = create_page(template_revision, owner, "published-guide")
    published_page.publish!(revision: published_page.page_revisions.first)

    get "/api/v1/public/pages/en/draft-guide"
    assert_response :not_found

    get "/api/v1/public/pages/en/published-guide"
    assert_response :success
    assert_equal "Published guide", response.parsed_body.fetch("title")
    assert_equal [ "rich_text" ], response.parsed_body.fetch("blocks").pluck("block_type")
    assert_not_includes response.parsed_body.keys, "status"
    assert_not_includes response.parsed_body.keys, "template_id"
  end

  test "a page draft copies its template blocks and remains independent" do
    owner = create_user(role_name: "owner")
    template_revision = create_template_revision(owner)
    page = create_page(template_revision, owner, "independent-guide")
    draft_copy = TemplateRevision.create!(template: template_revision.template, created_by: owner, version: 2, status: "draft")
    draft_copy.template_blocks.create!(position: 0, block_type: "rich_text", configuration: { "text" => "Original template" })

    draft_copy.template_blocks.first.update!(configuration: { "text" => "Changed template" })

    assert_equal({ "text" => "Original template" }, page.page_revisions.first.page_blocks.first.configuration)
    assert_equal template_revision.id, page.page_revisions.first.template_revision_id
  end

  test "public game entity endpoint excludes unreleased records" do
    GameEntity.create!(entity_type: "trekker", source_id: unique("released"), slug: unique("released"), publicly_available: true, released_at: 1.day.ago)
    GameEntity.create!(entity_type: "trekker", source_id: unique("unreleased"), slug: unique("unreleased"), publicly_available: false)
    GameEntity.create!(entity_type: "trekker", source_id: unique("future"), slug: unique("future"), publicly_available: true, released_at: 1.day.from_now)

    get "/api/v1/public/game-entities/trekker"

    assert_response :success
    assert_equal 1, response.parsed_body.length
  end

  test "only users with publishing permission can publish a page" do
    editor = create_user(role_name: "editor")
    publisher = create_user(role_name: "publisher")
    template_revision = create_template_revision(editor)
    page = create_page(template_revision, editor, "permission-guide")

    patch "/api/v1/admin/pages/#{page.id}/publish/#{page.page_revisions.first.id}", headers: authorization_header(editor)
    assert_response :forbidden

    patch "/api/v1/admin/pages/#{page.id}/publish/#{page.page_revisions.first.id}", headers: authorization_header(publisher)
    assert_response :success
    assert_equal "published", page.reload.status
  end

  test "admin endpoints require an authenticated user" do
    get "/api/v1/admin/templates"

    assert_response :unauthorized
  end

  test "an editor can sign in, create a template, and create a new template revision" do
    editor = create_user(role_name: "editor")

    post "/api/v1/session", params: { email: editor.email, password: "strong-password-123" }
    assert_response :created
    token = response.parsed_body.fetch("token")

    post "/api/v1/admin/templates",
      params: {
        template: { name: "Build guide", slug: unique("build-guide"), description: "Starter layout" },
        blocks: [ { position: 0, block_type: "note", configuration: { text: "Use this first." } } ]
      },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :created
    template = response.parsed_body
    source_revision_id = template.fetch("revisions").first.fetch("id")

    post "/api/v1/admin/templates/#{template.fetch("id")}/revisions",
      params: { revision: { source_revision_id: source_revision_id } },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :created
    assert_equal 2, response.parsed_body.fetch("revisions").length
    assert_equal [ "note" ], response.parsed_body.fetch("revisions").last.fetch("blocks").pluck("block_type")
  end

  test "new page revisions preserve the published page snapshot" do
    publisher = create_user(role_name: "publisher")
    template_revision = create_template_revision(publisher)
    page = create_page(template_revision, publisher, "versioned-guide")
    page.publish!(revision: page.page_revisions.first)
    source_revision = page.page_revisions.first

    post "/api/v1/admin/pages/#{page.id}/revisions",
      params: {
        revision: {
          source_revision_id: source_revision.id,
          title: "Updated draft",
          blocks: [ { position: 0, block_type: "rich_text", configuration: { text: "New draft content" } } ]
        }
      },
      headers: authorization_header(publisher)
    assert_response :created
    assert_equal 2, page.reload.page_revisions.count
    assert_equal({ "text" => "New draft content" }, page.page_revisions.order(:version).last.page_blocks.first.configuration)

    get "/api/v1/public/pages/en/versioned-guide"
    assert_response :success
    assert_equal "Draft guide", response.parsed_body.fetch("title")
  end

  test "published revision blocks cannot be changed" do
    publisher = create_user(role_name: "publisher")
    template_revision = create_template_revision(publisher)
    page = create_page(template_revision, publisher, "locked-guide")
    page.publish!(revision: page.page_revisions.first)
    block = page.published_revision.page_blocks.first

    block.configuration = { "text" => "Changed" }

    assert_not block.save
    assert_includes block.errors.full_messages, "published page revisions are immutable"
  end

  private

  def create_user(role_name:)
    role = Role.find_or_create_by!(name: role_name)
    User.create!(role:, email: "#{unique("user")}@example.test", password: "strong-password-123", password_confirmation: "strong-password-123")
  end

  def create_template_revision(owner)
    template = Template.create!(created_by: owner, name: unique("Template"), slug: unique("template"))
    revision = TemplateRevision.create!(template:, created_by: owner, version: 1, status: "draft")
    revision.template_blocks.create!(position: 0, block_type: "rich_text", configuration: { "text" => "Original template" })
    revision.publish!
    revision
  end

  def create_page(template_revision, owner, slug)
    Authoring::CreatePageFromTemplate.call(
      template_revision:,
      creator: owner,
      slug:,
      locale: "en",
      title: slug == "published-guide" ? "Published guide" : "Draft guide",
      summary: "A summary"
    )
  end

  def authorization_header(user)
    _session, token = ApiSession.issue_for!(user)
    { "Authorization" => "Bearer #{token}" }
  end

  def unique(prefix)
    "#{prefix}-#{SecureRandom.hex(6)}"
  end
end
