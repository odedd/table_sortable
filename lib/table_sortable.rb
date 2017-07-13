require 'active_support/concern'

module TableSortable

  FCOL = 'fcol'
  SCOL = 'scol'
  SORT_ASC = '0'
  SORT_DESC = '1'
  PAGE = 'page'
  PAGESIZE = 'pagesize'

  class Engine < Rails::Engine; end if defined?(Rails)

end

class TableSortableError < StandardError; end

require 'table_sortable/concerns/proc'
require 'table_sortable/column/sorter'
require 'table_sortable/column/filter'
require 'table_sortable/column'
require 'table_sortable/result'
require 'table_sortable/version'
require 'table_sortable/core'
require 'table_sortable/controller'
require 'table_sortable/query_params'
require 'table_sortable/railtie' if defined?(Rails)