module TableSortableHelper

  def table_sortable_pager
    render 'table_sortable/pager'
  end

  def table_sortable_headers
    render 'table_sortable/headers'
  end

  def table_sortable_columns(record)
    render 'table_sortable/columns', record: record
  end

end