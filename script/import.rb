#
  require "dato"
  require "pp"
  require "map"
  require "ro"

#
  script = File.expand_path(__FILE__)
  scriptdir = File.dirname(script)
  root = File.dirname(scriptdir)


  Dir.chdir(root) do
  #
    Ro.root = "./data/import"

  #
    token = ENV['TOKEN']
    client = Dato::Site::Client.new(token)

  #
    models = Map.new

  #
    client.item_types.all.each do |item_type|
      item_type = Map.for(item_type)
      #p item_type
      identifier = item_type[:api_key]
      models[identifier] = item_type
    end

  #p models
  #exit

  # delete all existing content
    models.each do |identifier, model|
      filter = {"filter[type]" => model.id}
      client.items.all(filter).each do |item|
        item = Map.for(item)
        client.items.destroy(item.id)
      end
    end

  # import people
    model = models[:person]
    dir = "./data/import/people"
    glob = File.join(dir, "*")

    Dir.glob(glob) do |entry|
      next unless test(?d, entry)
      basename = File.basename(entry)
      slug = basename

      attributes = {
      }
    end


    ro.people.each do |person|
      p person.attributes
    end
  end
  

