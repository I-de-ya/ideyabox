#coding: utf-8
class Admin::<%= linking_model_name.pluralize -%>Controller < Admin::ApplicationController

<%- if column_names.include?("visible") -%>
  def toggleshow
    @<%= linking_resource_name %> = <%= @linking_linking_model_name -%>.find(params[:id])
    @<%= linking_resource_name %>.toggle(:visible)
    @<%= linking_resource_name %>.save
    render :nothing => true
  end
<%- end -%><%- if column_names.include?("position") -%>
  def sort
    params[:<%= linking_resource_name %>].each_with_index do |id, idx|
      @<%= linking_resource_name %> = <%= linking_linking_model_name -%>.find(id)
      @<%= linking_resource_name %>.position = idx
      @<%= linking_resource_name %>.save
    end
    render :nothing => true
  end
  <%- end -%>
  
  def edit
    @<%= linking_resource_name %> = <%= linking_model_name -%>.find(params[:id])
  end
  
  def create
    @<%= linking_resource_name %> = <%= linking_model_name %>.create(params[:<%= linking_resource_name %>])
  end

  def update
    @<%= linking_resource_name %> = <%= linking_model_name -%>.find(params[:id])
    if @<%= linking_resource_name %>.update_attributes(params[:<%= linking_resource_name %>])
      redirect_to [:edit, :admin, @<%= linking_resource_name %>.<%= resource_name %>], :notice => "#{<%= linking_model_name %>.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @<%= linking_resource_name %> = <%= linking_model_name -%>.find(params[:id])
    @<%= linking_resource_name %>.destroy
  end

end