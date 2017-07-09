
module TableSortable
  module Controller

    extend ActiveSupport::Concern

    included do
      helper_method :columns
      prepend_before_action :initialize_table_sortable
    end

    module ClassMethods
      def define_columns(*args)
        options = args.extract_options!
        before_action do
          define_columns(options)
        end

      end

      def define_column(*args)
        before_action do
          define_column *args
        end
      end

      def define_column_order(order)
        before_action do
          define_column_order order
        end
      end

      def define_column_offset(offset)
        before_action do
          define_column_offset offset
        end
      end

      def define_translation_key(key)
        before_action do
          define_translation_key key
        end
      end

      def define_template_path(path)
        before_action do
          define_template_path path
        end
      end
    end

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
      @columns.sort_by(column_order)
    end

    private

    def default_column_options
      {translation_key: @translation_key, template_path: @template_path}
    end

    def filter_and_sort(scope, params = nil)
      populate_params(params)

      actions = [->(records) { records }]
      ordered_actions(scope.first).reverse.each_with_index do |action, i|
        actions << ->(records) { action.used? ? (actions[i].call(action.run(records))) : actions[i].call(records) }
      end
      scope = actions.last.call(scope) unless scope.blank?
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
      filter_actions =  @columns.map{|col| col.filter }
      sort_actions =    @columns.map{|col| col.sorter }
      (filter_actions+sort_actions).sort{ |a,b| (a.method(record) && b.method(record)) ? (a.method(record) <=> b.method(record)) : b.method(record) ? 1 : -1 }
    end

    def populate_params(params = nil)
      @query_params = QueryParams.new(params || self.params, columns, column_offset)
    end

    public

    attr_reader :column_order, :column_offset, :translation_key, :template_path

  end
end