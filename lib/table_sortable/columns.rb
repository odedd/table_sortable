module TableSortable
  class Columns

    def initialize
      @columns = []
    end

    def add(col_name, *options)
      options = options.extract_options!
      @columns << TableSortable::Column.new(col_name, options)
    end

    def define_column(col_name, *options)
      options = options.extract_options!
      @columns << TableSortable::Column.new(col_name, options)
    end

    def sort_by(sort_key)
      if sort_key
        sort_key.map{|c| @columns.find{|col| (c.is_a?(String) ? (col.label == c) : col.name == c)}}
      else
        @columns
      end
    end

    def sort(&sort_proc)
      @columns.sort(&sort_proc)
    end

  end
end