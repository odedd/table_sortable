module TableSortable
  class Result < Array

    attr_reader :total_count, :unpaginated

    def initialize(the_array, page, page_size)
      @unpaginated = the_array
      @total_count = the_array.length
      super(the_array[(page)*page_size, page_size])
    end

  end
end