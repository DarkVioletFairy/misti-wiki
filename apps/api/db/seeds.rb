# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
{
  "owner" => "Full administrative access, including user management and publishing.",
  "editor" => "Creates and edits templates and page drafts.",
  "publisher" => "Edits content and publishes approved pages.",
  "reviewer" => "Reviews imported game data."
}.each do |name, description|
  Role.find_or_create_by!(name:) { |role| role.description = description }
end
