# list of all the datasets to include in the parse - lifted from stagecraft datasets list

module PPDataSearcher

  # dataset config file location
  DATASET_CONFIG_FILE = "./config/dataset-config.json"
  
  EMPTY_STRING = ""
  
  # csv output constants
  CSV_HEADER = ["datagroup","datatype","published","tag","tag-type","element-type","type-count","value","value-count","min value","max value"]
  FILENAME_SEPARATOR = "-"
  DATA_DIRECTORY = "./data/"
  CSV_FILE_EXTENSION = ".csv"
  ALL_DATASET_TEXT = "all-datasets"

end