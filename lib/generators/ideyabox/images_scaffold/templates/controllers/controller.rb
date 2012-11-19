#coding: utf-8
class Admin::<%= @model_name.demodulize.pluralize -%>Controller < Admin::ApplicationController

<%- if column_names.include?("visible") -%>
  def toggleshow
    @<%= plural_resource_name %> = <%= @model_name.demodulize -%>.find(params[:id])
    @<%= plural_resource_name %>.toggle(:visible)
    @<%= plural_resource_name %>.save
    render :nothing => true
  end
<%- end -%><%- if column_names.include?("position") -%>
  def sort
    params[:<%= resource_name %>].each_with_index do |id, idx|
      @<%= resource_name %> = <%= @model_name.demodulize -%>.find(id)
      @<%= resource_name %>.position = idx
      @<%= resource_name %>.save
    end
    render :nothing => true
  end
  <%- end -%>
  
  def edit
    @<%= resource_name %> = <%= @model_name.demodulize -%>.find(params[:id])
  end
  
  def create
    @<%= parent_name %> = <%= parent_name.capitalize -%>.find(params[:<%= parent_name %>_id])
    @<%= resource_name %> = @<%= parent_name %>.<%= plural_resource_name %>.create(params[:<%= resource_name %>])
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
  end

end