describe TableSortable::Concerns::Proc do
  include_context 'shared stuff'

  let :proc_class do
    Class.new do
      include TableSortable::Concerns::Proc

      def array_proc
        -> (x) {x * 2}
      end

      def sql_proc
        -> (x) {x * 3}
      end

      def proc_wrapper(proc)
        proc
      end
    end
  end

  let :dummy_proc do
    proc_class.new(:proc, column: TableSortable::Column.new(:proc), proc: dummy_col)
  end

  context 'on initialization' do
    context 'given a proc' do
      it 'should keep it' do
        example_proc = -> (x) { x * 100 }
        proc = proc_class.new(:proc, column: TableSortable::Column.new(:proc),proc: example_proc )
        expect(5.instance_eval(&proc.proc)).to eq 500
      end
      context 'it is an sql proc' do
        it 'should detect it as sql' do
          proc = proc_class.new(:proc, column: TableSortable::Column.new(:proc), proc: -> (value) { where(name: value) } )
          expect(proc.method).to eq :active_record
        end
      end
      context 'it is an array proc' do
        it 'should detect it as array' do
          proc = proc_class.new(:proc, column: dummy_col, proc: -> (value) { select{|record| record.name == value} } )
          expect(proc.method).to eq :array
        end
      end
    end
    context 'given no proc' do
      it 'should use array proc' do
        expect(dummy_proc.method).to eq :array
      end
      context '_method: option' do
        context 'not provided' do
          it 'should replace it with array_proc' do
            expect(5.instance_eval(&dummy_proc.proc)).to eq 5.instance_eval(&dummy_proc.array_proc)
          end
        end
        context '== :active_record' do
          it 'should replace it with sql_proc' do
            dummy_proc = proc_class.new(:proc, column: TableSortable::Column.new(:proc), proc_method: :active_record)
            expect(5.instance_eval(&dummy_proc.proc)).to eq 5.instance_eval(&dummy_proc.sql_proc)
          end
        end
        context '== :array' do
          it 'should replace it with sql_proc' do
            dummy_proc = proc_class.new(:proc, column: TableSortable::Column.new(:proc), proc_method: :array)
            expect(5.instance_eval(&dummy_proc.proc)).to eq 5.instance_eval(&dummy_proc.array_proc)
          end
        end
      end
    end
  end

  context 'detect method' do
    context 'given a proc containing an sql method' do
      it 'should detect it as sql' do
        proc_to_detect = -> (filter_value) { where(name: filter_value) }
        expect(dummy_proc.detect_method(proc_to_detect)).to eq :active_record
      end
    end
    context 'given a proc containing an array method' do
      it 'should detect it as array' do
        proc_to_detect = -> (filter_value) { select{|record| record.name == filter_value} }
        expect(dummy_proc.detect_method(proc_to_detect)).to eq :array
      end
    end
  end
end