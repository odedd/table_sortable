module TableSortable
  class Columns < Array

    def initialize(*args)
      super *args
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

    def visible
      Columns.new(self.select{|c| c.visible?})
    end

    def [](name)
      return self.find{|col| col.name == name.to_sym} if name.is_a? String
      super
    end

  end
end