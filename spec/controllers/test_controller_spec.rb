require 'action_controller'


module Test
  class Controller < ActionController::Base

    include TableSortable::Controller

    def index
    end
  end
end

describe Test::Controller, type: :controller do

  let(:controller) { Test::Controller.new }

  it { has_before_filters(:initialize_table_sortable) }

end