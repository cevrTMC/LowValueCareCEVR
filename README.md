
# LowValueCareCEVR

Low Value Care project at CEVR, Tufts Medical Center

## Source data

This project uses CMS LDS data, including inpatient data (100%,
2017-2020), outpatient data (100%, 2017-2020), and carrier data (5%,
2017-2020).

-   Each inpatient claim file consists of two files: inpatient
    base-claim file and inpatient revenue-center file.

-   Each outpatient claim file consists of two files: outpatient
    base-claim file and outpatient revenue-center file.

-   Each carrier claim file consists of two files: carrier base-claim
    file and carrier line file.

## Steps of Processing

### 1. Split claim files

Powershell code: **chunk.ps1**

Split a large claim file into smaller chunks. Each base-claim file is
divided into many smaller chunk files, with each chunk containing
approximately 1,000,000 claims. The line/revenue file is also divided
into smaller chunk files containing the same claims as in the
corresponding base-claim chunk file.

### 2. Transform claim files

SAS code: **01\_etl.sas**

Merge claim-base file and line/revenue file into one claim file, with
each record containing all ICD and HCPCS codes.

### 3. Flag conditions

SAS code: **02\_flag.sas**

Scan HCPCS/ICD-10/BETOS/DRG codes from inpatient/outpatient/carrier
claims for 84 comorbidities and creates variables to indicate each
condition found. The 84 conditions include 33 HCPCS conditions, 48 ICD
conditions, 2 BETOS conditions and 1 DRG condition.

Here is [list of conditions](tables/flag.md)

### 4. Split-Combine flag files by ID-group

SAS code: **03\_split\_combine.sas**

Each patient\_id is mapped to a id\_group based on last two digits of
id. Split each flag file by id\_group, then combine flag files that
belong to the same id\_group.

### 5. Create time variables

SAS code: **04\_time.sas**

Scan whole history of claims of each patient, then create time variables
for some conditions, including first condition date, last condition
date, previous condition date, next condition date.

### 6. Label Low-Value-Care

SAS code: **05\_alg.sas**

Label low-value-care based on various LVC definitions(algorithms).

Here is [list of algorithms](tables/alg.md)
