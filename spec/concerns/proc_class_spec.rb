shared_examples_for 'proc_class' do |parameter_name|
  include_context 'shared stuff'

  let(:dummy_class) { described_class.new(parameter_name => ->(x) {x}, column: dummy_col) }

  it 'includes TableSortable::Concerns::Proc' do
    expect(described_class.included_modules).to include TableSortable::Concerns::Proc
  end
  it 'defines methods of its own' do
    expect(dummy_class.array_proc).to respond_to :call
    expect(dummy_class.active_record_proc).to respond_to :call
    expect(dummy_class.send(:proc_wrapper, -> {x})).to respond_to :call
    expect(dummy_class).to respond_to :run
    expect(dummy_class).to respond_to :used?
  end
end