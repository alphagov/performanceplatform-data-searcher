require 'ppdatasearcher'
require "logging"
require 'jsongetter'
require 'ting'
require 'csvbuilder'

module PPDataSearcher

	class Builder
    
    include Logging
    
    def initialize(verbose) 
      @verbose = verbose
      @verbose ? logger.level=Logger::INFO : logger.level=Logger::ERROR
      @big_array = Array.new()
    end
    
    def build(dataset_list, dryrun, all_datasets_output = true)
      
      logger.info "PPDataSearcher::Builder:build"
      
      csv = PPDataSearcher::CsvBuilder.new(@verbose)
      
      #get each dataset as single processed json object
      dataset_list.each do | dataset |
        # get the data
        json_data = get_data(dataset["url"])
        
        dataset_name = dataset["datagroup"] + "-" + dataset["datatype"]
        
        dataset_hash = get_dataset_hash(dataset,json_data)
        
        logger.error "PPDataSearcher::Builder:build - dataset read error: #{dataset}" if dataset_hash["data"].has_key? "error"
        
        @big_array << dataset_hash
        
        unless all_datasets_output
          csv_records = csv.go @big_array, dryrun, dataset_name
          @big_array.clear
        end
      end
      
      @big_array
      
    end
    
    private
    
    def get_data(url)
      # query the dataset
      json_getter = JsonGetter.new @verbose
      json_getter.go url
    end

    def get_dataset_hash(dataset,data)
      dataset_hash = {
        "datagroup" => dataset["datagroup"] ||= "<unknown>",
        "datatype" => dataset["datatype"] ||= "<unknown>",
        "published" => dataset["published"],
        "data" => build_dataset_tree(data["data"])
      }
    end

    def build_dataset_tree(data)
      
      return {"error" => {}} if data.nil?  # no dataset
      return {"empty" => {}} if data[0].nil?  # empty dataset
        
      data_hash = Hash.new()
      
      data.each do | record |    
        record.each do | tag,val |
          if tag == "_id"
            tag_type,element_type = Ting.new.wassup(val,false) # only check for base64 encode on _id tag
          else
            tag_type,element_type = Ting.new.wassup(val)
          end
          
          record_hash = build_record_hash(tag,tag_type,element_type,val)
          
          include_flag= true
          
          case tag
          when "_day_start_at", "_hour_start_at", "_month_start_at", "_quarter_start_at", "_updated_at", "_week_start_at", "_year_start_at" # meta data tags :(
            include_flag = false
          when "humanId" # meta data tags - override what is recorded
            record_hash["element_type"] = "meta" # override what gets recorded
          when "_id" # override 'dimension' if value not base64 encoded
            record_hash["element_type"] = "key" 
          else # key, dimensions or metrics
            # carry on ...
          end
          add_record_to_data_tree(data_hash,record_hash) if include_flag
        end
      end
      
      data_hash
      
    end
    
    def build_record_hash(tag,tag_type,element_type, val)
      return {
        "tag" => tag ||= "<unknown>",
        "tag_type" => tag_type ||= "<unknown>",
        "element_type" => element_type ||= "<unknown>",
        "val" => val ||= "<unknown>"
      }
    end

    def add_record_to_data_tree(data_hash,record)
      
      unless data_hash.has_key?(record["tag"]) # create record based on tag - no content - tag value is the key itself
        data_hash[record["tag"]] = Hash.new()
      end
      
      tag_hash = data_hash[record["tag"]]
      
      unless tag_hash.has_key?(record["tag_type"]) # record_type key
        tag_hash[record["tag_type"]] = {"element_type" => record["element_type"],"count" => 0,"values" => Array.new}
      end
      
      #add values dependent on type
      tag_type_hash = tag_hash[record["tag_type"]]
      
      # populate as array of hash dependent on tag_type
      if record["element_type"] == "dimension" # keep all the values for dimension
        # find the index of the value (key of hash)
        value_index = tag_type_hash["values"].index { |k| k[0].has_key?(record["val"])}
        if value_index == nil
          tag_type_hash["values"] << [{record["val"] => 1},"",""]
        else
          tag_type_hash["values"][value_index][0][record["val"]] += 1
        end
      else # hold sample records, min and max for metrics
        if tag_type_hash["values"].empty? # create new array of values
          tag_type_hash["values"][0] = [{"<value>" => 1},record["val"],record["val"]]
        else # check and optional overwrite of existing values
          tag_type_hash["values"][0][0]["<value>"] += 1
          tag_type_hash["values"][0][1] = record["val"] < tag_type_hash["values"][0][1] ? record["val"] : tag_type_hash["values"][0][1]
          tag_type_hash["values"][0][2] = record["val"] > tag_type_hash["values"][0][2] ? record["val"] : tag_type_hash["values"][0][2]
        end
      end

      tag_type_hash["count"] += 1 #increment the count of number of records
      
    end

  end # of class

end # of module
