class ActiveAdmin::Filters::FormBuilder
  def default_input_type(method, options = {})
    if column = column_for(method)
      # p method, column.type.name.downcase
      return :select if column.class.name == "Mongoid::Fields::ForeignKey"

      case column.type.name.downcase.to_sym
      when :date, :datetime, :time
        return :date_range
      when :string, :text, :object
        return :string
      when :integer
        return :numeric
      when :float, :decimal
        return :numeric
      end
    elsif is_association?(method)
      return :select
    else # dirty but allows to create filters for hashes
      return :string
    end
  end

  def is_association?(method)
    @object.klass.associations.to_a.map(&:first).include?(method.to_s)
  end

  def column_for(method)
    @object.klass.fields[method.to_s] if @object.klass.respond_to?(:fields)
  end

  def reflection_for(method)
    @object.klass.reflect_on_association(method) if @object.klass.respond_to?(:reflect_on_association)
  end
end
