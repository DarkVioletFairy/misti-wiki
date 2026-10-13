class CreateAuthoringFoundation < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :description
      t.timestamps
    end
    add_index :roles, :name, unique: true

    create_table :users do |t|
      t.references :role, null: false, foreign_key: true
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :api_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :api_sessions, :token_digest, unique: true
    add_index :api_sessions, :expires_at

    create_table :templates do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    add_index :templates, :slug, unique: true

    create_table :template_revisions do |t|
      t.references :template, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :version, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :published_at
      t.timestamps
    end
    add_index :template_revisions, [ :template_id, :version ], unique: true
    add_check_constraint :template_revisions,
      "status IN ('draft', 'published', 'archived')",
      name: "template_revisions_status_check"

    create_table :template_blocks do |t|
      t.references :template_revision, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :block_type, null: false
      t.jsonb :configuration, null: false, default: {}
      t.timestamps
    end
    add_index :template_blocks, [ :template_revision_id, :position ], unique: true

    create_table :pages do |t|
      t.references :template, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :slug, null: false
      t.string :locale, null: false, default: "en"
      t.string :status, null: false, default: "draft"
      t.bigint :published_revision_id
      t.datetime :published_at
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    add_index :pages, [ :locale, :slug ], unique: true
    add_check_constraint :pages,
      "status IN ('draft', 'published', 'archived')",
      name: "pages_status_check"

    create_table :page_revisions do |t|
      t.references :page, null: false, foreign_key: true
      t.references :template_revision, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :version, null: false
      t.string :status, null: false, default: "draft"
      t.string :title, null: false
      t.text :summary
      t.datetime :published_at
      t.timestamps
    end
    add_index :page_revisions, [ :page_id, :version ], unique: true
    add_check_constraint :page_revisions,
      "status IN ('draft', 'published', 'archived')",
      name: "page_revisions_status_check"
    add_foreign_key :pages, :page_revisions, column: :published_revision_id

    create_table :page_blocks do |t|
      t.references :page_revision, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :block_type, null: false
      t.jsonb :configuration, null: false, default: {}
      t.timestamps
    end
    add_index :page_blocks, [ :page_revision_id, :position ], unique: true

    create_table :game_entities do |t|
      t.string :entity_type, null: false
      t.string :source_id, null: false
      t.string :slug, null: false
      t.boolean :publicly_available, null: false, default: false
      t.datetime :released_at
      t.jsonb :source_data, null: false, default: {}
      t.timestamps
    end
    add_index :game_entities, [ :entity_type, :source_id ], unique: true
    add_index :game_entities, [ :entity_type, :slug ], unique: true
    add_index :game_entities, [ :publicly_available, :released_at ]
  end
end
