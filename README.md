# TableSortable

[![Build Status](https://travis-ci.org/odedd/table_sortable.svg?branch=master)](https://travis-ci.org/odedd/table_sortable)

TableSortable adds multi-column, **server-side** filtering, sorting and pagination 
to the **tableSorter jQuery plugin**, so you don't have to worry about interpreting the query parameters,
combining multiple queries, columns to sort by, or figuring out how to send the correct page back to the client.

It is a Rails backend complementation to the frontend tableSorter.js.

#### The Problem
The jQuery tableSorter plugin is an excellent tool for filtering and sorting tables. 
Often, when dealing with lots of rows, we may want to split the table into multiple pages. tableSorter.js has a nifty [widget](https://mottie.github.io/tablesorter/docs/example-pager-ajax.html) for that, which requires using [mottie's fork](https://mottie.github.io/tablesorter/docs/index.html) of tableSorter.

Usually this is a scenario where we don't want to send our entire set of records to the frontend,
which consequently means that the frontend no longer knows the entire set of records to filter and sort through,
which eventually requires our *server* to handle all that stuff as well as the pagination of the results.

#### The Solution: TableSortable
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

Of course there are many more configuration options that make TableSortable flexible and adaptable. For those, please see [advanced configuration](#advanced-configuration)

## Advanced Configuration
Coming soon...

### View Helpers
Coming soon...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/odedd/table_sortable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TableSortable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/table_sortable/blob/master/CODE_OF_CONDUCT.md).
