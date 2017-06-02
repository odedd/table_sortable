module TableSortable
  module Concerns
    module Proc
      extend ActiveSupport::Concern

      included do
        attr_reader :proc, :method, :column, :type
      end

      def initialize(option_name, *options)
        options = options.extract_options!
        unless options[option_name] == false
          @type = option_name
          @column = options[:column]
          the_proc = options[option_name] || @column.name
          @method = options["#{option_name.to_s}_method".to_sym] || :array
          if the_proc.respond_to? :call
            @proc = proc_wrapper(the_proc)
            @method = detect_method(@proc)
          elsif !the_proc.nil?
            case @method
              when :array
                @proc = array_proc
              when :active_record
                @proc = sql_proc
            end
          end
        end
      end

      def detect_method(proc)
        begin
          [].instance_exec('', &proc)
          method = :array
        rescue NoMethodError
          method = :active_record
        end
        method
      end

      def disabled?
        method.nil?
      end

      def array_proc
        raise NotImplementedError
      end

      def sql_proc
        raise NotImplementedError
      end

      def proc_wrapper(proc)
        raise NotImplementedError
      end

      def run(records)
        raise NotImplementedError
      end

      def used?
        raise NotImplementedError
      end
    end
  end
end

