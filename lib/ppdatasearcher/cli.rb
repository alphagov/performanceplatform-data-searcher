require "ppdatasearcher"
require "version"
require "thor"
require "logging"
require "builder"
require 'csvbuilder'
require 'json'
require 'time'

module PPDataSearcher

  class CLI < Thor

    include Logging

    desc "go", "Reads all datasets specified in 'dataset-config.json' on the perfromance platform and for each outputs all keys, datatypes and discovered values in csv format to file"
    option :combined, :type => :boolean, :default =>true, :desc => "produces a single output csv file: <false> - csv file per dataset, <true> - single csv of all datasets"
    option :verbose, :type => :boolean, :default => false, :desc => "logs user messages to the console: <false> - errors only, <true> - info and errors"
    option :dryrun, :type => :boolean, :default => false, :desc => "outputs data records to console only: <false> - generates csv file(s), <true> - outputs data records to console only"

    def go()
      @verbose = options[:verbose] 

      # set logging level
      @verbose ? logger.level=Logger::INFO : logger.level=Logger::ERROR
      single_csv_output = options[:combined]
      dryrun = options[:dryrun]

      logger.info "PPDataSearcher::CLI:go:start: #{Time.now.utc.iso8601}"
      log_configuration_setup if @verbose

      # get the dataset list
      get_config
      
      builder = PPDataSearcher::Builder.new(@verbose)
      record_tree = builder.build @dataset_list, dryrun, single_csv_output
    
      if single_csv_output
        csv = PPDataSearcher::CsvBuilder.new(@verbose)
        csv_records = csv.go record_tree, dryrun, ALL_DATASET_TEXT
        csv_records.clear
      end
    
      logger.info "PPDataSearcher::CLI - Complete: #{Time.now.utc.iso8601}"
    
    end
 
    desc "version","Outputs the current version of the application"
    def version
      say "version: #{PPDataSearcher::VERSION}"
    end
  
    private
  
    # validate options
  
    def log_configuration_setup
      logger.info "logging: #{@verbose} level: #{logger.level}"
    end
    
    def get_config
      logger.info "PPDataSearcher::CLI:get dataset config"
      begin
        File.open(DATASET_CONFIG_FILE,"r") do |f|
          @dataset_list = JSON.load(f)
        end
      rescue => ex
        logger.error "PPDataSearcher::CLI:unable to get dataset config: Exception: #{ex.class}:#{ex}"
        # just absorb any exceptions
        @dataset_list = nil
      end
    end
    
  end
  
end