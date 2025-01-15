require_relative "lib/vite_react/version"

Gem::Specification.new do |spec|
  spec.name        = "vite_react"
  spec.version     = ViteReact::VERSION
  spec.authors     = [ "lsproule" ]
  spec.email       = [ "lucas.sproule.42@gmail.com" ]
  spec.homepage    = "docs.lucassproule.com"
  spec.summary     = "Vite react adds vite and react to your project"
  spec.description = <<~DESCRIPTION
    Vite react adds a few generators and vite and react
    to your rails project. It also gets it set up to be able 
    to use shadcn. 
  DESCRIPTION
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.1"
end
