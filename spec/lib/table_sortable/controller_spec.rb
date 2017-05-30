describe TableSortable::Controller do

  let :controller do
    controller = ActionController::Base.new
    controller.class.include TableSortable::Controller
    controller.instance_eval('initialize_table_sortable')
    controller
  end
  let :populated_controller do
    controller.send(:define_column,
                    :column_with_sql_procs_a,
                    filter: -> (value) { where(column: value)},
                    sort: -> { order(:column)})
    controller.send(:define_column,
                    :column_with_array_procs,
                    filter: -> (value) { select{|record| record == value}},
                    sort: -> (col) { sort{ |a,b| col.value(a) <=> col.value(b) }})
    controller.send(:define_column,
                    :column_with_sql_procs_b,
                    filter: -> (value) { where(last_name: value)},
                    sort: -> { order(:column)})
    controller
  end

  context 'initialization' do
    it 'creates a columns collection' do
      expect(controller.instance_eval('@columns')).to be_a TableSortable::Columns
    end
  end

  context 'define_column' do
    it 'adds a new column at the end of the collection' do
      controller.send(:define_column, :name)
      controller.send(:define_column, :another_name)
      expect(controller.send(:columns).first.name).to eq :name
      expect(controller.send(:columns).last.name).to eq :another_name
    end
  end

  context 'filter_order' do
    it 'orders sql filters before array filters' do
      expect(populated_controller.send(:filter_order)).to eq [:column_with_sql_procs_a, :column_with_sql_procs_b, :column_with_array_procs]
    end
  end

  context 'sort_order' do
    it 'orders sql filters before array filters' do
      expect(populated_controller.send(:sort_order)).to eq [:column_with_sql_procs_a, :column_with_sql_procs_b, :column_with_array_procs]
    end
  end
end