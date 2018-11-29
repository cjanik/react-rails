require 'net/http/persistent'

module React
  module ServerRendering
    # This renderer class makes a request to an external node service.
    # Allows you to stub out a browser environment in node.js so you can render react components
    # that have dependencies on window/document/jQuery etc
    # Assumes all assets are loaded by the node server.
    class NodeJSRenderer
      def logger
        @@logger ||= defined?(Rails.logger) ? Rails.logger : Logger.new(STDOUT)
      end
      # @context is not available using this class
      def initialize(options={})
        @uri = URI(options.fetch(:node_server_url, ''))
        @http = Net::HTTP::Persistent.new name: 'server_renderer'
        logger.info "initialized Net::HTTP connection"
      end

      def render(component_name, props, prerender_options)
        logger.info "prerendering #{component_name}"
        props = props.to_json
        # @uri.query = URI.encode_www_form({ :component_name => component_name, :props => props })
        # resp = @http.request(@uri)

        post = Net::HTTP::Post.new @uri.path
        post['Content-Type'] = 'application/json'
        post.set_form_data { component_name: component_name, props: props }
        resp = @http.request @uri, post

        logger.info resp
        resp.body
      rescue => err
        logger.info err
        raise React::ServerRendering::PrerenderError.new(component_name, props, err)
      end
    end
  end
end
