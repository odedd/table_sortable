module TableSortable
  class Column
    class Filter
      include TableSortable::Concerns::Proc

      attr_accessor :query, :default_value, :collection, :sort_collection

      def initialize(*args)
        options = args.extract_options!
        @default_value = options[:filter_initial_value]
        @collection = options[:filter_collection]
        @sort_collection = options[:filter_sort_collection] || false
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
        result = records.instance_exec(query, column, &proc)

        # PostgreSQL compatibility: When using HAVING, ensure GROUP BY includes all selected columns
        if result.is_a?(ActiveRecord::Relation) && uses_having?(result)
          result = auto_group_for_having(result, records)
        end

        result
      end

      private

      def uses_having?(relation)
        relation.having_clause.present? rescue false
      end

      def auto_group_for_having(relation, original_records)
        # PostgreSQL requires all selected columns to be in GROUP BY when using HAVING
        # Build a comprehensive GROUP BY clause
        group_columns = ["#{relation.table_name}.#{relation.klass.primary_key}"]

        # Extract all table.column references from select_values
        all_selects = extract_select_columns(relation) + extract_select_columns(original_records)

        # Add all selected columns to GROUP BY
        all_selects.uniq.each do |select_expr|
          # Skip aggregate functions and subquery result columns
          next if select_expr.include?('(') || select_expr.include?('_totals_')

          # Extract the actual column reference (before " as alias" if present)
          col = if select_expr.include?(' as ')
            select_expr.split(' as ').first.strip
          else
            select_expr
          end

          # Add the column (with or without table prefix)
          group_columns << col
        end

        relation.group(group_columns.uniq.join(', '))
      end

      def extract_select_columns(relation)
        return [] unless relation.is_a?(ActiveRecord::Relation)
        return [] unless relation.select_values.present?

        # Get all select expressions, including those without table prefixes
        relation.select_values.map(&:to_s)
      end

      public

      def used?
        !query.nil?
      end

    end
  end
end