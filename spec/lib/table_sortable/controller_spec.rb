describe TableSortable::Controller do

  let :controller do
    controller = ActionController::Base.new
    controller.class.include TableSortable::Controller
    controller.instance_eval('initialize_table_sortable')
    controller
  end
  let :controller_with_columns do

    controller.send(:define_column,
                    :first_name,
                    filter: -> (value) { where('UPPER(first_name) LIKE (?)', "%#{value.upcase}%") },
                    sort: -> (sort_order) { order(:first_name => sort_order) })

    controller.send(:define_column,
                    :last_name,
                    filter: -> (value) { select{|record| value.downcase.in? record.last_name.downcase }},
                    sort: -> (sort_order) { sort{ |a,b| (sort_order == :asc ? a : b).last_name <=> (sort_order == :asc ? b : a).last_name }})

    controller.send(:define_column,
                    :email,
                    filter: -> (value) { where('UPPER(email) LIKE (?)', "%#{value.upcase}%") },
                    sort: -> (sort_order) { order(:email => sort_order) })

    controller
  end

  before(:all) do
    create :user, first_name: 'Bob', last_name: 'Doe', email: 'misterbob@gmail.com'
    create :user, first_name: 'David', last_name: 'Copperfield', email: 'alphadavid@gmail.com'
    create :user, first_name: 'Aaron', last_name: 'Marks', email: 'super_aaron@gmail.com'
    create :user, first_name: 'Jim', last_name: 'Jones', email: 'aaron_is_not_my_name@gmail.com'
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

  context 'ordered_actions' do
    it 'orders sql actions before array filters' do
      expect(controller_with_columns.send(:ordered_actions).map{|action| action.method}).to eq [:sql, :sql, :sql, :sql, :array, :array]
    end
  end

  context 'filter_and_sort' do
    it 'filters using a single filter' do
      filter_by_first_name = controller_with_columns.send(:filter_and_sort, User.all, {TableSortable::PAGESIZE => '10', TableSortable::PAGE => '0', TableSortable::FCOL => {'0' => 'a'}, TableSortable::SCOL => {'0' => TableSortable::SORT_ASC}})
      expect(filter_by_first_name.pluck(:first_name)).to eq %w(Aaron David)
    end
    it 'filters using multiple filters' do
      filter_by_first_name = controller_with_columns.send(:filter_and_sort, User.all, {TableSortable::PAGESIZE => '10', TableSortable::PAGE => '0', TableSortable::FCOL => {'0' => 'a', '1' => 'c'}, TableSortable::SCOL => {'0' => TableSortable::SORT_ASC}})
      expect(filter_by_first_name.pluck(:first_name)).to eq %w(David)
    end
    it 'sorts a record set based on the column to sort' do
      sort_by_first_name = controller_with_columns.send(:filter_and_sort, User.all, {TableSortable::PAGESIZE => '10', TableSortable::PAGE => '0', TableSortable::SCOL => {'0' => TableSortable::SORT_ASC}})
      expect(sort_by_first_name.pluck(:first_name)).to eq %w(Aaron Bob David Jim)

      sort_by_email = controller_with_columns.send(:filter_and_sort, User.all, {TableSortable::PAGESIZE => '10', TableSortable::PAGE => '0', TableSortable::SCOL => {'2' => TableSortable::SORT_ASC}})
      expect(sort_by_email.pluck(:first_name)).to eq %w(Jim David Bob Aaron)
    end
    context "sort order parameter equals #{TableSortable::SORT_DESC}" do
      it 'sorts in descending order' do
        sort_by_last_name_desc = controller_with_columns.send(:filter_and_sort, User.all, {TableSortable::PAGESIZE => '10', TableSortable::PAGE => '0', TableSortable::SCOL => {'1' => TableSortable::SORT_DESC}})
        expect(sort_by_last_name_desc.pluck(:first_name)).to eq %w(Aaron Jim Bob David)
      end
    end

  end
end