# encoding: utf-8
#
begin
  require 'rubygems'
rescue LoadError
end

begin
  require 'stringex'
rescue LoadError
end

# p Slug.for("it's a girl")          #=> its-a-girl
#  
# p Slug.for('foo/bar')              #=> 'foo--bar'
#  
# p Slug.for('foo/bar', :join => :_) #=> 'foo__bar'
#  
# p Slug.for('Mötley Crüe')          #=> 'motley-crue'
#  
# p Slug.for('  foo bar.baz ')       #=> "foo-bar--baz"

class Slug < ::String
  @@join = '-'

  def Slug.for(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    join = (options[:join] || options['join'] || @@join).to_s

    shortcuts = {'dash' => '-', 'underscore' => '_'}

    if shortcuts.has_key?(join)
      join = shortcuts[join]
    end

    string = args.flatten.compact.join.underscore

    tokens = string.scan(%r{[^/.]+})

    tokens.map{|token| token.to_url.gsub('-', join)}.join(join * 2)
  end

  unless defined?(Stringex::Unidecoder)
    def Slug.unidecode(string)
      string
    end
  else
    def Slug.unidecode(string)
      Stringex::Unidecoder.decode(string)
    end
  end
end
