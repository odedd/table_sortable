module TableSortable
  class Column
    class Filter
      include TableSortable::Concerns::Proc

      def initialize(*options)
        super :filter, *options
      end

      def array_proc
        -> (value, col=nil) { select{|record| value.downcase.in? col.value(record).to_s.downcase} }
      end

      def sql_proc
        -> (value, col=nil) { where("? LIKE (?)", filter.to_s.underscore, "%#{value}%") }
      end
    end
  end
end