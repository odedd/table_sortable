module TableSortable
  class QueryParams

    attr_reader :page, :page_size
    def initialize(params, columns)
      @page = params[PAGE].to_i
      @page_size = params[PAGESIZE].to_i

      # reset column filters and sorters
      columns.each do |col|
        col.filter.query = params[FCOL] ? params[FCOL][columns.find_index(col).to_s] : nil
        col.sorter.sort_order = params[SCOL] && params[SCOL][columns.find_index(col).to_s] ? ((params[SCOL][columns.find_index(col).to_s] == SORT_ASC) ? :asc : :desc) : nil
      end
    end
  end
end