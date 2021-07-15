# Create a public collections
# @param [User] user creating the collection
# @param [String] collection type gid
# @param [String] id to use for the new collection
# @param [Hash] options holding metadata and permissions for the new collection
def create_collection(user, type_gid, id, options)
  # find existing collection if it already exists
  col = Collection.where(id: id)
  return col.first if col.present?

  # remove stale permisisons for the collection id
  remove_access(collection_id: id)

  # create collection
  col = Collection.new(id: id)
  col.attributes = options.except(:permissions)
  col.apply_depositor_metadata(user.user_key)
  col.collection_type_gid = type_gid
  col.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  col.save

  # apply new permissions
  add_access(collection: col, grants: options[:permissions])
  col
end

# Add access grants to a collection
# @param collection [Collection] the collection to modify
# @param grants [Array<Hash>] array of grants to add to the collection
# @example grants
#   [ { agent_type: Hyrax::PermissionTemplateAccess::GROUP,
#       agent_id: 'my_group_name',
#       access: Hyrax::PermissionTemplateAccess::DEPOSIT } ]
# @see Hyrax::PermissionTemplateAccess for valid values for agent_type and access
def add_access(collection:, grants:)
  template = Hyrax::PermissionTemplate.find_or_create_by(source_id: collection.id)
  grants.each do |grant|
    Hyrax::PermissionTemplateAccess.find_or_create_by(permission_template_id: template.id,
                                                      agent_type: grant[:agent_type],
                                                      agent_id: grant[:agent_id],
                                                      access: grant[:access])
  end
  collection.reset_access_controls! # updates solr
end

# Remove all access grants for a specific collection id
# @param collection_id [String] the id of stale collection
def remove_access(collection_id:)
  templates = Hyrax::PermissionTemplate.where(source_id: collection_id)
  return unless templates.present?
  templates.each { |template| template.destroy! }
end

case Rails.env
when 'development', 'integration', 'staging', 'production'
  organization_gid = CollectionTypeService.organization_gid
  unless organization_gid.present?
    puts 'Failed to get Organization collection type.  Unable to create collections.'
    return
  end

  # Create default admin set
  AdminSet.find_or_create_default_admin_set_id

  user = User.find_by(email: ENV['ADMIN_EMAIL'])
  unless user.present?
    puts 'Failed to get admin user.  Unable to create collections.'
    return
  end

  base_grants = [ { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'SuperAdmins', access: Hyrax::PermissionTemplateAccess::MANAGE },
                  { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'LibraryAdmins', access: Hyrax::PermissionTemplateAccess::MANAGE } ]

  puts 'Adding collections...'
  unless Collection.exists?(title: 'Collection 1')
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'collection1_admins', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'collection1_depositors', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    subcol_permissions = [{ agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'collection1_admins', access: Hyrax::PermissionTemplateAccess::DEPOSIT }]
    subcol_permissions = [{ agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'collection1_depositors', access: Hyrax::PermissionTemplateAccess::DEPOSIT }]
    col1 = create_collection(user, organization_gid, 'collection1',
                             title: ['Collection 1'],
                             description: ['Example collection 1.'],
                             permissions: permissions + subcol_permissions)
    sub_col1 = create_collection(user, organization_gid, 'sub-col1',
                                 title: ['Sub-collection of Collection 1'],
                                 description: ["Example Sub-collection of Collection 1."],
                                 permissions: permissions + subcol_permissions)
    Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(parent: col1, child: sub_col1)
  end

  unless Collection.exists?(title: "Collection 2")
    permissions = base_grants.dup
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'collection2_admins', access: Hyrax::PermissionTemplateAccess::MANAGE }
    permissions << { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: 'collection2_depositors', access: Hyrax::PermissionTemplateAccess::DEPOSIT }
    create_collection(user, organization_gid, 'collection2',
                      title: ['Collection 2'],
                      description: ['Example collection 2.'],
                      permissions: permissions)
  end
end
