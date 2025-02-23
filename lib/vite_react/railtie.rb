require "rails"
require "rails/railtie"

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
      port = 4000 # ViteReact.config.node_server_port || 4000
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


module ViteReact
  module ReactComponentHelper
    # Renders a React component with extended options.
    #
    # Options:
    #   - i18n: if true, merge current locale translations from Rails I18n YAML into props under :i18n.
    #   - filename: if provided, used to determine the component file path on the Node server.
    #
    # Example usage:
    #   <%== react_component("MyComponent", file_name="CustomFile", props: { name: "Alice" }, options: { i18n: true }) %>
    def react_component(name, file_name: nil,  props: {}, options: {}, &block)
      # Process options BEFORE any other logic.
      if options[:i18n]
        # Fetch only translations for the current locale from the YAML files.
        translations = I18n.backend.send(:translations)[I18n.locale] || {}
        props[:i18n] = translations
      end
      filename = name if file_name.nil?
      if block_given?
        # SERVER‑SIDE RENDERING: capture block content as children.
        children_html = capture(&block)
        props_with_children = props.merge(children: children_html)
        ssr_html = render_react_component_ssr(name, props_with_children, filename)
        ssr_html
      else
        # CLIENT‑SIDE RENDERING: output a placeholder div with data attributes.
        placeholder_id = "react-component-#{SecureRandom.hex(8)}"
        data_attributes = { react_component: name, props: props.to_json }
        data_attributes[:filename] = filename if filename
        content_tag(:div, "", id: placeholder_id, data: data_attributes)
      end
    end

    private

    def render_react_component_ssr(name, props, filename = nil)
      port = 4000 # Alternatively, use ViteReact.config.node_server_port || 4000
      uri = URI("http://localhost:#{port}/render")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      payload = { component: name, props: props }
      payload[:filename] = filename if filename
      req.body = payload.to_json

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
