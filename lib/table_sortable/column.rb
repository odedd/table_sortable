module TableSortable
  class Column

    attr_reader :name, :label, :filter, :sorter, :template, :placeholder, :content, :translation_key, :options, :template_path, :includes, :scope
    attr_writer :visible

    def initialize(col_name, *options)

      options = options.extract_options!
      value = options[:value] || col_name
      content = options[:content] || value
      translation_key = options[:translation_key]
      template_path = options[:template_path]
      label = options[:label] || (options[:label] == false ? '' : I18n.translate("table_sortable.#{"#{translation_key}." if translation_key }#{col_name.to_s}", :default => col_name.to_s).titleize)
      placeholder = options[:placeholder] || (options[:placeholder] == false ? nil : label)
      template = options[:template] || col_name
      column_options = options[:options] || {}
      includes = options[:includes] || []
      scope = options[:scope]
      visible = options[:visible].nil? ? true : options[:visible]

      @name = col_name.to_sym
      @value = value.respond_to?(:call) ? value : -> (record) { record.send(value) }
      @content = content.respond_to?(:call) ? content : -> (record) { record.send(content) }
      @label = label
      @placeholder = placeholder
      @template = template
      @template_path = template_path
      @translation_key = translation_key
      @visible = visible
      @scope = scope
      @includes = [includes].flatten.map{|as| as.is_a?(Hash) ? as : {as => []}}

      @options = column_options
      @filter = TableSortable::Column::Filter.new(options.merge(:column => self) )
      @sorter = TableSortable::Column::Sorter.new(options.merge(:column => self) )

    end

    def value(record)
      record.instance_eval(&@value) unless @value.nil?
    end

    def content(record)
      record.instance_eval(&@content) unless @content.nil?
    end

    def visible?
      @visible
    end

  end

end