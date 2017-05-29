describe TableSortable::Controller do

  let(:controller) { ActionController::Base.new }

  context 'column' do

    it 'should create a columns collection on initialization' do
      controller.instance_eval('initialize_table_sortable')
      expect(controller.instance_eval('@columns')).to be_a TableSortable::Columns
    end

  end

end