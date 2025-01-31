say "=== Vite-react setup starting... ===", :green

unless File.exist? "starting"
  create_file "starting"
else
  remove_file "starting"
  exit
end

gem "vite_rails", "~> 3.0"
gem "turbo-mount", "~> 0.4.1"
gem "tailwindcss-ruby", "~> 4.0.0.beta.9"
gem "tailwindcss-rails", "~> 3.0"
gem "opentelemetry-sdk"
gem "opentelemetry-instrumentation-rails"
gem "opentelemetry-exporter-otlp"
gem "yabeda"
gem "yabeda-gc"
gem "yabeda-rails"
gem "yabeda-activerecord"
gem "yabeda-activejob"
gem "yabeda-prometheus"



rails_command "tailwindcss:install"

gsub_file "app/views/layouts/application.html.erb",
  /<main class="container mx-auto mt-28 px-5 flex">/,
  "<main class=\"\">"

# --------------------------------------------------------------------------
# 2.3: Vite + React + Tailwind + shadcn
# --------------------------------------------------------------------------
say "=== Installing Vite, React, Tailwind, shadcn, etc. ===", :green

# --- Vite ---
run "bundle exec vite install"

# --- Install NPM dependencies ---
run <<~CMD
    npm install \
      react react-dom \
      turbo-mount stimulus-vite-helpers clsx tailwind-merge \
      @hotwired/turbo-rails  \
      @rails/actioncable @rails/activestorage \
      class-variance-authority clsx tailwind-merge lucide-react
CMD

run <<~CMD
    npm install -D \
      @vitejs/plugin-react eslint globals eslint-plugin-react-refresh typescript-eslint @eslint/js \
      @types/react @types/react-dom vite-plugin-stimulus-hmr vite-plugin-full-reload \
      tailwind @tailwindcss/postcss @tailwindcss/vite autoprefixer tailwindcss-animate @types/node \
      @tailwindcss/typography @tailwindcss/container-queries @tailwindcss/forms
CMD

# Initialize Tailwind configs
# run "npx tailwindcss init -p"
copy_file "#{__dir__}/postcss.config.mjs", "postcss.config.mjs"

# --------------------------------------------------------------------------
# 2.3.2: Overwrite vite.config.js with your React + Ruby config
# --------------------------------------------------------------------------
remove_file "vite.config.ts"
copy_file "#{__dir__}/vite.config.ts", "vite.config.ts"

# --------------------------------------------------------------------------
# 2.3.3: Add TypeScript config files
# --------------------------------------------------------------------------
copy_file "#{__dir__}/tsconfig.json", "tsconfig.json"
copy_file "#{__dir__}/tsconfig.app.json", "tsconfig.app.json"
copy_file "#{__dir__}/tsconfig.node.json", "tsconfig.node.json"

# --------------------------------------------------------------------------
# 2.3.4: Remove default Rails assets / create Stimulus + Tailwind structure
# --------------------------------------------------------------------------
remove_file "app/javascript/application.js"
remove_file "app/javascript/controllers/index.js"

create_file "app/javascript/controllers/index.js", <<~JS
    import { application } from "./application";
    import { registerControllers } from "stimulus-vite-helpers";

    const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
    registerControllers(application, controllers);
JS


copy_file "#{__dir__}/application.css", "app/javascript/entrypoints/application.css"
remove_file
copy_file "#{__dir__}/application.css", "app/assets/stylesheets/application.tailwind.css"

# 2.3.5: Create the main JS entrypoint for Vite
remove_file "app/javascript/entrypoints/application.js"
create_file "app/javascript/entrypoints/application.js", <<~JS
    import "@hotwired/turbo-rails";
    import "../controllers";
    import "./turbo-mount";
    import "./application.css";

    console.log("Hello from application.js");
JS

# --------------------------------------------------------------------------
# 2.4: turbo-mount installation
# --------------------------------------------------------------------------
say "=== Installing turbo-mount ===", :green
generate "turbo_mount:install --framework=react"

# We’ll create a dedicated turbo-mount entry for React components
remove_file "app/javascript/turbo-mount.js"
create_file "app/javascript/entrypoints/turbo-mount.js", <<~JS
    import { TurboMount } from "turbo-mount";
    import { registerComponent } from "turbo-mount/react";

    // Example React component
    import { App } from "@/components/App";

    const turboMount = new TurboMount();
    registerComponent(turboMount, "App", App);
JS

# --------------------------------------------------------------------------
# 2.5: Example React component + Home controller
# --------------------------------------------------------------------------

copy_file "#{__dir__}/App.tsx", "app/javascript/components/App.tsx"

empty_directory "public/images"
run <<~CMD
    curl -o public/images/rails.svg https://raw.githubusercontent.com/lsproule/react-rails-template/refs/heads/main/images/rails.svg
    curl -o public/images/vite.svg https://raw.githubusercontent.com/lsproule/react-rails-template/refs/heads/main/images/vite.svg
    curl -o public/images/react.svg https://raw.githubusercontent.com/lsproule/react-rails-template/refs/heads/main/images/react.svg
CMD

generate :controller, "route", "index", "--skip-routes", "--no-helper", "--no-assets"
route "root to: 'route#index'"

remove_file "app/views/route/index.html.erb", force: true
copy_file "#{__dir__}/index.html.erb", "app/views/route/index.html.erb"

# --------------------------------------------------------------------------
# 2.6: Insert needed tags in application.html.erb
# --------------------------------------------------------------------------
insert_into_file "app/views/layouts/application.html.erb",
  after: "<%= csrf_meta_tags %>\n" do
    <<~ERB
      <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
      <%= vite_client_tag %>
      <%= vite_javascript_tag 'application' %>
    ERB
  end

# --------------------------------------------------------------------------
# 2.7: shadcn initialization
# --------------------------------------------------------------------------
# run "npx shadcn@latest init"
copy_file "#{__dir__}/components.json", "components.json"
copy_file "#{__dir__}/utils.ts", "app/javascript/lib/utils.ts"
remove_file "tailwind.config.js"
copy_file "#{__dir__}/postcss.config.mjs", "postcss.config.mjs"
copy_file "#{__dir__}/tailwind.config.js", "tailwind.config.js"
# --------------------------------------------------------------------------
# 2.8  setup telemetry
# --------------------------------------------------------------------------
template "#{__dir__}/opentelemetry.rb.tt", "config/initializers/opentelemetry.rb"
insert_into_file "config/routes.rb",
  before: "  get \"up\" => \"rails/health#show\", as: :rails_health_check\n" do
     "  mount Yabeda::Prometheus::Exporter, at: \"/metrics\"\n"
  end


# --------------------------------------------------------------------------
# 2.9: Done!
# --------------------------------------------------------------------------
say "=== Setup Complete ===", :green
say "You can now run: bin/rails server", :yellow
say "Visit http://localhost:3000 to see the example turbo-mounted React component.", :yellow
