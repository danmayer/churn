module Churn

  class ChurnHistory
    
    def self.store_revision_history(revision, hash_data)
      FileUtils.mkdir 'tmp' unless File.directory?('tmp')
      File.open("tmp/#{revision}.json", 'w') {|f| f.write(hash_data.to_json) }
    end

    def self.load_revision_data(revision)
      #load revision data from scratch folder if it exists
      filename = "tmp/#{revision}.json"
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

  end

end
