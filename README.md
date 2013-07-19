Churn
===

A Project to give the churn file, class, and method for a project for a given checkin. Over time the tool adds up the history of churns to give the number of times a file, class, or method is changing during the life of a project.
Churn for files is immediate, but classes and methods requires buildings up a history using churn between revisions. The history is stored in ./tmp

Currently has full Git, Mercurial (hg), and Bazaar (bzr) support, and partial SVN support (supports only file level churn currently)

Authors:

* danmayer
* ajwalters
* cldwalker
* absurdhero
* bf4

## CI Build Status

[![Build Status](https://secure.travis-ci.org/danmayer/churn.png)](http://travis-ci.org/danmayer/churn)

This project runs [travis-ci.org](http://travis-ci.org)

## Churn Usage

Install with `gem install churn` or for bundler add to your Gemfile `gem 'churn', :require => false`. 

The reason you want require false is that when required by default churn is expecting to add some rake tasks, you don't really want or need it loading when running your server or tests. Previous versions required this change, churn will now do the right thing if you forget to add `require => false`. 

* rake:
  * add `require 'churn'` to Rakefile
  * then run`rake churn` or `bundle exec rake churn`
  * use environment variables to control churn defaults

        ENV['CHURN_MINIMUM_CHURN_COUNT']
        ENV['CHURN_START_DATE']
        ENV['CHURN_IGNORE_FILES']

* CLI:
  * on command line run `churn` or `bundle exec churn`
  * need help run `churn -h` to get additional information
  * run the executable passing in options to override defaults

        churn -i "churn.gemspec, Gemfile" #ignore files
        churn -y #output yaml format opposed to text
        churn -c 10 #set minimum churn count on a file to 10
        churn -c 5 -y -i "Gemfile" #mix and match
        churn --start_date "6 months ago" #Start looking at file changes from 6 months ago


## Example Output

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
    +-------------------------------+-----------------  +-------------------------------+
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

## Options

    [~/projects/churn] churn -h
    NAME
      churn

    SYNOPSIS
      churn [options]+

    PARAMETERS
    --minimum_churn_count=minimum_churn_count, -c (0 ~>  int(minimum_churn_count=3))
    --yaml, -y
    --ignore_files=[ignore_files], -i (0 ~> string(ignore_files=))
    --start_date=[start_date], -s (0 ~> string(start_date=))
    --help, -h

## TODO

The list of items has been moved to the [http://waffle.io/danmayer/churn](churn wafflie.io)

## Notes on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2013 Dan Mayer. See LICENSE for details.
