require 'rails/generators'
module Ideyabox
  module Generators
    class AdminGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_admin_layout
        directory "controllers/admin", "app/controllers/admin"
        directory "views/admin", "app/views/admin"
        directory "views/layouts", "app/views/layouts"
        copy_file "tasks/seeds.rb", "db/seeds.rb"
        copy_file "tasks/reset_db.rake", "lib/tasks/reset_db.rake"
      end

      def setup_routes
        route("namespace :admin do end")
      end
      
    end
  end
end