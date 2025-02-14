module ViteReact
  module NodeServerManager
    class << self
      def start!
        return if @started
        @started = true

        node_executable = ViteReact.config.node_path ||
                          `which bun`.strip
        unless node_executable && !node_executable.empty?
          Rails.logger.error("Node executable not found. SSR functionality disabled.")
          return
        end

        server_script = File.expand_path("/node/ssr-server.ts", __FILE__)
        port = ViteReact.config.node_server_port
        command = "#{node_executable} #{server_script} --expirimental-strip-types --port=#{port}"
        Rails.logger.info("Starting vite_react_ssr Node server with: #{command}")

        @pid = Process.spawn(command, out: "/dev/null", err: "/dev/null")
        Rails.logger.info("vite_react_ssr Node server started with pid: #{@pid}")

        sleep 1

        at_exit { stop! }
      rescue => e
        Rails.logger.error("Failed to start vite_react_ssr Node server: #{e.message}")
      end

      def stop!
        return unless @pid
        Rails.logger.info("Stopping vite_react_ssr Node server (pid: #{@pid})")
        Process.kill("TERM", @pid)
      rescue => e
        Rails.logger.error("Error stopping vite_react_ssr Node server: #{e.message}")
      end
    end
  end
end
