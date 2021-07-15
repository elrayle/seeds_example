case Rails.env
when 'development', 'integration', 'staging', 'production'
  puts 'Adding collection types...'

  as_ct = Hyrax::CollectionType.find_or_create_admin_set_type
  as_ct.title = 'Administrative Set'
  as_ct.badge_color = '#405060'
  as_ct.save

  user_ct = Hyrax::CollectionType.find_by(machine_id: Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID)
  unless user_ct.present?
    options = {
      description: Hyrax::CollectionTypes::CreateService::USER_COLLECTION_OPTIONS[:description],
      nestable: true,
      brandable: false,
      discoverable: false,
      sharable: true,
      share_applies_to_new_works: false,
      allow_multiple_membership: true,
      require_membership: false,
      assigns_workflow: false,
      assigns_visibility: false,
      badge_color: '#705070',
      participants: [{ agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE, agent_id: 'SuperAdmins', access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS },
                     { agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE, agent_id: ::Ability.registered_group_name, access: Hyrax::CollectionTypeParticipant::CREATE_ACCESS }]
    }
    Hyrax::CollectionTypes::CreateService.create_collection_type(machine_id: Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID, title: 'User Collection', options: options)
  end

  org_ct = Hyrax::CollectionType.find_or_create_organization_type
end
