require 'rails/generators'
module Ideyabox
  module Generators
    class AdminGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_admin_layout
        directory "controllers", "app/controllers"
        directory "views/admin", "app/views/admin"
        directory "views/layouts", "app/views/layouts"
        directory "locales", "config/locales"
        copy_file "assets/admin.scss.erb", "app/assets/stylesheets/admin.scss.erb"
        copy_file "assets/admin.js", "app/assets/javascripts/admin.js"
        copy_file "tasks/seeds.rb", "db/seeds.rb"
      end

      def setup_routes
        route("namespace :admin do\n\n  end")
      end

      def add_gems_for_admin_workflow
        gem 'devise'
        gem 'kaminari'
        gem 'russian'
        gem 'redactor-rails'
        gem 'haml'
        gem 'ancestry'
        gem 'carrierwave'
        gem 'mini_magick'
        gem 'squeel'
        gem 'sexy_validators'
        gem_group :development do
          gem 'haml-rails'
        end
        gem_group :assets do
          gem "jquery-fileupload-rails"
        end
        inside Rails.root do
          run "bundle install"
        end

      end

      def rake_tasks_for_admin
        generate("devise:install")
        generate("devise", "User")
        generate("redactor:install")
        # Next 4 lines for test purposes only
        # generate("scaffold", "Ghost name:string desc:text position:integer visible:boolean --skip-stylesheets")
        # generate("scaffold", "Guest name:string desc:text visible:boolean --skip-stylesheets")
        # generate("scaffold", "Host name:string desc:text position:integer --skip-stylesheets")
        # generate("scaffold", "Post name:string desc:text --skip-stylesheets")
        rake("db:migrate")
        rake("db:seed")
      end

      def initialize_git_repo
        git :init
        git :add => "."
        git :add => "-u"
        git :commit => "-m \"First commit!\""
      end
      
    end
  end
end