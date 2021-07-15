case Rails.env
when 'development', 'integration'
  # NOTE: DO NOT delete users here or it will delete users created in earlier seeds.

  puts ('Adding test users...')
  library_admins_role = Role.find_by(name: 'LibraryAdmins')
  collection1_admins = Role.find_by(name: 'collection1_admins')
  collection1_depositors = Role.find_by(name: 'collection1_depositors')

  user = User.find_or_create_by(email: 'lib_admin@example.com') do |user|
    user.password = 'admin_password'
    user.password_confirmation = 'admin_password'
    user.confirmed_at = DateTime.now
  end
  user.roles << super_role unless user.roles.include?(library_admins_role)
  user.save!(validate: false)

  user = User.find_or_create_by(email: 'col1_admin@example.com') do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.confirmed_at = DateTime.now
  end
  user.roles << super_role unless user.roles.include?(collection1_admins)
  user.save!(validate: false)

  user = User.find_or_create_by(email: 'col1_depositor@example.com') do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.confirmed_at = DateTime.now
  end
  user.roles << super_role unless user.roles.include?(collection1_depositors)
  user.save!(validate: false)

  user = User.find_or_create_by(email: 'col2_admin@example.com') do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.confirmed_at = DateTime.now
  end
  user.roles << super_role unless user.roles.include?(collection2_admins)
  user.save!(validate: false)

  user = User.find_or_create_by(email: 'col2_depositor@example.com') do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.confirmed_at = DateTime.now
  end
  user.roles << super_role unless user.roles.include?(collection2_depositors)
  user.save!(validate: false)
end
