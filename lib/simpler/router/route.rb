module Simpler
  class Router
    class Route
      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
        @path_regex = path_to_regexp(path)
      end

      def match?(method, path)
        match_data = path.match(@path_regex)
        match_data && @method == method
      end

      def extract_params(env)
        params = {}
        match_data = env['PATH_INFO'].match(@path_regex)
        @path.scan(/:(\w+)/).flatten.each_with_index do |name, index|
          params[name.to_sym] = match_data.captures[index]
        end
        params
      end

      private

      def path_to_regexp(path)
        Regexp.new('\A' + path.gsub(/:\w+/, '([^\/]+)') + '\z')
      end
    end
  end
end
