#coding: utf-8
class Admin::<%= linking_model_name.pluralize -%>Controller < Admin::ApplicationController
<%- if linking_columns.include?("visible") -%>
  def toggleshow
    @<%= linking_resource_name %> = <%= linking_model_name -%>.find(params[:id])
    @<%= linking_resource_name %>.toggle(:visible)
    @<%= linking_resource_name %>.save
    render :nothing => true
  end
<%- end -%><%- if linking_columns.include?("position") -%>
  def sort
    params[:<%= linking_resource_name %>].each_with_index do |id, idx|
      @<%= linking_resource_name %> = <%= linking_model_name -%>.find(id)
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

    @<%=resource_name%> = @<%= linking_resource_name %>.<%=resource_name%>
    @<%=plural_child_name%> = <%=child_model%>.has_not_this_<%=resource_name%>(@<%=resource_name%>.id)

    #@<%=child_name%> = @<%= linking_resource_name %>.<%=child_name%>
    #@<%=plural_resource_name%> = <%=model_name%>.has_not_this_<%=child_name%>(@<%=child_name%>.id)
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

    @<%=resource_name%> = @<%= linking_resource_name %>.<%=resource_name%>
    @<%=plural_child_name%> = <%=child_model%>.has_not_this_<%=resource_name%>(@<%=resource_name%>.id)

    #@<%=child_name%> = @<%= linking_resource_name %>.<%=child_name%>
    #@<%=plural_resource_name%> = <%=model_name%>.has_not_this_<%=child_name%>(@<%=child_name%>.id)    
  end
end