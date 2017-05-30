module TableSortable
  class Result < Array

    attr_reader :total_count

    def initialize(the_array, page, page_size)
      @total_count = the_array.length
      super(the_array[(page)*page_size, page_size])
    end

  end
end