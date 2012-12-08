#encoding:utf-8
require 'rails/generators'
require 'rails/generators/generated_attribute'

module Ideyabox
  module Generators
    class CropGenerator < ::Rails::Generators::Base
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

      def updating_models
        inject_into_file "app/models/#{resource_name}.rb", " :crop_x, :crop_y, :crop_w, :crop_h,", :after => "  attr_accessible"
        inject_into_file "app/models/#{resource_name}.rb", "\n  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h\n  after_update :crop_image\n  def crop_image\n    image.recreate_versions! if crop_x.present?\n  end\n", :after => "class #{@model_name.demodulize} < ActiveRecord::Base"
        
      end

      def updating_uploader
        inject_into_file "app/uploaders/#{resource_name}_uploader.rb", "\n  
  version :large do
    process :resize_to_limit => [500, 500]
  end

  version :crop do
    process :crop
    resize_to_fill(300, 200)
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(500, 500)
        manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop(\"\#{w}x\#{h}+\#{x}+\#{y}\")
        img
      end
    end
  end
        \n", :after => "process :resize_to_fill => [160, 100]\n  end"

      end

      def updating_edit_view
        inject_into_file "app/views/admin/#{plural_resource_name}/edit.html.haml", "(:large), :id=>'cropbox'\n          = render 'crop', :#{resource_name} => @#{resource_name}\n", :after => "          = image_tag @#{resource_name}.image_url"

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

      def parent_name
        resource_name.split("_").first
      end

      def plural_parent_name
        parent_name.pluralize
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
          "_crop.html.haml"            => "app/views/admin/#{@controller_file_path}/_crop.html.#{ext}",
        }

        selected_views = views
        options.engine == generate_erb(selected_views)
      end

      def generate_erb(views)
        views.each do |template_name, output_path|
          template template_name, output_path
        end
      end

      def ext
        :haml
      end


      def add_resource_route
        resources_string = "\n    resources :#{plural_resource_name} do\n"
        sort_string = "      post \"sort\", :on => :collection\n"
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

        inject_into_file "config/routes.rb", "\n      resources :#{plural_resource_name}\n", :after => "\n    resources :#{plural_parent_name} do"

        inject_into_file "config/routes.rb", " do\n      resources :#{plural_resource_name}\n    end", :after => "\n    resources :#{plural_parent_name}\n"
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
