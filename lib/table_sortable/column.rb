module TableSortable
  class Column

    attr_reader :name, :label, :filter, :sorter, :template, :placeholder, :content, :translation_key

    def initialize(col_name, *options)

      options = options.extract_options!
      value = options[:value] || col_name
      content = options[:content] || value
      translation_key = options[:translation_key]
      label = options[:label] || (options[:label] == false ? '' : I18n.translate("table_sortable.#{"#{translation_key}." if translation_key }#{col_name.to_s}", :default => col_name.to_s).titleize)
      placeholder = options[:placeholder] || (options[:placeholder] == false ? nil : label)
      # priority = options[:priority]
      template = options[:template] || col_name

      # filter_defaultAttrib (data-value)
      # data-sorter (=false?)

      @name = col_name
      @value = value.respond_to?(:call) ? value : -> (record) { record.send(value) }
      @content = content.respond_to?(:call) ? content : -> (record) { record.send(content) }
      @label = label
      @placeholder = placeholder
      # @sort_priority = sort_priority
      @template = template
      @filter = TableSortable::Column::Filter.new(options.merge(:column => self) )
      @sorter = TableSortable::Column::Sorter.new(options.merge(:column => self) )

    end

    def value(record)
      record.instance_eval(&@value) unless @value.nil?
    end

    def content(record)
      record.instance_eval(&@content) unless @content.nil?
    end

  end

end