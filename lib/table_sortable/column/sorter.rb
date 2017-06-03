module TableSortable
  class Column
    class Sorter
      include TableSortable::Concerns::Proc

      attr_accessor :sort_order

      def initialize(*args)
        super :sort, *args
      end

      def array_proc
        -> (sort_order, col=nil) { sort{ |a,b| col.value(sort_order == :asc ? a : b) <=> col.value(sort_order == :asc ? b : a) } }
      end

      def active_record_proc
        -> (sort_order, col=nil) { order(col.name.to_s.underscore => sort_order) }
      end

      def proc_wrapper(proc)
        -> (sort_order, col=nil) { instance_exec(sort_order , &proc) }
      end

      def run(records)
        records.instance_exec(sort_order, column, &proc)
      end

      def used?
        !sort_order.nil?
      end

    end
  end
end