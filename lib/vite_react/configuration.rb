# frozen_string_literal: true

module ViteReact
  class Configuration
    # Port for the Node/Vite SSR server.
    attr_accessor :node_server_port
    # Path to the Node executable (optional override)
    attr_accessor :node_path

    def initialize
      @node_server_port = 4000
      @node_path = nil # uses system's node by default
    end
  end
end
