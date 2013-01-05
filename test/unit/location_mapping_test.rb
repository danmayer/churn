require File.expand_path('../test_helper', File.dirname(__FILE__))

class LocationMappingTest < Test::Unit::TestCase

  #todo unfortunately it looks like ruby parser can't handle construct tmp dirs
  #<Pathname:/private/var/folders/gl/glhHkYYSGgG5nb6+4OG0yU+++TI/-Tmp-/construct_container-56784-851001101/fake_class.rb>
  #(rdb:1) p locationmapping.get_info(file.to_s)
  #RegexpError Exception: invalid regular expression; there's no previous pattern, to which '+' would define cardinality at 2: /^+++/

  should "location_mapping gets correct file classes info" do
    file = 'test/data/churn_calculator.rb'
    locationmapping = Churn::LocationMapping.new
    locationmapping.get_info(file.to_s)
    klass_hash = {"ChurnCalculator"=>[14..213]}
    assert_equal klass_hash, locationmapping.klasses_collection
  end

  should "location_mapping gets correct methods info" do
    file = 'test/data/churn_calculator.rb'
    locationmapping = Churn::LocationMapping.new
    locationmapping.get_info(file.to_s)
    methods_hash = {"ChurnCalculator#report"=>[32..36], "ChurnCalculator#emit"=>[38..41], "ChurnCalculator#changes_for_type"=>[139..155], "ChurnCalculator#get_klass_for"=>[135..137], "ChurnCalculator#calculate_changes!"=>[109..116], "ChurnCalculator#analyze"=>[43..53], "ChurnCalculator#calculate_revision_data"=>[95..107], "ChurnCalculator#calculate_revision_changes"=>[78..92], "ChurnCalculator#parse_logs_for_updated_files"=>[171..213], "ChurnCalculator#to_h"=>[55..70], "ChurnCalculator#parse_log_for_revision_changes"=>[167..169], "ChurnCalculator#get_changes"=>[118..133], "ChurnCalculator#parse_log_for_changes"=>[157..165], "ChurnCalculator#initialize"=>[16..30]}
    assert_equal methods_hash.sort, locationmapping.methods_collection.sort
  end

  should "location_mapping gets correct classes info for test helper files" do
    file = 'test/data/test_helper.rb'
    locationmapping = Churn::LocationMapping.new
    locationmapping.get_info(file.to_s)
    klass_hash = {"TestCase"=>[12..15]}
    assert_equal klass_hash.sort, locationmapping.klasses_collection.sort
  end

end

