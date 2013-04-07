
module ArIdeyabox
  # In model just add this line
  # has_not_this :person, through: :professions_people, order: :title, by: :title, group_by: {play: :title}
  # :order and :by - optionally
  # :group_by is for group selectors, if you want grouping roles by play titles, just add group_by: {play: :title}
  
  def first_el_tryer(object, by)
    if by.class == Hash
      object.try(by.keys[0]).try(by.values[0])
    else
      object.try(by)
    end
  end

  def has_not_this(model_name, *args)
    options = args.extract_options!
    join_model = options[:through].to_s.singularize.camelize
    self_id_sym = "#{self.to_s.underscore}_id".to_sym
    array_first_el = options[:by] ? options[:by] : :title
    group_by = options[:group_by]
    includes = options[:includes]
    model_name_id = "#{model_name}_id"

    define_singleton_method("has_not_this_#{model_name}") do |ids|
      excluded_ids = join_model.constantize.where(model_name_id.to_sym => ids).collect(&self_id_sym)
      output = self.where{id << excluded_ids}
      output = output.includes(includes) if includes
      output = output.order(options[:order]) if options[:order]
      if group_by
        output = output.group_by{|a| first_el_tryer(a, group_by)} 
        output.delete(nil)
        output.each do |key, value|
          array = []
          value.each do |el|
            array << [first_el_tryer(el, array_first_el), el.id]
          end
          output[key] = array
        end
        # output.to_a.sort
      else
        output.collect{|p| [first_el_tryer(p, array_first_el), p.id]}
      end
    end
  end
  
  # Original method for one model looks like this
  # def self.has_not_this_person(person_id)
  #   excluded_ids = ProfessionsPerson.where(person_id: person_id).collect(&:profession_id)
  #   self.where{id << excluded_ids}.order(:title).collect{|p| [p.title, p.id]}
  # end
end

ActiveSupport.on_load :active_record do
  extend ArIdeyabox
end