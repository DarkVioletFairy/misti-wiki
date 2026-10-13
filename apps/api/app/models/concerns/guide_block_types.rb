module GuideBlockTypes
  ALL = %w[
    rich_text
    note
    image
    contributor_list
    collapsible_section
    trekker_profile
    team_lineup
    potential_priority
    skill_priority
    runic_disc_recommendation
    emblem_recommendation
    affix_recommendation
    rotation_steps
    data_table
    linked_entity_collection
  ].freeze

  def validate_block_configuration
    errors.add(:configuration, "must be an object") unless configuration.is_a?(Hash)
  end
end
