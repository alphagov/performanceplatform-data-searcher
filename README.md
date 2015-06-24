#performanceplatform-data-searcher

This repo holds a utility application for use with the [Performance Platform](https://www.gov.uk/performance).

The application:
* reads a list of dataset configurations from ./config/dataset-config.json
* extracts all data from an identified dataset using the platform 'Read API'
* parses each record to determine each key:value as a dimension or metric 
* creates a list of all key:values recording the set of dimensions and ranges of metrics for each dataset
* writes the output to a csv file in the ./data folder

##Purpose
This application is to allow interrogation of the types and structure of records stored on the platform 
 
##Running the application
Create an entry in the config file for any dataset to check:

```
[
    {
        "datagroup": "<datagroup name>", 
        "datatype": "<datatype>", 
        "url": "<Read API endpoint for the dataset", 
        "published": <true/false>
    },
    ...
]
```

To see the application run options:
```
$ ./bin/ppdatasearcher -h go
```

To run the application:
```
$ ./bin/ppdatasearcher go --combined=<combined-flag> --verbose=<verbose-flag> --dryrun=<dryrun-flag>
```
_combined_flag_ - create a file per dataset or a single file for all datasets

_verbose_flag_ - output info messages to the console

_dryrun_flag_ - output data to the console or file

_NOTE:_ 

If the dataset contains more than 20000 records, the underlying query to the platform will fail and an error will be recorded in the output file