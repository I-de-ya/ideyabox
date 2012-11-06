#coding: utf-8
class Admin::<%= plural_resource_name.capitalize -%>Controller < Admin::ApplicationController
  
  def index
    @<%= plural_resource_name %> = <%= resource_name.capitalize -%>.all
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
  
end