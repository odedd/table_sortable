shared_examples_for 'proc_class' do |parameter_name|
  include_context 'shared stuff'

  let(:dummy_class) { described_class.new(parameter_name => ->(x) {x}) }

  it 'includes TableSortable::Concerns::Proc' do
    expect(described_class.included_modules).to include TableSortable::Concerns::Proc
  end
  it 'defines array_proc and sql_proc that return a proc' do
    expect(dummy_class.array_proc).to respond_to :call
    expect(dummy_class.sql_proc).to respond_to :call
  end
end