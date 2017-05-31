module TableSortable
  class Column
    class Filter
      include TableSortable::Concerns::Proc

      attr_accessor :query

      def initialize(*args)
        super :filter, *args
      end

      def array_proc
        -> (value, col=nil) { select{|record| value.downcase.in? col.value(record).to_s.downcase} }
      end

      def sql_proc
        -> (value, col=nil) { where("LOWER(?) LIKE (?)", filter.to_s.underscore, "%#{value.to_s.downcase}%") }
      end

      def proc_wrapper(proc)
        -> (value, col=nil) { instance_exec(value, &proc) }
      end

      def run(records)
        records.instance_exec(query, column, &proc)
      end

      def used?
        !query.nil?
      end

    end
  end
end