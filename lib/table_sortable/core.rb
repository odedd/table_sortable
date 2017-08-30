require 'table_sortable/columns'

module TableSortable
  module Core
    extend ActiveSupport::Concern

    def define_columns(*args)
      options = args.extract_options!
      column_offset = options[:offset] || 0
      translation_key = options[:translation_key]
      template_path = options[:template_path]
      columns   = args
      define_translation_key translation_key
      define_template_path template_path
      define_column_offset column_offset
      columns.each do |column|
        define_column column, translation_key: translation_key
      end
    end

    def define_column(col_name, *options)
      options = default_column_options.merge(options.extract_options!)
      @columns.add(col_name, options.merge(controller: self))
    end

    def define_column_order(*order)
      @column_order = order
    end

    def define_column_offset(offset)
      @column_offset = offset
    end

    def define_translation_key(key)
      @translation_key = key
    end

    def define_template_path(path)
      @template_path = path.blank? ? nil : File.join(path, "")
    end

    def columns
      all_columns.select{|c| c.visible?}
    end

    def all_columns
      @all_columns ||= @columns.sort_by(column_order)
    end

    # private

    def default_column_options
      {translation_key: @translation_key, template_path: @template_path}
    end

    def filter_and_sort(scope, params = nil)
      populate_params(params)
      resolved_scope = scope
      actions = [->(records) { records }]
      ordered_actions(resolved_scope).reverse.each_with_index do |action, i|
        actions << ->(records) { action.used? ? (actions[i].call(action.run(records))) : actions[i].call(records) }
      end
      scope = actions.last.call(resolved_scope)
      if @query_params.page
        scope = Result.new(scope, @query_params.page, @query_params.page_size)
      end

      scope
    end

    def initialize_table_sortable
      @columns = TableSortable::Columns.new
      define_column_offset 0
    end

    def ordered_actions(record = nil)
      filter_actions =  columns.map{|col| col.filter }
      sort_actions =    columns.map{|col| col.sorter }
      (filter_actions+sort_actions).sort{ |a,b| (a.method(record) && b.method(record)) ? (a.method(record) <=> b.method(record)) : b.method(record) ? 1 : -1 }
    end

    def populate_params(params = nil)
      @query_params = QueryParams.new(params || self.params, columns, column_offset)
    end

    public

    attr_reader :column_order, :column_offset, :translation_key, :template_path
    # attr_accessor :params if defined?(self.class.params)

  end
end