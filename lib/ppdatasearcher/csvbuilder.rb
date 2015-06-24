require 'ppdatasearcher'
require 'csvwriter'
require "logging"
require 'csv'

module PPDataSearcher

	class CsvBuilder
    
    include Logging
    
    def initialize(verbose) 
      @verbose = verbose
      @verbose ? logger.level=Logger::INFO : logger.level=Logger::ERROR
    end
    
    def go(data_tree, dryrun, dataset_name="unknown")
      
      logger.info "PPDataSearcher::CsvBuilder:build"
      
      @csv_arr = Array.new()
      @csv_arr << CSV_HEADER
      
      @tree = data_tree

      #flatten the data
      traverse_hash
      filename = build_filename dataset_name
      
      # output the data
      csv_out = CsvWriter.new(@verbose)
      csv_out.go(@csv_arr,filename,dryrun)
      
      @success = csv_out.success?
      
      return @csv_arr
      
    end
    
    private
    
    def build_filename(dataset_name)
      return DATA_DIRECTORY + dataset_name + FILENAME_SEPARATOR + Time.now.utc.iso8601.gsub(/\W/,'') + CSV_FILE_EXTENSION
    end
    
    def traverse_hash()
      
      current_dataset = EMPTY_STRING
      
      begin
        @tree.each do | record |
          
          current_dataset = record["datagroup"] + ":" + record["datatype"] # only for error handling
          
          record_arr = Array.new()
          record_arr << record["datagroup"]
          record_arr << record["datatype"]
          record_arr << record["published"]
          # record_arr : [datagroup,datatype,published]
          if record["data"].count == 0
            @csv_arr << record_arr
            break
          end
          record["data"].each do | tag,tag_info |
            tag_arr = Array.new()
            tag_arr.replace(record_arr)
            tag_arr << tag
            # tag_arr : [datagroup,datatype,published,tag]
            if tag_info.count == 0
              @csv_arr << tag_arr
              break
            end
            tag_info.each do | element, element_info |
              element_arr = Array.new()
              element_arr.replace(tag_arr)
              element_arr << element
              if element_info.count == 0
                 @csv_arr << element_arr
                 break
              end
              element_arr << element_info["element_type"]
              element_arr << element_info["count"]
              # element_arr : [datagroup,datatype,published,tag,tag_type,element_type,count]
              if element_info["values"].count == 0
                 @csv_arr << element_arr
                 break
              end
              element_info["values"].each do | values |
                values_arr = Array.new()
                values_arr.replace(element_arr)
                if values.count == 0
                   @csv_arr << values_arr
                   break
                end
                values.each do | value |
                  if value.is_a?(Hash)
                    values_arr << value.flatten[0] << value.flatten[1]
                  else
                    values_arr << value
                  end
                end
                # values_arr : [datagroup,datatype,published,tag,tag_type,element_type,count,value, min value, max value]
                @csv_arr << values_arr
              end
            end
          end
        end
      rescue => ex
        logger.error "CsvBuilder:traverse_hash - failed to parse dataset: #{current_dataset}: Exception: #{ex.class}:#{ex}"
        @csv_arr.clear
      end
      
    end
    
  end
  
end
    

    
    
	
		