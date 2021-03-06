require 'tilt'

module HoganAssets
  class Tilt < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def initialize_engine
      require_template_library 'haml'
    rescue LoadError
      # haml not available
    end

    def evaluate(scope, locals, &block)
      if scope.pathname.extname == '.hamstache'
        raise "Unable to complile #{scope.pathname} because haml is not available. Did you add the haml gem?" unless HoganAssets::Config.haml_available?
        compiled_template = Haml::Engine.new(data, @options).render
        compiled_template = Hogan.compile(compiled_template)
      else
        compiled_template = Hogan.compile(data)
      end
      template_name = scope.logical_path.inspect
      <<-TEMPLATE
        this.HoganTemplates || (this.HoganTemplates = {});
        this.HoganTemplates[#{template_name}] = new Hogan.Template(#{compiled_template});
      TEMPLATE
    end

    protected

    def prepare; end
  end
end
