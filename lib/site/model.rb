module Site
  class Model
  #
    include Tagz

  #
    Fattr(:root){
      Pathname.new(
        case
          when defined?(Rails.root)
            File.join(Rails.root.to_s, 'data')
          when defined?(Middleman::Application.root)
            File.join(Middleman::Application.root, 'data')
          else
            'data'
        end
      )
    }

  #
    Fattr(:collection_name){ name.downcase.underscore }
    Fattr(:basename){ "#{ collection_name }.yml" }
    Fattr(:file){ Model.root.join(basename) }
    Fattr(:env){ Rails.env }
    Fattr(:caching){ env.to_s == 'production' }
    Fattr(:reloaded_at)
    Fattr(:sort_key){ :position }
    Fattr(:model_name){ ActiveModel::Name.new(Map.for(:name => name)) }
    fattr(:model_name){ self.class.model_name } 

  #
    fattr(:sort_key){ self.class.sort_key }

    def Model.reload
      if Rails.env.production? && @reloaded_at
        return @collection
      end

      if @reloaded_at
        if @collection
          mtime = file.stat.mtime rescue Time.now
          if @reloaded_at > mtime
            return @collection
          end
        end
      end

      list = YAML.load(file.binread)

      unless list.is_a?(Array)
        list = [list]
      end

      @collection = list.map{|attributes| new(attributes)}.sort!

      index!

      @reloaded_at = Time.now

      @collection
    end

    def Model.reload!
      @reloaded_at = nil
      reload
    end

    def Model.index
      reload! unless @collection
      build_index! unless @index
      @index
    end

    def Model.index!
      @index = nil
      index
    end

    def Model.build_index!
      @index = Map.new

      keys = %w[ id slug ]
      keys.each{|key| @index[key] = Map.new}

      @collection.each do |model|
        keys.each do |key|
          val = model[key]
          next if val.blank? 
          index[key][val] = model
        end
      end

      @index
    end

    def Model.collection
      self == Model ? [] : reload
    end

    def Model.all(*args, &block)
      collection(*args, &block)
    end

    def collection
      self.class.collection
    end

    %w[
      select
      detect
      grep
      first
      last
      sort_by
      each
    ].each do |method|
      class_eval <<-__
        def Model.#{ method }(*args, &block)
          collection.send('#{ method }', *args, &block)
        end
      __
    end

  #
    fattr(:attributes)

    def initialize(attributes = {})
      @attributes = Map.for(attributes)
    end

    def method_missing(method, *args, &block)
      attributes.send(method, *args, &block)
    end

    def Model.find(key)
      keys = [key, key.to_s.to_i, key.to_s]
      indexes = %w[ id slug ]

      keys.each do |key|
        indexes.each do |idx|
          model = index[idx][key]
          return model if model
        end
      end

      nil
    end

    def Model.[](key)
      find(key)
    end

    def Model.where(conditions = {})
      collection.each do |model|
        match =
          conditions.all do |key, val|
            model[key] == val || model[key].to_s == val.to_s
          end

        if match
          return model
        end
      end

      []
    end

    def Model.find_by(conditions = {})
      where(conditions).first
    end

    def Model.for(arg)
      arg.is_a?(self) ? arg : find(arg)
    end

    def Model.instance
      collection.first
    end

    def localize(key, *args, &block)
      options = Map.options_for!(args)

      unless args.empty?
        options[:locale] ||= args.shift
      end

      locale = options[:locale] ? options[:locale].to_s.to_sym : I18n.locale

      locale_key = [:locales, locale, key]

      if has?(locale_key)
        value = get(locale_key)
        return value if '' != value && nil != value && [] != value
      end

      if block
        return block.call
      else
        if has?(key)
          return get(key)
        end
      end

      nil
    end
    alias_method :l, :localize

    def localized_keys_for(locale, *keys)
      keys = Coerce.list_of_strings(keys)

      localized_keys = []

      if locale.present?
        localized_keys.push [:locales, Locale.for(locale), *keys]
      end

      localized_keys.push keys

      localized_keys
    end

    def localized_value_for(locale, *keys)
      localized_keys_for(locale, *keys).each do |key|
        if has?(key)
          return get(key)
        end
      end

      nil
    end

    def slug
      self[:slug] || Slug.for(self[:title] || self[:name])
    end

    def to_s
      slug
    end

    def to_param
      slug
    end

    def cache_key
      cache_key = [self.class.model_name.cache_key, slug].join('/')
    end

    def cache_key_for(*args)
      absolute_path_for(cache_key, *args)
    end
   
    def paths_for(*args)
      args.flatten.compact.join('/').
        gsub!(%r|[.]+/|, '/').
        squeeze!('/').
        sub!(%r|^/|, '').
        sub!(%r|/$|, '').
        split('/')
    end

    def absolute_path_for(*args)
      absolute_path = ('/' + paths_for(*args).join('/')).squeeze('/')
      absolute_path unless absolute_path.strip.empty?
    end
   
    def relative_path_for(*args)
      relative_path = absolute_path_for(*args).sub(%r{^/+}, '')
      relative_path unless relative_path.strip.empty?
    end

    def <=>(other)
      self[sort_key] <=> other[other.sort_key]
    rescue
      self[sort_key].to_s <=> other[other.sort_key].to_s
    end
  end
end
