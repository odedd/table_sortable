require 'rails/engine'
require 'active_support/concern'
require 'action_controller'
require 'kaminari'
require 'kaminari/models/array_extension'

module TableSortable

  FCOL = 'fcol'
  SCOL = 'scol'
  SORT_ASC = '0'
  SORT_DESC = '1'

  class Engine < Rails::Engine; end

end


class TableSortableError < StandardError; end

require 'table_sortable/concerns/proc'
require 'table_sortable/column/sorter'
require 'table_sortable/column/filter'
require 'table_sortable/column'
require 'table_sortable/columns'
require 'table_sortable/version'
require 'table_sortable/controller'