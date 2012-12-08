#coding: utf-8
class Admin::<%= @model_name.demodulize.pluralize -%>Controller < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
<%- if column_names.include?("visible") -%>
  def toggleshow
    @<%= plural_resource_name %> = <%= @model_name.demodulize -%>.find(params[:id])
    @<%= plural_resource_name %>.toggle(:visible)
    @<%= plural_resource_name %>.save
    render :nothing => true
  end
<%- end -%><%- if column_names.include?("position") -%>
  def sort

    <%= @model_name.demodulize %>.sort(params[:list])

    render :nothing => true
  end
  <%- end -%>
  def index
    @<%= plural_resource_name %> = <%= @model_name.demodulize -%>.order(sort_column + " " + sort_direction)
  end
  
  def new
    @<%= resource_name %> = <%= @model_name.demodulize -%>.new
    render 'edit'
  end
  
  def edit
    @<%= resource_name %> = <%= @model_name.demodulize -%>.find(params[:id])
  end
  
  def create
    @<%= resource_name %> = <%= @model_name.demodulize -%>.new(params[:<%= resource_name %>])
    if @<%= resource_name %>.save
      redirect_to admin_<%= plural_resource_name %>_path, :notice => "#{<%= @model_name.demodulize %>.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @<%= resource_name %> = <%= @model_name.demodulize -%>.find(params[:id])
    if @<%= resource_name %>.update_attributes(params[:<%= resource_name %>])
      redirect_to admin_<%= plural_resource_name %>_path, :notice => "#{<%= @model_name.demodulize %>.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @<%= resource_name %> = <%= @model_name.demodulize -%>.find(params[:id])
    @<%= resource_name %>.destroy
    redirect_to admin_<%= plural_resource_name %>_path, :alert => "#{<%= @model_name.demodulize %>.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def sort_column
    <%= @model_name.demodulize -%>.column_names.include?(params[:sort]) ? params[:sort] : <%= column_names.include?("position") ? "\'position\'" : "\'created_at\'" %>
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end