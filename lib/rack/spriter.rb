require 'spriter'

module Rack
  class Spriter

    File = ::File

    def initialize(app, options = {})
      options = default_options.merge(options)
      @app = app
      @stylesheets_path = options[:stylesheets_path]
      ::Spriter.assets_path = options[:assets_path]
      ::Spriter.sprite_image_path = options[:sprite_image_path]
      ::Spriter.sprite_image_url = options[:sprite_image_url]
    end

    def default_options
      defaults = {
        :sprite_image_url => '/images/sprites.png'
      }

      if defined? Rails
        defaults.merge(
          :stylesheets_path => File.join(Rails.root, *%w[ public stylesheets ]),
          :assets_path => File.join(Rails.root, *%w[ public images sprite_assets ]),
          :sprite_image_path => File.join(Rails.root, *%w[ public images sprites.png ])
        )
      else
        defaults
      end
    end

    def call(env)
      if css = generate_css(env)
        return [200, {"Content-Type" => "text/css", "Cache-Control" => "private"}, [css]]
      else
        @app.call(env)
      end
    end
    
    private
    def generate_css(env)
      if Rack::Request.new(env).path =~ %r{stylesheets\/(.+)\.css$}
        name = $1
        spriter_path = File.join(@stylesheets_path, "#{name}.spriter")
        generated_css($1) if File.exist? spriter_path
      end
    end

    def generated_css(name)
      paths = Dir.glob(File.join(@stylesheets_path, '*.spriter'))
      paths.sort!
      files = paths.map{ |p| File.new(p, 'r') }

      if @generated_css.nil? or files.max{ |a,b| a.mtime <=> b.mtime }.mtime > @generated_at
        names = paths.map{ |p| p =~ %r{stylesheets/(.+)\.spriter$}; $1 }
        css = ::Spriter.transform(*files)
        css = [css] unless css.is_a? Array
        @generated_at = Time.now
        @generated_css = Hash[*names.zip(css).flatten]
      end

      @generated_css[name]
    end
  end
end
