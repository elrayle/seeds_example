# NOTE:
# Roles are used for two functions:
# 1) roles used by cancan for authentication of user actions
# 2) groups for assigning participants and sharing of works

case Rails.env
  when 'development', 'integration', 'staging', 'production'
    puts 'Adding groups...'
    Role.find_or_create_by(name: 'SuperAdmins')
    Role.find_or_create_by(name: 'LibraryAdmins')

    Role.find_or_create_by(name: 'collection1_depositors')
    Role.find_or_create_by(name: 'collection1_admins')

    Role.find_or_create_by(name: 'collection2_depositors')
    Role.find_or_create_by(name: 'collection2_admins')
end
