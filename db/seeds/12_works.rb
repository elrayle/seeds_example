case Rails.env
when 'development', 'integration'
  Publication.delete_all if Publication.count # This is a type of work.
  Release.delete_all if Release.count # This is a type of work.

  # THIS ADDS THROUGH AN API INSTEAD OF METHOD CALLS
  #
  puts 'Getting user_token...'
  user_token = get_user_token
  host = ActionMailer::Base.default_url_options[:host]

  puts "Adding works..."
  publications = {
    publication_1: {
      title: "Publication 1",
      visibility: "open",
      resource_type: "Report",
      description: "This is publication 1.",
      collection_id: "collection1",
    },
    publication_2: {
        title: "Publication 2",
        visibility: "open",
        resource_type: "Report",
        description: "This is publication 2.",
        collection_id: "collection1",
    },
    publication_3: {
        title: "Publication 3",
        visibility: "open",
        resource_type: "Report",
        description: "This is publication 3.",
        collection_id: "collection2",
    }
  }

  publications.each do |key, value|
    RestClient.post "#{host}/api/v1/publication/create",
      {
        title: value[:title],
        visibility: value[:visibility],
        resource_type: value[:resource_type],
        description: value[:description],
        collection_id: value[:collection_id]
      },
      {
        Authorization: "Bearer #{user_token}"
      }
  end
end
