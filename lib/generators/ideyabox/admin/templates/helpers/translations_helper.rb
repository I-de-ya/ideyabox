# encoding:utf-8
module TranslationsHelper
  def plural_name(resource)
    t "#{resource}.plural", default: resource.singularize.camelize.constantize.model_name.human
  end

  def accusative_case(resource)
    t "#{resource}.accusative", default: resource.singularize.camelize.constantize.model_name.human
  end

  def action_accusative(resource, action)
    t(action) + " " + accusative_case(resource)
  end
end