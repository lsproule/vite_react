require "rails"
require "rails/railtie"
require_relative "react_helper"

require "net/http"
require "json"
require "securerandom"

module ViteReact
  module ReactComponentHelper
    # Usage:
    #   <%== react_component("MyComponent", props: { name: "Alice" }) %>
    # for client‑side hydration, and:
    #
    #   <%== react_component("MyComponent", props: { name: "Alice" }) do %>
    #     <div>Extra ERB content</div>
    #   <% end %>
    #
    # for SSR via renderToPipeableStream.
    def react_component(name, props: {}, &block)
      if block_given?
        # SERVER‑SIDE RENDERING: capture block content
        children_html = capture(&block)
        # Merge in the children as a prop for your React component
        props_with_children = props.merge(children: children_html)
        ssr_html = render_react_component_ssr(name, props_with_children)
        ssr_html
      else
        # CLIENT‑SIDE RENDERING: output a placeholder div with data attributes
        placeholder_id = "react-component-#{SecureRandom.hex(8)}"
        content_tag(:div, "",
                    id: placeholder_id,
                    data: { react_component: name, props: props.to_json })
      end
    end

    private

    def render_react_component_ssr(name, props)
      port = ViteReactSSR.config.node_server_port
      uri = URI("http://localhost:#{port}/render")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      req.body = { component: name, props: props }.to_json

      res = http.request(req)
      if res.is_a?(Net::HTTPSuccess)
        res.body.html_safe
      else
        Rails.logger.error("SSR Error: #{res.code} #{res.body}")
        "Error rendering component"
      end
    rescue => e
      Rails.logger.error("SSR Exception: #{e.message}")
      "Error rendering component"
    end
  end
end


module ViteReact
  class Railtie < ::Rails::Railtie
    initializer "vite_react.action_view" do
      ActiveSupport.on_load(:action_view) do
        include ViteReact::ReactComponentHelper
      end
    end
    rake_tasks do
      load "tasks/install.rake"
    end
  end
end
