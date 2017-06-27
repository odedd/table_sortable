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
          th_options['filter-select'] = true
          th_options['data-filter-options'] = col.filter.collection
        end
        th_options['data-value'] = col.filter.default_value if col.filter.default_value
        th_options.merge!(html_options)

        begin
          render partial: "#{col.template_path || controller_path}/table_sortable/#{col.template}_header.html",
                 locals: {label: col.label,
                          column: col,
                          index: index}
        rescue ActionView::MissingTemplate
          content_tag :th, th_options do
            col.label
          end
        end
      end.join.html_safe
    end

    def table_sortable_columns(record, html_options = {})
      controller.columns.map.with_index do |col, index|
        td_options = {}
        td_options['data-text'] = col.value(record) if col.value(record) != col.content(record)
        td_options.merge!(html_options)

        begin
          render partial: "#{col.template_path || controller_path}/table_sortable/#{col.template}_column.html",
                 locals: {content: col.content(record),
                          value: col.value(record),
                          source: record,
                          column: col,
                          index: index}
        rescue ActionView::MissingTemplate
          content_tag :td, td_options do
            col.value(record)
          end
        end
      end.join.html_safe
    end
  end
end