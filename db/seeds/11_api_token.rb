case Rails.env
when 'development', 'integration', 'staging', 'production'

  @user_token = ''

  def get_user_token
    # Getting an error connecting running seeds on your local machine?  Try deleting config/initializers/resolv.rb
    return @user_token unless @user_token.empty?
    host = ActionMailer::Base.default_url_options[:host]
    user_token = JSON.parse (RestClient.post "#{host}/user_token", auth: { email: ENV["ADMIN_EMAIL"], password: ENV["ADMIN_PASSWORD"] }) , symbolize_names: true
    @user_token = user_token[:jwt]
  end
end
