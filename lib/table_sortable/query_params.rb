module TableSortable
  class QueryParams

    attr_reader :page, :page_size
    def initialize(params, columns, column_offset = 0)
      @page = params[PAGE] ? params[PAGE].to_i : nil
      @page_size = params[PAGESIZE].to_i

      # reset column filters and sorters
      columns.each do |col|
        col_index = (columns.find_index(col) + column_offset)
        col.filter.query = params[FCOL] ? params[FCOL][col_index.to_s] : nil
        col.sorter.sort_order = params[SCOL] && params[SCOL][col_index.to_s] ? ((params[SCOL][col_index.to_s] == SORT_ASC) ? :asc : :desc) : nil
      end
    end
  end
end