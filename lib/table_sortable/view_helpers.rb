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
        label = col.label
        placeholder = col.placeholder
        filter = col.filter

        th_options = {}
        th_options['data-placeholder'] = placeholder if placeholder
        # th_options['data-priority'] = col.sort_priority if col.sort_priority
        th_options['data-filter'] = 'false' if filter.disabled?
        th_options['data-sorter'] = 'false' if col.sorter.disabled?
        unless filter.collection.blank?
          th_options['filter-select'] = true
          th_options['data-filter-options'] = filter.collection
        end
        th_options['data-value'] = filter.default_value if filter.default_value
        th_options.merge!(html_options)
        view_path = "#{col.template_path || controller_path}/table_sortable/"
        view_filename = "#{col.template}_header.html"
        if Dir.glob(File.join(Rails.root, 'app', 'views', view_path, "_#{view_filename}.*")).any?
          render partial: File.join(view_path, view_filename),
                 locals: {label: label,
                          column: col,
                          index: index}
        else
          content_tag :th, th_options do
            label
          end
        end
      end.join.html_safe
    end

    def table_sortable_columns(record, html_options = {})
      controller.columns.map.with_index do |col, index|
        value = col.value(record)
        content = col.content(record)
        td_options = {}
        td_options['data-text'] = value if value != content
        td_options.merge!(html_options)
        view_path = "#{col.template_path || controller_path}/table_sortable/"
        view_filename = "#{col.template}_column.html"
        if Dir.glob(File.join(Rails.root, 'app', 'views', view_path, "_#{view_filename}.*")).any?
          render partial: File.join(view_path, view_filename),
                 locals: {content: content,
                          value: value,
                          source: record,
                          column: col,
                          index: index}
        else
          content_tag :td, td_options do
            value
          end
        end
      end.join.html_safe
    end
  end
end