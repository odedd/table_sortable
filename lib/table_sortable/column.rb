module TableSortable
  class Column

    attr_reader :name, :label, :filter, :sorter, :template, :placeholder

    def initialize(col_name, *options)

      options = options.extract_options!
      value = options[:value] || col_name
      label = options[:label] || (options[:label] == false ? '' : col_name.to_s.titleize)
      placeholder = options[:placeholder] || (options[:placeholder] == false ? false : label)
      template = options[:template] || col_name

      @name = col_name
      @value = value.is_a?(Proc) ? value : -> (record) { record.send(value) }
      @label = label
      @placeholder = placeholder
      @template = template
      @filter = TableSortable::Column::Filter.new(options.merge(:column_name => @name) )
      @sorter = TableSortable::Column::Sorter.new(options.merge(:column_name => @name) )

    end

    def value(record)
      record.instance_eval(&@value) unless @value.nil?
    end

  end

end