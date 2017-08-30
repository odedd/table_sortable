
module TableSortable
  module Controller

    extend ActiveSupport::Concern
    include TableSortable::Core

    included do
      helper_method :columns, :all_columns
      prepend_before_action :initialize_table_sortable
    end

    module ClassMethods
      def define_columns(*args)
        options = args.extract_options!
        before_action do
          define_columns(options)
        end

      end

      def define_column(*args)
        before_action do
          define_column *args
        end
      end

      def define_column_order(order)
        before_action do
          define_column_order order
        end
      end

      def define_column_offset(offset)
        before_action do
          define_column_offset offset
        end
      end

      def define_translation_key(key)
        before_action do
          define_translation_key key
        end
      end

      def define_template_path(path)
        before_action do
          define_template_path path
        end
      end
    end


  end
end