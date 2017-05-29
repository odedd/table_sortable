module TableSortable
  class Column
    class Sorter
      include TableSortable::Concerns::Proc

      def initialize(*options)
        super :sort, *options
      end

      def array_proc
        -> (col=nil) { sort{ |a,b| col.value(a) <=> col.value(b) }}
      end

      def sql_proc
        -> (col=nil) { order(sorter) }
      end

    end
  end
end