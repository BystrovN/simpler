require 'logger'

class AppLogger
  def initialize(app, log_path)
    @app = app
    @logger = Logger.new(log_path)
  end

  def call(env)
    @env = env
    request = Rack::Request.new(env)
    response = @app.call(env)
    prepare_log(request, response)
    response
  end

  private

  def prepare_log(request, response)
    status, headers, = response
    template = @env['simpler.template'] || ''
    @logger.info(
      "
      Request: #{request.request_method} #{request.fullpath}
      Handler: #{@env['simpler.controller'].class.name}##{@env['simpler.action']}
      Parameters: #{request.params}
      Response: #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} [#{headers['Content-Type']}] #{template}
      "
    )
  end
end
