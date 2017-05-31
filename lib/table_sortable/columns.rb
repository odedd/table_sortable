module TableSortable
  class Columns < Array

    def initialize
      super
    end

    def add(col_name, *options)
      options = options.extract_options!
      self << TableSortable::Column.new(col_name, options)
    end

    def sort_by(sort_key)
      if sort_key
        sort_key.map{|c| self.find{|col| (c.is_a?(String) ? (col.label == c) : col.name == c)}}
      else
        self
      end
    end

  end
end