case Rails.env
when 'development', 'integration'
  # NOTE: Not deleting users so dev team members who have changed their password do not have it changed out from under them.
  # User.delete_all if User.count

  puts ('Adding dev team users...')
  super_role = Role.find_by(name: 'SuperAdmins')

  user = User.find_or_create_by(email: 'admin@example.com') do |user|
    user.password = 'admin_password'
    user.password_confirmation = 'admin_password'
    user.confirmed_at = DateTime.now
  end
  user.roles << super_role unless user.roles.include?(super_role)
  user.save!(validate: false)

  # NOTE: This can be used with real logins to find the user and add the role if the user exists.
  User.find(email: 'read_email@example.com') do |user|
    user.roles << super_role unless user.roles.include?(super_role)
    user.save!(validate: false)
  end
end
