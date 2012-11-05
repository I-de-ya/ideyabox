require 'rails/generators'
module Ideyabox
  module Generators
    class AssetsGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def add_assets_to_admin_layout
        directory "assets/stylesheets", "app/assets/stylesheets"
        directory "assets/images", "app/assets/images"
        directory "assets/javascripts", "app/assets/javascripts/"
      end
      
    end
  end
end