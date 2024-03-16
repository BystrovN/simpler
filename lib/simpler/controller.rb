require_relative 'view'

module Simpler
  class Controller
    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      params.merge!(env['simpler.route_params'])
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      set_content_type('text/html')
    end

    def set_content_type(content_type)
      headers['Content-Type'] = content_type
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render_template(template)
      @request.env['simpler.template'] = template
    end

    def render_hash(hash)
      render_plain(hash[:plain]) if hash.key?(:plain)
    end

    def render_plain(text)
      set_content_type('text/plain')
      @response.write(text)
    end

    def render(options)
      case options
      when String
        render_template(options)
      when Hash
        render_hash(options)
      end
    end

    def status(code)
      @response.status = code
    end

    def headers
      @response.header
    end
  end
end
