#!/bin/bash

set -o pipefail

rails new testing_env
cd testing_env
echo 'gem "vite_react", git: "git@github.com:lsproule/vite_react.git", branch: "removing_turbo_mount"' >> Gemfile
bundle install
./bin/rails  vite_react:install 
