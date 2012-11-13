#coding: utf-8
class Admin::<%= plural_resource_name.capitalize -%>Controller < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
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
  def index
    @<%= plural_resource_name %> = <%= resource_name.capitalize -%>.order(sort_column + " " + sort_direction)
  end
  
  def new
    @<%= resource_name %> = <%= resource_name.capitalize -%>.new
    render 'edit'
  end
  
  def edit
    @<%= resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
  end
  
  def create
    @<%= resource_name %> = <%= resource_name.capitalize -%>.new(params[:<%= resource_name %>])
    if @<%= resource_name %>.save
      redirect_to admin_<%= plural_resource_name %>_path, :notice => "<%= resource_name %> добавлен."
    else
      render 'edit'
    end
  end

  def update
    @<%= resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
    if @<%= resource_name %>.update_attributes(params[:<%= resource_name %>])
      redirect_to admin_<%= plural_resource_name %>_path, :notice => "<%= resource_name %> отредактирован."
    else
      render 'edit'
    end
  end
  
  def destroy
    @<%= resource_name %> = <%= resource_name.capitalize -%>.find(params[:id])
    @<%= resource_name %>.destroy
    redirect_to admin_<%= plural_resource_name %>_path, :alert => "<%= resource_name %> удален."
  end

  private

  def sort_column
    <%= resource_name.capitalize -%>.column_names.include?(params[:sort]) ? params[:sort] : <%= column_names.include?("position") ? "\'position\'" : "\'created_at\'" %>
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end