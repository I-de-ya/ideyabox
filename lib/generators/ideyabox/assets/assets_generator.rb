require 'rails/generators'
module Ideyabox
  module Generators
    class AssetsGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../../../../../app', __FILE__)

      def add_assets_to_admin_layout
        directory "helpers", "app/helpers"
        directory "assets/stylesheets", "app/assets/stylesheets"
        directory "assets/images", "app/assets/images"
        directory "assets/javascripts", "app/assets/javascripts/"
        copy_file "tasks/reset_db.rake", "lib/tasks/reset_db.rake"
      end
      
    end
  end
end