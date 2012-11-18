#coding: utf-8
class Admin::<%= plural_resource_name.capitalize -%>Controller < Admin::ApplicationController

<%- if column_names.include?("visible") -%>
  def toggleshow
    @<%= plural_resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
    @<%= plural_resource_name %>.toggle(:visible)
    @<%= plural_resource_name %>.save
    render :nothing => true
  end
<%- end -%><%- if column_names.include?("position") -%>
  def sort
    params[:<%= resource_name %>].each_with_index do |id, idx|
      @<%= resource_name %> = <%= resource_name.capitalize -%>.find(id)
      @<%= resource_name %>.position = idx
      @<%= resource_name %>.save
    end
    render :nothing => true
  end
  <%- end -%>
  
  def edit
    @<%= resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
  end
  
  def create
    @<%= parent_name %> = <%= parent_name.capitalize -%>.new(params[:<%= parent_name %>_id])
    @<%= resource_name %> = @<%= parent_name %>.@<%= plural_resource_name %>.create(params[:<%= resource_name %>])
  end

  def update
    @<%= resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
    if @<%= resource_name %>.update_attributes(params[:<%= resource_name %>])
      redirect_to admin_<%= plural_resource_name %>_path, :notice => "#{<%= resource_name.capitalize %>.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @<%= resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
    @<%= resource_name %>.destroy
  end

end