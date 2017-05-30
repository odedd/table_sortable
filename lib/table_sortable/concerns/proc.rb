module TableSortable
  module Concerns
    module Proc
      extend ActiveSupport::Concern

      included do
        attr_reader :proc, :method
      end

      def initialize(option_name, *options)
        options = options.extract_options!
        unless options[option_name] == false
          filter = options[option_name] || options[:column_name]
          @method = options["#{option_name.to_s}_method".to_sym] || :array
          if filter.respond_to? :call
            @proc = -> (records, col=nil) { instance_exec(records, &filter) }
            @method = detect_method(@proc)
          elsif !filter.nil?
            case @method
              when :array
                @proc = array_proc
              when :sql
                @proc = sql_proc
            end
          end
        end
      end

      def detect_method(proc)
        method = [].instance_exec('', &proc) rescue :failed
        method == :failed ? :sql : :array
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

    end
  end
end

