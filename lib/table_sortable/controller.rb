
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

    def filter_and_sort(scope)
      cols = @columns.sort_by(display_order)

      page = params[:page]
      page_size = params[:pagesize]
      sort_by_col_data = params[SCOL] ? params[SCOL].keys.first : column_offset
      sort_order = params[SCOL] ? params[SCOL].values.first : SORT_ASC

      sort_column = cols.at(sort_by_col_data.to_i - column_offset)
      sort_proc = ->(records) { records.instance_exec(sort_column, &sort_column.sorter.proc)}
      ordered_sort_proc = ->(records) {sort_order == SORT_ASC ? sort_proc.call(records) : sort_proc.call(records).reverse}

      filters = [->(records) { ordered_sort_proc.call(records) }]

      # a filter exists
      if params[FCOL]
        @columns.sort_by(filter_order.reverse).each_with_index do |col, i|
          column_index = cols.index(col) + column_offset
          filter_value = params[FCOL][column_index.to_s]
          filters << ->(records){ filter_value.nil? ? filters[i].call(records) : filters[i].call(records.instance_exec(filter_value, col, &col.filter.proc)) }
        end
      end
      scope = filters.last.call(scope)
      if page
        scope = Kaminari.paginate_array(scope)
        scope = scope.page(page.to_i + 1).per(page_size)
      end
      scope
    end

    def initialize_table_sortable

      @columns ||= TableSortable::Columns.new
      self.column_offset = 0

    end

    def columns(record = nil)
      @columns.sort_by(display_order)
    end

    def filter_order
      @filter_order || @columns.sort{ |a,b| a.filter.method && b.filter.method ? b.filter.method <=> a.filter.method : a.filter.method ? 1 : -1 }.compact.map{|col| col.name}
    end

    def sort_order
      @sort_order || @columns.sort{ |a,b| a.sorter.method && b.sorter.method ? b.sorter.method <=> a.sorter.method : a.filter.method ? 1 : -1 }.compact.map{|col| col.name}
    end

    public

    attr_writer :filter_order, :sort_order
    attr_accessor :display_order, :column_offset

  end
end