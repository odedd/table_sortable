module TableSortable
  module ViewHelpers

    def table_sortable_pager(*args)
      options = args.extract_options!

      pagination_class =    options[:wrapper_class]       || 'pagination'
      page_display_class =  options[:page_display_class]  || 'pagedisplay'
      item_wrapper_class =  options[:item_wrapper_class]
      item_class =          options[:item_class]
      first_item =          options[:first]               || '<<'
      prev_item =           options[:prev]                || '<'
      next_item =           options[:next]                || '>'
      last_item =           options[:last]                || '>>'

      content_tag :ul, class:pagination_class do
        content_tag(:li, link_to(first_item,  '#', class: ([item_class] + ['first']).flatten.compact.join(' ')),            class: item_wrapper_class)+
        content_tag(:li, link_to(prev_item,   '#', class: ([item_class] + ['prev'] ).flatten.compact.join(' ')),            class: item_wrapper_class)+
        content_tag(:li, content_tag(:span,   nil, class: ([item_class] + [page_display_class]).flatten.compact.join(' ')), class: item_wrapper_class)+
        content_tag(:li, link_to(next_item,   '#', class: ([item_class] + ['next'] ).flatten.compact.join(' ')),            class: item_wrapper_class)+
        content_tag(:li, link_to(last_item,   '#', class: ([item_class] + ['last'] ).flatten.compact.join(' ')),            class: item_wrapper_class)
      end.html_safe
    end

    def table_sortable_headers(html_options = {})
      controller.columns.map.with_index do |col, index|
        th_options = {}
        th_options['data-placeholder'] = col.placeholder if col.placeholder
        # th_options['data-priority'] = col.sort_priority if col.sort_priority
        th_options['data-filter'] = 'false' if col.filter.disabled?
        th_options['data-sorter'] = 'false' if col.sorter.disabled?
        unless col.filter.collection.blank?
          th_options['data-filter-options'] = col.filter.collection.to_json
        end
        th_options['data-value'] = col.filter.default_value if col.filter.default_value
        th_options.merge!(html_options)

        if col.header_partial
          render partial: col.header_partial,
                 locals: {label: col.label,
                          column: col,
                          index: index}
        else
          content_tag :th, th_options do
            col.label
          end
        end
      end.join.html_safe
    end

    def table_sortable_columns(record, row_number, html_options = {})
      controller.columns.map.with_index do |col, index|
        value = col.value(record)
        content = col.content(record)
        td_options = {}
        td_options['data-text'] = value if value != content
        td_options.merge!(html_options)

        if col.column_partial
          @column_html[col.name][row_number]
        else
          content_tag :td, td_options do
            content
          end
        end
      end.join.html_safe
    end

    def table_sortable_rows(layout, collection, html_options = {})
      @column_html = {}
      controller.columns.select{|col| col.column_partial}.each do |col|
        @column_html[col.name] = []
        render partial: col.column_partial, collection: collection, as: :record, layout: '/table_sortable/capture_column.html.erb', locals: {column: col}
      end
      render partial: '/table_sortable/row.html.erb', layout: layout, collection: collection, as: :record, locals: {html_options: html_options}
    end
  end
end