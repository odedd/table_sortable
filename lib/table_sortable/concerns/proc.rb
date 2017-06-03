module TableSortable
  module Concerns
    module Proc
      extend ActiveSupport::Concern

      included do
        attr_reader :proc, :column, :type
      end

      def initialize(option_name, *options)
        options = options.extract_options!
        unless options[option_name] == false
          @type = option_name
          @column = options[:column]
          the_proc = options[option_name] || @column.name
          @method = options["#{option_name.to_s}_method".to_sym] || :autodetect
          if the_proc.respond_to? :call
            @proc = proc_wrapper(the_proc)
            @method = detect_method(@proc)
          elsif !the_proc.nil?
            case @method
              when :array
                @proc = array_proc
              when :active_record
                @proc = active_record_proc
            end
          end
        end
      end

      def detect_method(proc, scope = nil)
        begin
          [].instance_exec('', &proc)
          method = :array
        rescue NoMethodError
          method = :active_record
        end
        method
      end

      def method(record = nil)
        return @method if record.nil?
        if @method == :autodetect
          if record.class.columns.map{|col| col.name.to_sym}.include? @column.name
            method = :active_record
            @proc = active_record_proc
          else
            method = :array
            @proc = array_proc
          end
        else
          method = @method
        end
        method
      end

      def disabled?
        method.nil?
      end

      def array_proc
        raise NotImplementedError
      end

      def active_record_proc
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

