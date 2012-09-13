__churn__

A Project to give the churn file, class, and method for a project for a given checkin. Over time the tool adds up the history of chruns to give the number of times a file, class, or method is changing during the life of a project.
Churn for files is immediate, but classes and methods requires buildings up a history using churn between revisions. The history is stored in ./tmp

Currently has full Git, Mercurial (hg), and Bazaar (bzr) support, and partial SVN support (supports only file level churn currently)

Authors:

* danmayer
* ajwalters 
* cldwalker
* absurdhero

Execute with:  
    `rake churn` #after adding require 'churn' to projects rakefile  
    or as a executable `churn`
    
__Example Output__  

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

__Executable Usage:__  

* `gem install churn`  
* go to project root run `churn`

__Rake Usage:__

* 'gem install churn'
* on any project you want to use churn, add "require 'churn'" to your rake file
* run 'rake churn' to view the current output, file churn history is immediate, class and method churn builds up a history as it is run on each revision
* temporary files with class / method churn history are stored in /tmp, to clear churn history delete them

__Options__

* option('minimum_churn_count', 'c')
    * the minimum number of changes on a file before counting it as churn (default is 3)       
* option('yaml', 'y')
    * output text or yaml (default false, ie text)
* option('ignore_files', 'i')
    * a string comma delimited of files to ignore (default '', example: 'Gemfile,Rakefile'
* example CLI call: `churn -i "Gemfile.lock, churn.gemspec"`

__TODO:__  

* SVN only supports file, add full SVN support 
* support bazaar, cvs, and darcs
* make storage directory configurable instead of using tmp
* allow passing in directories to churn, directories to ignore
* add a filter that allows for other files besides. *.rb
* ignore files pattern, so you can ignore things like vendor/, lib/, or docs/
* finish adding better documenation using YARD
* rake task for building manpage (currently manually run  ronn -b1 README.rdoc)
* bug that reports '/dev/null' as a file during revision changes
* don't output methods and classes on a commit that has none detected (css and view only commits, etc)

__Notes on Patches/Pull Requests__
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

__Copyright__

Copyright (c) 2012 Dan Mayer. See LICENSE for details.
