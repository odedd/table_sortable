module Test
  class Controller < ActionController::Base
    def index
    end
  end
end

describe Test::Controller, type: :controller do

  let(:controller) { Test::Controller.new }

  it { has_before_filters(:initialize_table_sortable) }

end