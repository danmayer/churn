[![Build Status](https://travis-ci.org/danmayer/churn.svg?branch=master)](http://travis-ci.org/danmayer/churn)

# Churn

A Project to give the churn file, class, and method for a project for a given checkin. Over time the tool adds up the history of churns to give the number of times a file, class, or method is changing during the life of a project.
Churn for files is immediate, but classes and methods requires building up a history using churn between revisions. The history is stored in ./tmp

Currently has full Git, Mercurial (hg), Bazaar (bzr) support, and partial SVN support (supports only file level churn currently)

File changes can be calculated on any single commit to look at method changes you need to be running churn over time. Using a git post-commit hook, configuring your CI to run churn. See the --past_history (-p) option to do a one time run building up past class and method level churn.

## TODO

Want to help out, there are easy tasks ready for some attention. The list of items is hosted on [github issues](https://github.com/danmayer/churn/issues)

## Churn Usage

Install with `gem install churn` or for bundler add to your Gemfile


```
group :development do
  gem 'churn'
end
```

### Rake

* Add `require 'churn'` to Rakefile
* Then run `rake churn` or `bundle exec rake churn`
* Use environment variables to control churn defaults

``` ruby
ENV['CHURN_MINIMUM_CHURN_COUNT']
ENV['CHURN_START_DATE']
ENV['CHURN_IGNORES']
```

### CLI

* On the command line run `churn` or `bundle exec churn`
* Need help? Run `churn -h` to get additional information
* Run the executable, passing in options to override defaults

```shell
churn -i "churn.gemspec, Gemfile"   # Ignore files
churn -y                            # Output yaml format opposed to text
churn -c 10                         # Set minimum churn count on a file to 10
churn -c 5 -y -i "Gemfile"          # Mix and match
churn --start_date "6 months ago"   # Start looking at file changes from 6 months ago
churn -p "4 months ago"             # Churn the past history to build up data for the last 4 months
churn --past_history                # Churn the past history for default 3 months to build up data
```

## Example Output

```
**********************************************************************
* Revision Changes
**********************************************************************
Files:
+-------------------------------+
| file                          |
+-------------------------------+
| Rakefile                      |
| lib/churn/churn_calculator.rb |
+-------------------------------+

Classes:
+-------------------------------+-----------------+
| file                          | klass           |
+-------------------------------+-----------------+
| lib/churn/churn_calculator.rb | ChurnCalculator |
+-------------------------------+-----------------+

Methods:
+-------------------------------+-----------------+-------------------------------+
| file                          | klass           | method                        |
+-------------------------------+-----------------+-------------------------------+
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#filters       |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#display_array |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#to_s          |
+-------------------------------+-----------------+-------------------------------+

**********************************************************************
* Project Churn
**********************************************************************
Files:
+------------------------------------+---------------+
| file_path                          | times_changed |
+------------------------------------+---------------+
| lib/churn/churn_calculator.rb      | 14            |
| README.rdoc                        | 7             |
| lib/tasks/churn_tasks.rb           | 6             |
| Rakefile                           | 6             |
| lib/churn/git_analyzer.rb          | 4             |
| VERSION                            | 4             |
| test/test_helper.rb                | 4             |
| test/unit/churn_calculator_test.rb | 3             |
| test/churn_test.rb                 | 3             |
+------------------------------------+---------------+

Classes:
+-------------------------------+-----------------+---------------+
| file                          | klass           | times_changed |
+-------------------------------+-----------------+---------------+
| lib/churn/churn_calculator.rb | ChurnCalculator | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | 1             |
+-------------------------------+-----------------+---------------+

Methods:
+-------------------------------+-----------------+-----------------------------------------+---------------+
| file                          | klass           | method                                  | times_changed |
+-------------------------------+-----------------+-----------------------------------------+---------------+
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#to_s                    | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#display_array           | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#calculate_revision_data | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#filters                 | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#initialize              | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#filters                 | 1             |
| lib/churn/churn_calculator.rb | ChurnCalculator | ChurnCalculator#to_s                    | 1             |
+-------------------------------+-----------------+-----------------------------------------+---------------+
```

## CLI Options

```
    [~/projects/churn] churn -h
    NAME
      churn

    SYNOPSIS
      churn [options]+

    PARAMETERS
      --minimum_churn_count=minimum_churn_count, -c (0 ~>
      int(minimum_churn_count=3))
      --yaml, -y
      --ignore_files=[ignore_files], -i (0 ~> string(ignore_files=))
      --start_date=[start_date], -s (0 ~> string(start_date=))
      --data_directory=[data_directory], -d (0 ~> string(data_directory=))
      --past_history=[past_history], -p (0 ~> string(past_history=))
      --help, -h
```

## Library Options

All the CLI options are parsed and just passed into the library. If you want to run the library directly from other code. The best way to see current options is where the [churn executable](https://github.com/danmayer/churn/blob/master/bin/churn) passes the parsed options into the `ChurnCalculator` class

```ruby
###
# Available options
###
options = {:minimum_churn_count => params['minimum_churn_count'].value,
  :ignore_files => params['ignore_files'].value,
  :start_date => params['start_date'].value,
  :data_directory => params['data_directory'].value,
  :history => params['past_history'].value,
  :report => params['report'].value,
  :name => params['name'].value
}
result = Churn::ChurnCalculator.new(options).report(false)
```

## Notes on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Authors

* danmayer
* ajwalters
* cldwalker
* absurdhero
* bf4

## Code of Conduct

Please see our [Code of Conduct](https://github.com/danmayer/churn/blob/master/CODE_OF_CONDUCT.md)

## Copyright

Copyright (c) 2019 Dan Mayer. See LICENSE for details.
