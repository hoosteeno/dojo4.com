namespace :dato do
#
  task :pull do
  #
    require 'securerandom'
    uuid    = SecureRandom.uuid
    pull_id = uuid.to_s

  #
    rakefile  = File.expand_path(__FILE__)
    taskdir   = File.dirname(rakefile)
    libdir    = File.dirname(taskdir)
    root      = File.dirname(libdir)
    bindir    = File.join(root, 'bin')
    datadir   = "#{ root }/data/dato"
    bakdir    = "#{ root }/data/dato-#{ pull_id }"

   #
    Dir.chdir(root) do
    #
      load "./config/boot.rb" if test(?s, "./config/boot.rb")

    #
      token = (
        ENV['DATO_READ_ONLY_API_TOKEN'] ||
        ENV['DATO_API_TOKEN'] ||
        ENV['DATO_TOKEN'] ||
        ENV['TOKEN'] ||
        Site.config.get(:sekrets, :dato, :read_only_api_token) || 
        Site.config.get(:dato, :read_only_api_token) ||
        nil
      )

      if token.blank?
        abort "no dato.read_only_api_token found in either config/site.yml.enc or config/site.yml"
      end


    #
      ENV['PATH'] = [bindir, ENV['PATH']].join(':')

    #
      command = "bundle exec dato dump '--token=#{ token }'"

    #
      FileUtils.rm_rf(bakdir)
      FileUtils.mkdir_p(datadir) unless test(?d, datadir)
      FileUtils.cp_r(datadir, bakdir)
      FileUtils.rm_rf(datadir)
      FileUtils.mkdir_p(datadir)

    #
      if system(command)
        Dir.glob("data/dato/**/**").each do |file|
          puts Pathname.new(file).expand_path.relative_path_from(Pathname.new(root)).to_s
        end
        FileUtils.rm_rf(bakdir)
      else
        FileUtils.rm_rf(datadir)
        FileUtils.mv(bakdir, datadir)
        abort "#{ command } # failed with #{ $? }"
      end
    end
  end

#
  task :dump => :pull
end
