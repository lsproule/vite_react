namespace :vite_react do
  desc "Install the vite react setup"
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/vite_react.rb", __dir__)}"
  end
end
