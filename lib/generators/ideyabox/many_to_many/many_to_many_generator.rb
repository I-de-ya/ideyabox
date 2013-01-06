require 'rails/generators'
require 'rails/generators/generated_attribute'

module Ideyabox
  module Generators
    class ManyToManyGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :controller_path,    :type => :string
      argument :child_controller_path,    :type => :string
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

      # def add_locale_templates
      #   add_to_locales
      # end

      def add_resources_and_root
        add_resource_route
      end

      def updating_views
        update_views
      end

      def updating_controllers
        update_controllers
      end

      def updating_models
        update_model
      end

      protected

      def initialize_views_variables
        @base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(controller_path)

        @child_contoller_class_nesting = child_controller_path

        @controller_routing_path = @controller_file_path.gsub(/\//, '_')
        @model_name = @controller_class_nesting + "::#{@base_name.singularize.camelize}" unless @model_name
        @model_name = @model_name.camelize

        @child_model_name = @child_contoller_class_nesting.singularize.camelize

      end

      def controller_routing_path
        @controller_routing_path
      end

      def singular_controller_routing_path
        @controller_routing_path.singularize
      end

      def model_name
        @model_name.demodulize
      end

      def plural_model_name
        @model_name.pluralize
      end

      #parent model
      def resource_name
        @model_name.demodulize.underscore
      end

      def plural_resource_name
        resource_name.pluralize
      end

      #child model
      def child_model
        @child_model_name
      end

      def child_name
        @child_model_name.demodulize.underscore
      end

      def plural_child_name
        child_name.pluralize
      end     

      #linking model
      def linking_model_name
        if ActiveRecord::Base.connection.table_exists? "#{child_name}_#{plural_resource_name}"
          "#{child_name}_#{plural_resource_name}".singularize.camelize
        elsif
          ActiveRecord::Base.connection.table_exists? "#{resource_name}_#{plural_child_name}"
          "#{resource_name}_#{plural_child_name}".singularize.camelize
        end       
      end

      def linking_resource_name
        linking_model_name.underscore
      end

      def plural_linking_resource_name
        linking_resource_name.pluralize
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
      
      def child_columns
        child_model.constantize.column_names
      end
      
      def linking_columns
        linking_model_name.constantize.column_names
      end

      def get_title
        if child_columns.include?("title")
          t = 'title'
        elsif child_columns.include?("name")
          t = 'name'
        elsif child_columns.include?("username")
          t = 'username'
        else
          t = 'id'
        end
        t
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
          "views/_form.html.#{ext}"            => "app/views/admin/#{plural_linking_resource_name}/_form.html.#{ext}",
          "views/_one_to_one.html.#{ext}"            => "app/views/admin/#{plural_linking_resource_name}/_#{linking_resource_name}.html.#{ext}",
          "views/destroy.js.erb"            => "app/views/admin/#{plural_linking_resource_name}/destroy.js.haml",
          "views/create.js.erb"            => "app/views/admin/#{plural_linking_resource_name}/create.js.haml",
          "views/_child.html.haml"            => "app/views/admin/#{plural_resource_name}/_#{plural_child_name}.html.haml",
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
        template "controllers/controller.rb", "app/controllers/admin/#{plural_linking_resource_name}_controller.rb"
      end

      def update_controllers
        inject_into_file "app/controllers/admin/#{plural_resource_name}_controller.rb", "\n    @#{plural_child_name} = #{child_model}.has_not_this_#{resource_name}(params[:id])", :after => "\n  def edit"
      end

      def update_model
        inject_into_file "app/models/#{resource_name}.rb", "\n  has_many :#{plural_child_name}, :through => :#{plural_linking_resource_name}\n  has_many :#{plural_linking_resource_name}\n
  # def self.has_not_this_#{child_name}(#{child_name}_id)
  #   h = Hash.new
  #   self.order(#{child_model.constantize.column_names.include?('title') ? '\'title\'' : 'created_at'}).each do |p|
  #     if p.#{plural_linking_resource_name}.where(:#{child_name}_id=>#{child_name}_id).length == 0
  #       h[\"\#{p.#{@model_name.constantize.column_names.include?('title') ? 'title' : 'id'}}\"] = p.id
  #     end
  #   end
  #   return h
  # end
        ", :after => "class #{model_name} < ActiveRecord::Base"

        inject_into_file "app/models/#{child_model}.rb", "\n  has_many :#{plural_resource_name}, :through => :#{plural_linking_resource_name}\n  has_many :#{plural_linking_resource_name}\n
  def self.has_not_this_#{resource_name}(#{resource_name}_id)
    h = Hash.new
    self.order('#{@model_name.constantize.column_names.include?(get_title.to_s) ? (get_title.to_s) : 'created_at'}').each do |p|
      if p.#{plural_linking_resource_name}.where(:#{resource_name}_id=>#{resource_name}_id).length == 0
        h[\"\#{p.#{get_title.to_s}}\"] = p.id
      end
    end
    return h
  end
        ", :after => "class #{child_model} < ActiveRecord::Base"

        inject_into_file "app/models/#{linking_resource_name}.rb", "\n  belongs_to :#{resource_name}\n  belongs_to :#{child_name}\n  validates :#{resource_name}_id, :#{child_name}_id, :presence => true", :after => "class #{linking_model_name} < ActiveRecord::Base" 
        if linking_columns.include?("position")
        inject_into_file "app/models/#{linking_resource_name}.rb", "\n
  before_create :set_position
  def set_position
    if self.#{resource_name}.#{plural_linking_resource_name}.length > 0 && self.#{resource_name}.#{plural_linking_resource_name}.order('position').last.position
      self.position = self.#{resource_name}.#{plural_linking_resource_name}.order('position').last.position + 1
    else
      self.position = 0
    end
  end
        ", :after => "class #{linking_model_name} < ActiveRecord::Base" 
        end
      end




      def update_views
        prepend_to_file "app/views/admin/#{plural_resource_name}/edit.html.haml", "
- content_for(:page_sidebar) do
  - unless @#{resource_name}.new_record?
    %h2 #{plural_child_name}
    .bordered_box 
      = render '#{plural_child_name}'
"
      end

      def add_resource_route
        resources_string = "\n    resources :#{plural_linking_resource_name} do\n"
        sort_string = "      post \"sort\", :on => :collection\n"
        toggleshow_string = "      get \"toggleshow\", :on => :member\n"
        
        if linking_columns.include?("visible") && linking_columns.include?("position")
          final_string = "#{resources_string}#{sort_string}#{toggleshow_string}    end\n"
        elsif linking_columns.include?("visible")
          final_string = "#{resources_string}#{toggleshow_string}    end\n"
        elsif linking_columns.include?("position")
          final_string = "#{resources_string}#{sort_string}    end\n"
        else
          final_string = "\n    resources :#{plural_linking_resource_name}\n"
        end

        inject_into_file "config/routes.rb", final_string, :after => "\n  namespace :admin do\n"
      end

      # def add_to_locales
      #   locales = [:ru, :en]
        
      #   attributes = column_names.collect {|column| "        #{column}: \"#{column}\"\n"}

      #   attributes_string = "      #{resource_name}:\n#{attributes.join}"

      #   locales.each do |locale|
      #     inject_into_file "config/locales/#{locale}.yml", "      #{resource_name}: \"#{resource_name}\"\n", :after => "models:\n"
      #     inject_into_file "config/locales/#{locale}.yml", attributes_string, :after => "attributes:\n"
      #   end
      # end




    end
  end
end
