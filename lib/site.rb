module Site
  fattr(:app)
  fattr(:env){ Rails.env }
  fattr(:root){ File.dirname(File.dirname(File.expand_path(__FILE__))) }

  def Site.locale
    I18n.locale
  end

  def Site.default_locale
    :en
  end

  def Site.locale=(locale)
    I18n.locale = locale.to_s.to_sym
  end

  Fattr(:locales){ Meta.locales.map(&:to_sym) }

  def Site.locale_for(locale)
    locale.to_s.strip.downcase.to_sym
  end

  def url(*args)
    options = Map.options_for!(args) 

    only_path      = options.delete(:only_path) || options.delete(:path_only)
    path_info      = options.delete(:path_info) || options.delete(:path)
    trailing_slash = options.delete(:trailing_slash)
    query_string   = options.delete(:query_string)
    fragment       = options.delete(:fragment) || options.delete(:hash)
    query          = options.delete(:query) || options.delete(:params)

    raise(ArgumentError, 'both of query and query_string') if query and query_string

    args.push(path_info) if path_info

    path_info = ('/' + args.join('/')).gsub(%r|/+|, '/').gsub(%r|/+$|, '')

    path, ext = File.basename(path_info).split('.', 2)

    if(path != '/' && !ext && trailing_slash != false)
      path_info << '/'
    end

    unless only_path==true
      url = Site.slash + path_info
    else
      url = path_info
    end
    
    url += ('?' + query_string) unless query_string.blank?
    url += ('?' + query.query_string) unless query.blank?
    url += ('#' + fragment) if fragment
    url 
  end
  alias_method :url_for, :url

  def Site.slash(*args)
    Site.config.url.to_s.sub(%r|/*$|, '')
  end

  def config
    @config ||= (
    #
      config = Map.new

    #
      path = File.join(Site.root.to_s, 'config/site.yml')
      if test(?s, path)
        settings = Settings.for(path)
        config.update(settings)
      end

    #
      path = File.join(Site.root.to_s, 'config/site.yml.enc')
      if test(?s, path)
        settings = Sekrets.settings_for(path)
        config.update(:sekrets => settings)
        config.update(settings)
      end

    #
       if config.has_key?(env)
         config.update(config[env])
       end

    #
      config
    )
  end

  extend(Site)
end
