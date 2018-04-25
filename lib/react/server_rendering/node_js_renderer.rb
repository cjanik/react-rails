module React
  module ServerRendering

    # This renderer class makes a request to an external node service.
    # Allows you to stub out a browser environment in node.js so you can render react components
    # that have dependencies on window/document/jQuery etc
    # Assumes all assets are loaded by the node server.
    class NodeJSRenderer
      # @context is not available using this class
      def initialize(options={})
        @node_server_url = options.fetch(:node_server_url, '')
      end

      def render(component_name, props, prerender_options)
        props = props.to_json
        HTTParty.get(@node_server_url, query: { component_name: component_name, props: props }).to_s
      rescue ExecJS::ProgramError => err
        raise React::ServerRendering::PrerenderError.new(component_name, props, err)
      end
    end
  end
end
