# LowValueCareCEVR
Low Value Care project at CEVR, Tufts Medical Center

### Source data
This project uses CMS LDS data, including inpatient data (100%, 2017-2020), outpatient data (100%, 2017-2020), carrier data (5%, 2017-2020). 
Each inpatient claim file consists of two files: inpatient base-claim file and inpatient revenue-center file. 
Each outpatient claim file consists of two files: outpatient base-claim file and outpatient revenue-center file.
Each carrier claim file consists of two files: carrier base-claim file and carrier line file. 

### Split large claim files by claim no. 
Due to the large size of a single claim file, the claim file needs to be split into smaller chunks before further processing. 

Each claim-base file will be divided into many smaller chunk files, each containing approximately 100,000 claims. 
The corresponding line/revenue file is also divided into smaller chunk files containing the same claim No. as in the corresponding claim basic chunk file.

### Transform claim file
merge claim-base file and line/revenue file into one claim file, with each record containing all ICD and HCPCS codes. 





