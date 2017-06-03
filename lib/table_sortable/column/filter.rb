module TableSortable
  class Column
    class Filter
      include TableSortable::Concerns::Proc

      attr_accessor :query, :default_value

      def initialize(*args)
        options = args.extract_options!
        @default_value = options[:filter_initial_value]
        super :filter, options
      end

      def array_proc
        -> (value, col=nil) { select{|record| col.value(record).to_s.downcase.include? value.downcase} }
      end

      def active_record_proc
        -> (value, col=nil) { where("LOWER(#{col.name.to_s.underscore}) LIKE (?)", "%#{value.to_s.downcase}%") }
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