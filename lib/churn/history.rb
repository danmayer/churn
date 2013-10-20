module Churn

  # responsible for storing the churn history to json,
  # and for loading old churn history data from json.
  class ChurnHistory

    #takes current revision and it's hash_data and stores it
    def self.store_revision_history(revision, hash_data)
      FileUtils.mkdir_p tmp_churn_directory unless File.directory?(tmp_churn_directory)
      File.open("#{tmp_churn_directory}/#{revision}.json", 'w') {|file| file.write(hash_data.to_json) }
    end
    
    #given a previous project revision find and load the churn data from a json file
    def self.load_revision_data(revision)
      #load revision data from scratch folder if it exists
      filename = "#{tmp_churn_directory}/#{revision}.json"
      if File.exists?(filename)
        begin
          json_data = File.read(filename)
          data      = JSON.parse(json_data)
          changed_files   = data['churn']['changed_files']
          changed_classes = data['churn']['changed_classes']
          changed_methods = data['churn']['changed_methods']
        rescue JSON::ParserError
          #leave all of the objects nil
        end
      end
      [changed_files, changed_classes, changed_methods]
    end

    def self.tmp_churn_directory
      ChurnOptions.instance.data_directory
    end

  end

end
