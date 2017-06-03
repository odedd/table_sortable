# TableSortable

[![Build Status](https://travis-ci.org/odedd/table_sortable.svg?branch=master)](https://travis-ci.org/odedd/table_sortable)

TableSortable adds multi-column, **server-side** filtering, sorting and pagination 
to the **tableSorter jQuery plugin**, so you don't have to worry about interpreting the query parameters,
combining multiple queries, columns to sort by, or figuring out how to send the correct page back to the client.

It is a Rails backend complementation to the frontend tableSorter.js.

### The Problem
The jQuery tableSorter plugin is an excellent tool for filtering and sorting tables. 
Often, when dealing with lots of rows, we may want to split the table into multiple pages. tableSorter.js has a nifty [widget](https://mottie.github.io/tablesorter/docs/example-pager-ajax.html) for that, which requires using [mottie's fork](https://mottie.github.io/tablesorter/docs/index.html) of tableSorter.

Usually this is a scenario where we don't want to send our entire set of records to the frontend,
which consequently means that the frontend no longer knows the entire set of records to filter and sort through,
which eventually requires our *server* to handle all that stuff as well as the pagination of the results.

### The Solution: TableSortable
TableSortable will handle all the backend filtering, sorting and pagination for you.

NOTICE: This gem is in very early stages of development, and is not yet fully documented.  Any input will be more than welcome.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'table_sortable'
```

Then run `bundle install` and you're ready to start

You should also probably be using jquery-tablesorter.  
For information regarding integration or tableSorter.js into your Rails project, 
please see the [jQuery tablesorter plugin for Rails](https://github.com/themilkman/jquery-tablesorter-rails) page.

## Usage

First, we need to setup our controller. For this example this will be a users controller.  
Let's `include TableSortable` so that we can use its methods.

```ruby
#controllers/users_controller.rb
class UsersController < ApplicationController
  include TableSortable
```

Next, let's define our columns.
```ruby
#controllers/users_controller.rb
class UsersController < ApplicationController
  include TableSortable
  
  define_colunns :first_name, :last_name, :email, :created_at
```
That's just the basic setup of columns. For more configuration options, please see [advanced configuration](#advanced-configuration).

Now we need to make sure our `index` action filters, sorts and paginates the records.  
We can do that using the `filter_and_sort` method.
```ruby
#controllers/users_controller.rb
def index
  
  @users = filter_and_sort(User.all)
  
  respond_to do |format|
    format.html {}
    format.json {render layout: false}
  end
end
```

Let's write the `index` view. We can use TableSortable's [view helpers](#view-helpers) to render our table.
```erb
<!-- views/users/index.html.erb -->
<div id="usersPager">
    <%= table_sortable_pager %>
</div>

<table id="usersTable" data-query="<%= users_path %>">
    <thead>
        <tr>
            <%= table_sortable_headers %>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
```
Notice how `index.html` doesn't render the actual rows. They will later be polled via ajax by tableSorter.js.

Let's create `index.json.jbuilder` to send the users' info back to the frontend.
```ruby
# views/users/index.json.jbuilder
# Since we only send out the current page of users, 
# we must also send the total number of records.
# We'll use TableSortable's total_count method for that.
json.total @users.total_count
json.rows @users.map{|user| render partial: 'user_row.html.erb', locals: {user: user}}.join
json.pager_output 'Users {startRow} to {endRow} of {totalRows}'
```
We should also create the _user_row.html partial. In it, we may also use TableSortable's [helpers](#view-helpers).
```erb
<!-- views/users/_user_row.html.erb -->
<tr>
    <%= table_sortable_columns user %>
</tr>
```

Now that we are done configuring the backend - let's continue to frontend. Here's a simple tableSorter.js configuration example:
```javascript
var table = $('#usersTable');
table.tablesorter({
    widgets: ['filter', 'pager'],
    widgetOptions: {
        // show 10 records at a time
        pager_size: 10,
        // Poll our users_index_path, which we receive from the table's data-query attribute.
        pager_ajaxUrl: table.data('query') + '?pagesize={size}&page={page}&{filterList:fcol}&{sortList:scol}',
        // Parse the incoming result
        pager_ajaxProcessing: function (data) {
            if (data && data.hasOwnProperty('rows')) {
                // Update the pager output
                this.pager_output = data.pager_output;
                // return total records, the rows HTML data,
                // and the headers information.
                return [data.total, $(data.rows)];
            }
        }
    }
});
```
That's it! The results fetched from the server are now filtered, sorted and paginated by TableSortable.

For full documentation of the usage of tableSorter.js please go [here](https://mottie.github.io/tablesorter/docs/index.html) for the very popular fork by mottie, or [here](http://tablesorter.com/docs/) for the original version of the plugin.

Of course there are many more configuration options that make TableSortable flexible and adaptable. For those, please see [advanced configuration](#advanced-configuration).

## Advanced Configuration

TableSortable has several advanced configuration settings, which allow for a more fine-grained control over its behaviour.

- [define_column](#define_column)
- [define_column_order](#define_column_order)
- [define_column_offset](#define_column_offset)

#### define_column  

TableSortable lets you define the columns one by one with many custom attributes, using the `define_column` method.
```ruby
#controllers/users_controller.rb
class UsersController < ApplicationController
  include TableSortable
  
  define_column :full_name, 
                 value: -> (user) {"#{user.first_name} #{user.last_name}"}
  define_column :email
end
```
##### Syntax: `define_column column_name, [arguments]`  

- `column_name` <sub>(required)</sub>  
    A symbol representing the column_name. Can be anything, but should usually be the same as the column name. 
- `arguments` <sub>(optional)</sub>  
    - `value: (symbol|proc)`  
        <sub>default: same as column name</sub>   
        Accepts either a symbol representing a method that the record responds to, like an ActiveRecord attribute, 
        or a proc the returns the record's value. for example:
        ```ruby
        define_column :full_name, 
                      value: -> (user) {"#{user.first_name} #{user.last_name}"}
        ```
    - `content: (symbol|proc)`  
        <sub>default: same as value</sub>   
        Works the same way as `value`, but allows specifying a different value to be displayed in the table cells.
        The difference between `value` and `content` is that the former determines the value by which the scope will be filtered and sorted,
        while the latter only affects the displayed cell contents.
        ```ruby
        define_column :full_name, 
                      value:   -> (user) {"#{user.first_name} #{user.last_name}"},
                      content: -> (user) {"#{user.last_name}, #{user.first_name}"}
        ```
    - `label: (string)`  
        <sub>default: 'Titleized' version of the column name</sub>   
        Allows specifying a string to be used as the column label, displayed at the table header.
    - `placeholder: (string|false)`  
        <sub>default: same as label</sub>  
        Allows specifying a string to be used as a placeholder for the column's filter input field.
        You may also specify `false`, in which case no placeholder will be displayed.
    - `filter: (proc|false)`  
        <sub>default: free case-insensitive text search on the column's value</sub>   
        By default, the column will be filtered according to the column's value. However, you may specify a proc to perform the search on that column. 
        The proc itself can contain either ActiveRecord operations (eg. `where`) or array operations (eg. `select`), 
        and will be passed the current filter query when run.
        ```ruby
        define_column :full_name, 
                      filter: ->(query) {where('LOWER(CONCAT(first_name," ", last_name)) LIKE (?)', "%#{query.downcase}%")}
        ```
        If no filtering is to be performed on that column you can set it to `false`. When using TableSortable's [view helpers](#view-helpers),
        this also means that no filter input will be shown on that column.
    - `filter_method: (:array|:active_record)`  
        <sub>default: :array</sub>   
        Determines whether the default filter function relies on an ActiveRecord `where` method or an Array `select` method.  
        _Only applies when no `filter` option has been specified._
        - `:array` <sub>(default)</sub>  
            Filter using the `select` method. While being slower, it selects based on the column's value, whatever it might be, and so fits every scenario.
        - `:active_record`  
            Filter using the `where` method. While being faster, it only applies to cases where the column name matches the database column name. 
    - `filter_initial_value: (string)`
        <sub>default: nil</sub>   
        You may specify an initial filter query for each column.
    - `sort: (proc|false)`  
        <sub>default: sorting based on the column's value</sub>   
        By default, the record set will be sorted according to the selected column's value. 
        However, you may specify a proc to perform the sorting when this column is selected as the sort base. 
        The proc itself can contain either ActiveRecord operations (eg. `order`) or array operations (eg. `sort`), 
        and will be passed the current sort order as a symbol (`:asc` or `:desc`) when run.
        ```ruby
        define_column :full_name, 
                      sort: -> (sort_order) { sort{ |a,b| (sort_order == :asc ? a : b) <=> (sort_order == :asc ? b : a) } }
        ```
        If no sorting is to be performed based on that column you can set it to `false`. When using TableSortable's [view helpers](#view-helpers),
        this also means that no sorting handle will be shown on the client side on that column as well.
    - `sort_method: (:array|:active_record)`  
        <sub>default: :array</sub>   
        Determines whether the default sort function relies on an ActiveRecord `order` method or an Array `sort` method.  
        _Only applies when no `sort` option has been specified._
        - `:array` <sub>(default)</sub>  
            Sort using the `sort` method. While being slower, it sorts based on the column's value, whatever it might be, and so fits every scenario.
        - `:active_record`  
            Sort using the `order` method. While being faster, it only applies to cases where the column name matches the database column name. 
    - `template: (string)`  
        <sub>default: same as column_name</sub>  
        Allows setting a custom template name to look for when rendering the header or column contents. For more information see [view helpers](#view-helpers).

##### Dynamic Column Definitions

If the column definitions themselves need to be dynamic (eg. if you're using 
dynamic fields in your model) you can also use `define column` in a `before action` callback like this
```ruby
#controllers/users_controller.rb
  
  before_action :define_columns

  private
  
  def define_columns
    @user.custom_fields.each do |cf|
      define_column cf, 
                    value: -> (user) {user.get_custom_field(cf)}
    end
  end
```

#### define_column_order  
Columns are displayed in the order they are defined using `define_method`. If you wish, you may override this order by specifying your own using the `define_column_order` method.  
It also allows hiding columns that you need to include in the filtering and sorting process, eg. when you want to have an external search box filtering based on a column that you don't necessarily want to display.
##### Syntax: `define_column_order column1, [column2], [column3] ...`  
```ruby
#controllers/users_controller.rb
#define a full_name column, allowing to create a custom search box that operates on the 4th column
define_columns :first_name, :last_name, :email, :full_name
define_column_order :last_name, :first_name, :email
```
#### define_column_offset  
Sometimes you wish to manually add columns in the views before adding the defined TableSortable columns, eg. to have a checkbox next to each row.  
```erb
<!-- views/users/index.html.erb -->
<table id="usersTable" data-query="<%= users_path %>">
    <thead>
        <tr></tr>   <!-- EXTRA COLUMN -->
        <tr>
            <%= table_sortable_headers %>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>

<!-- views/users/_user_row.html.erb -->
<tr> <%= check_box_tag :checked %> </tr>   <!-- EXTRA COLUMN -->
<tr>
    <%= table_sortable_columns user %>
</tr>
```
Since the column numbers that appear in tableSorter.js' ajax request will represent their actual number, you should let TableSortable know that the columns you defined are offset.  
So, in the above case you should define an offset of 1.

##### Syntax: `define_column_offset offset`  
```ruby
define_column_offset 1
```
You may define it either using the `define_column_offset` method shown above, 
or using the all inclusive `define_columns` method, as an `offset: <integer>` argument.
```ruby
define_column :first_name, :last_name, :email, offset: 1
```

### View Helpers
TableSortable offers several view helpers, to help maintain the connection between the view layer and the controller layer, and make your code DRYer and less error prone.
- [table_sortable_headers](#table_sortable_headers)
- [table_sortable_columns](#table_sortable_columns)
- [table_sortable_pager](#table_sortable_pager)

#### table_sortable_headers
##### Syntax: `table_sortable_headers [html_attributes]`  
Renders the table header columns, each one inside a \<th> tag.  
Notice that it _does not_ wrap a \<tr> tag around the headers, to allow you adding columns before of after TableSortable's headers. 

It also renders data attributes that let tableSorter.js know the columns behaviour:
- `data-filter="false"` if the column's `filter` attribute is set to `false`.
- `data-sorter="false"` if the column's `sort` attribute is set to `false`.
- `data-placeholder="?"` if a placeholder has been defined (defaults to be the same as the column's label).
- `data-value="?"` if an initial filter value has been defined.

You may also specify any html attribute, as well as additional data attributes to be added to each \<th> element.
```erb
<tr> <%= table_sortable_headers class: 'text-center' %> </tr>
```

If you wish to render your own version of a specific header (eg. to add an icon), 
you may create a partial inside a `table_sortable` folder nested inside the controller's views folder. The partial should be named according to the following naming scheme:  
`_<template>_header.html`, with `template` corresponding to the column's template attribute.  
Notice that in this case you need to manually specify the different data attributes that correspond to the behaviour you wish this column to have.

The view will be supplied with two locals:
- `label`: the column's label
- `column`: the TableSortable::Column object

Here is an example of a full name header partial, which includes a font-awesome icon:
```erb
<!-- views/users/table_sortable/_full_name_header.html.erb -->
<th data-placeholder="<%= column.placeholder %>"> 
    <i class="fa fa-user" aria-hidden="true"></i>
    <%= label %> 
</th>
```

By using the template attribute you may render several columns using the same template.

#### table_sortable_columns
##### Syntax: `table_sortable_columns record, [html_attributes]`  
Renders the table columns for a specific `record`, each one inside a \<td> tag.  
Notice that it _does not_ wrap a \<tr> tag around the headers, to allow you adding columns before of after TableSortable's columns. 

It also renders data attributes that let tableSorter.js know the columns behaviour:
- `data-text="?"` if the column's `value` attribute is different than the column's `content` attribute, the value will be set in the `data-text` attribute, and the content will be displayed inside the \<td> element.

You may also specify any html attribute, as well as additional data attributes to be added to each \<td> element.
```erb
<tr> <%= table_sortable_columns @user, class: 'text-info' %> </tr>
```

If you wish to render your own version of a specific column (eg. to include a link inside of it), 
you may create a partial inside a `table_sortable` folder nested inside the controller's views folder. The partial should be named according to the following naming scheme:  
`_<template>_column.html`, with `template` corresponding to the column's template attribute.  
Notice that in this case you need to manually specify the different data attributes that correspond to the behaviour you wish this column to have.

The view will be supplied with four locals:
- `source`: the source ActiveRecord object
- `content`: the column's content to be displayed
- `value`: the column's value
- `column`: the TableSortable::Column object

Here is an example of a full name column partial, in which the name links to the edit_user_path:
```erb
<!-- views/users/table_sortable/_full_name_column.html.erb -->
<td> 
    <%= link_to content, edit_user_path(@user) %> 
</td>
```

By using the template attribute you may render several columns using the same template.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/odedd/table_sortable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TableSortable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/table_sortable/blob/master/CODE_OF_CONDUCT.md).
