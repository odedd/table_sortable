
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
        column_offset = options[:offset] || 0
        columns   = args
        before_action(options) do
          columns.each do |column|
            define_column column
          end
          self.column_offset = column_offset
        end
      end

      def define_column(*args)
        before_action do
          define_column *args
        end
      end
    end

    def define_column(col_name, *options)
      options = options.extract_options!
      @columns.add(col_name, options)
    end

    private

    def filter_and_sort(scope, params = nil)
      populate_params(params)

      actions = [->(records) { records }]
      ordered_actions.reverse.each_with_index do |action, i|
        actions << ->(records) { action.used? ? actions[i].call(action.run(records)) : actions[i].call(records) }
      end
      scope = actions.last.call(scope)
      if @query_params.page
        scope = Result.new(scope, @query_params.page, @query_params.page_size)
      end

      scope
    end

    def initialize_table_sortable
      @columns = TableSortable::Columns.new
      self.column_offset = 0
    end

    def columns
      @columns.sort_by(display_order)
    end

    def ordered_actions
      filter_actions =  @columns.map{|col| col.filter }
      sort_actions =    @columns.map{|col| col.sorter }
      (filter_actions+sort_actions).sort{ |a,b| (a.method && b.method) ? (b.method <=> a.method) : a.method ? 1 : -1 }
    end

    def populate_params(params = nil)
      @query_params = QueryParams.new(params || self.params, columns, column_offset)
    end

    public

    attr_writer :filter_order, :sort_order
    attr_accessor :display_order, :column_offset

  end
end