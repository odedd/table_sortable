# lib/my_gem/railtie.rb
require 'table_sortable/view_helpers'
module TableSortable
  class Railtie < Rails::Railtie
    initializer 'table_sortable.view_helpers' do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end