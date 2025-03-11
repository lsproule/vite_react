require "vite_react/version"
require "vite_react/railtie"
require "vite_react/engine"


module ViteReact
   def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end
end
