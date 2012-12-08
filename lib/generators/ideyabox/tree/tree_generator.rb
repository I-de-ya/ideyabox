require 'rails/generators'
require 'rails/generators/generated_attribute'

module Ideyabox
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :controller_path,    :type => :string
      argument :model_name,         :type => :string, :required => false
      argument :layout,             :type => :string, :default => "application",
                                    :banner => "Specify application layout"

      def initialize(args, *options)
        super(args, *options)
        initialize_views_variables
      end

      def copy_views
        generate_views
      end

      def add_locale_templates
        add_to_locales
      end

      def add_resources_and_root
        add_resource_route
      end

      def updated_admin_layout
        add_to_launchbar_items
        add_to_topbar_items
      end

      def updating_models
        inject_into_file "app/models/#{resource_name}.rb", "\n
  has_ancestry :orphan_strategy => :rootify


  def self.sort(list)
 
    temp = {}
    list.each do |key, value|
      if temp[value]
        temp[value] << key
      else
        temp[value] = [key]
      end
    end

    temp.each do |parent, cats|
      i = 1
      if parent == 'root' || parent == 'null'
        p = ''
      else
        p = Menu.find(parent).id
      end
      cats.each do |cat|
        c = Menu.find(cat)
        c.parent_id = p
        c.position = i
        c.save
        i += 1
      end
    end
  end

        ", :after => "class #{@model_name.demodulize} < ActiveRecord::Base"   

      end

      protected

      def initialize_views_variables
        @base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(controller_path)
        @controller_routing_path = @controller_file_path.gsub(/\//, '_')
        @model_name = @controller_class_nesting + "::#{@base_name.singularize.camelize}" unless @model_name
        @model_name = @model_name.camelize
      end

      def controller_routing_path
        @controller_routing_path
      end

      def singular_controller_routing_path
        @controller_routing_path.singularize
      end

      def model_name
        @model_name
      end

      def plural_model_name
        @model_name.pluralize
      end

      def resource_name
        @model_name.demodulize.underscore
      end

      def plural_resource_name
        resource_name.pluralize
      end

      def sort_priority(column_name)
        case column_name
        when "position" then 1
        when "visible" then 2
        when "name" then 3
        when "title" then 3
        else 5
        end
      end

      def columns
        begin
          excluded_column_names = %w[id created_at updated_at]
          @model_name.constantize.columns.reject{|c| excluded_column_names.include?(c.name) || c.name.index("_id") }.sort{|a, b| sort_priority(a.name) <=> sort_priority(b.name)}.collect{|c| ::Rails::Generators::GeneratedAttribute.new(c.name, c.type)}
        rescue NoMethodError
          @model_name.constantize.fields.collect{|c| c[1]}.reject{|c| excluded_column_names.include?(c.name) || c.name.index("_id") }.collect{|c| ::Rails::Generators::GeneratedAttribute.new(c.name, c.type.to_s)}
        end
      end
      
      def column_names
        @model_name.constantize.column_names
      end

      def extract_modules(name)
        modules = name.include?('/') ? name.split('/') : name.split('::')
        name    = modules.pop
        path    = modules.map { |m| m.underscore }
        file_path = (path + [name.underscore]).join('/')
        nesting = modules.map { |m| m.camelize }.join('::')
        [name, path, file_path, nesting, modules.size]
      end

      def generate_views
        views = {
          "index.html.#{ext}"           => "app/views/admin/#{@controller_file_path}/index.html.#{ext}",
          "edit.html.#{ext}"            => "app/views/admin/#{@controller_file_path}/edit.html.#{ext}",
          "index.js.#{ext}"             => "app/views/admin/#{@controller_file_path}/index.js.#{ext}",
          "_index.html.#{ext}"          => "app/views/admin/#{@controller_file_path}/_index.html.#{ext}",
          "_sort_buttons.html.#{ext}"   => "app/views/admin/#{@controller_file_path}/_sort_buttons.html.#{ext}"
        }
        views.delete("_sort_buttons.html.#{ext}") unless column_names.include?("position")
        selected_views = views
        options.engine == generate_erb(selected_views)
      end

      def generate_erb(views)
        views.each do |template_name, output_path|
          template template_name, output_path
        end
        generate_controller
      end

      def ext
        :haml
      end

      def generate_controller
        template "controllers/controller.rb", "app/controllers/admin/#{plural_resource_name}_controller.rb"
      end

      def add_resource_route
        resources_string = "\n    resources :#{plural_resource_name} do\n"
        sort_string = "      get \"sort\", :on => :collection\n"
        toggleshow_string = "      get \"toggleshow\", :on => :member\n"
        
        if column_names.include?("visible") && column_names.include?("position")
          final_string = "#{resources_string}#{sort_string}#{toggleshow_string}    end\n"
        elsif column_names.include?("visible")
          final_string = "#{resources_string}#{toggleshow_string}    end\n"
        elsif column_names.include?("position")
          final_string = "#{resources_string}#{sort_string}    end\n"
        else
          final_string = "\n    resources :#{plural_resource_name}\n"
        end

        inject_into_file "config/routes.rb", final_string, :after => "\n  namespace :admin do\n"
      end

      def add_to_launchbar_items
        final_string = "#{plural_resource_name} "

        inject_into_file "app/views/admin/shared/_launchbar.html.haml", final_string, :after => "- @active = :section if %w{"
      end

      def add_to_topbar_items
        final_string = "\n    %li{:class => \"\#\{\'active\' if c == \'#{plural_resource_name}\'}\"\}= link_to \'#{plural_resource_name}\', admin_#{plural_resource_name}_path"

        inject_into_file "app/views/admin/shared/_topbar.html.haml", final_string, :after => "-when :section"
      end

      def add_to_locales
        locales = [:ru, :en]
        
        attributes = column_names.collect {|column| "        #{column}: \"#{column}\"\n"}

        attributes_string = "      #{resource_name}:\n#{attributes.join}"

        locales.each do |locale|
          inject_into_file "config/locales/#{locale}.yml", "      #{resource_name}: \"#{resource_name}\"\n", :after => "models:\n"
          inject_into_file "config/locales/#{locale}.yml", attributes_string, :after => "attributes:\n"
        end
      end

    end
  end
end
