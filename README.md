# LowValueCareCEVR

Low Value Care project at CEVR, Tufts Medical Center

### Source data

This project uses CMS LDS data, including inpatient data (100%, 2017-2020), outpatient data (100%, 2017-2020), carrier data (5%, 2017-2020). Each inpatient claim file consists of two files: inpatient base-claim file and inpatient revenue-center file. Each outpatient claim file consists of two files: outpatient base-claim file and outpatient revenue-center file. Each carrier claim file consists of two files: carrier base-claim file and carrier line file.

### Split large claim files by claim no.

Due to the large size of a single claim file, the claim file needs to be split into smaller chunks before further processing.

Each claim-base file will be divided into many smaller chunk files, each containing approximately 100,000 claims. The corresponding line/revenue file is also divided into smaller chunk files containing the same claim No. as in the corresponding claim basic chunk file.

### Transform claim file

merge claim-base file and line/revenue file into one claim file, with each record containing all ICD and HCPCS codes.

### Flag conditions

This SAS macro scans HCPCS/ICD-10/BETOS/DRG codes from inpatient/outpatient/carrier claims for 84 comorbidities and creates variables to indicate each condition found. The 84 conditions include 33 HCPCS conditions, 48 ICD conditions, 2 BETOS conditions and 1 DRG condition.

There will be approximately 150 output files, including 48(4 years\*12 chunks) inpatient flag files, 48(4 year\*12 chunks) outpatient flag files, and 48 (4 year\*12 chunks) carrier flag files.

+------------+-----------------------------+
| Type       | Output Flag Files           |
+============+=============================+
| Inpatient  | IP\_[year]\_[chunkid]\_flag |
+------------+-----------------------------+
| Outpatient | OP\_[year]\_[chunkid]\_flag |
+------------+-----------------------------+
| Carrier    | CR\_[year]\_[chunkid]\_flag |
+------------+-----------------------------+

note: year=2017,2018,2019,2020, chunkid=1-12

### Split-Merge flag files by bene_id

It is not possible to simply combine all the year and type files into one large combined flags file that is too large to handle in SAS. Each flag file needs to be split by bene_id, so flag files of a subgroup of bene_ids can be combined, resulting in a smaller combined flag file that SAS can process separately.

### Create Date variables

The Low-Value-Care algorithm need the check individual's claim history of conditions.

+--------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SAS macro          | Description                                                                                                                                                            |
+====================+========================================================================================================================================================================+
| firstLastPrevDates | This SAS macro create variables for the earliest date, the last date, and the previous date of each of 35 conditions, which will be used in low-value-care algorithms. |
+--------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| nextDate           | This SAS macro create variables for the next date of each of 3 conditions, which will be used in some low-value-care algorithms                                        |
+--------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

### Label Low-Value-Care

This step labels low-value care based on various LVC definitions(algorithm).

The input file for each LVC algorithm is "claims_all_flag\_[chunkid]\_FLPDx_nextDx.sas8bdat" which is the output of the "Create Date Variables"" step.

+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| No. | SAS macro          | Description                                                                                                                                                                                                                                           |
+=====+====================+=======================================================================================================================================================================================================================================================+
| 1   | alg_psa            | prostate-specific antigen (PSA) testing in men age 70 or older                                                                                                                                                                                        |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 2   | alg_cerv           | screen women age 65 or older for cervical cancer if they have had adequate prior screening and are not otherwise at high risk for cervical cancer                                                                                                     |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 3   | alg_vd             | vitamin D testing in non-high risk patients                                                                                                                                                                                                           |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 4   | alg_lbp            | imaging for low back pain within the first six weeks, unless another diagnosis that warrants imaging is present                                                                                                                                       |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 5   | alg_crc            | colorectal cancer screening for patients age 85 or older                                                                                                                                                                                              |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 6   | alg_canscrn        | routine cancer screening for dialysis patients with limited life expectancy                                                                                                                                                                           |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 7   | alg_bonemd         | bone mineral density testing within 2 years of a prior bone mineral density test for patients with osteoporosis                                                                                                                                       |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 8   | alg_hypercoagula   | hypercoagulability test in patients with deep vein thrombosis (DVT) with a known cause                                                                                                                                                                |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 9   | alg_t3             | total or free T3 level when assessing levothyroxine (T4) dose in hypothyroid patients                                                                                                                                                                 |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 10  | alg_xray           | chest X-ray not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure patients undergoing low or intermediate risk non-cardiothoracic surgical procedure |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 11  | alg_echo           | echocardiogram not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure                                                                                 |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 12  | alg_pft            | pulmonary function test (PFT) not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure                                                                  |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 13  | alg_eenc           | electrocardiogram, echocardiogram, nuclear medicine imaging, cardiac MRI or CT angiography not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure     |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 14  | alg_mfct           | maxillofacial CT study with a diagnosis of sinusitis and no other complications and no sinusitis diagnosis within 30 to 365 days before CT                                                                                                            |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 15  | alg_headimg        | CT or MRI imaging for a diagnosis of syncope without another diagnosis for warranted imaging                                                                                                                                                          |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 16  | alg_headimg2       | brain CT or MRI imaging for non-post-traumatic, nonthunderclap headache diagnosis without another diagnosis for warranted imaging.                                                                                                                    |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 17  | alg_eeg            | EEG for headache diagnosis without epilepsy or convulsions noted in current or prior claims                                                                                                                                                           |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 18  | alg_carotid        | carotid imaging not associated with inpatient or emergency care for patients without a stroke, TIA, or focal neurological symptom in claim                                                                                                            |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 19  | alg_carotidsyn     | imaging of the carotid arteries for simply syncope without other neurologic symptoms                                                                                                                                                                  |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 20  | alg_radio          | radiographic or MR imaging with diagnosis of plantar faciitis occuring within 2 weeks of initial foot pain diagnosis                                                                                                                                  |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 21  | alg_stress         | stress testing not associated with inpatient or emergency care for patients with an established diagnosis of acute myocardial infraction                                                                                                              |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 22  | alg_endarterectomy | carotid endarterectomy (CEA), not associated with an ER visit, for patients without a history of stroke or TIA and without stroke, TIA, or focal neurological symptoms noted in claim                                                                 |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 23  | alg_homocysteine   | homocysteine testing with no diagnoses of folate or B12 deficiencies in the claim                                                                                                                                                                     |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 24  | alg_pth            | parathyroid hormone (PTH) measurement for patients with chronic kidney disease and no dialysis services before PTH testing or within 30 days following testing, as well as no hypercalcemia diagnosis during the year                                 |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 25  | alg_pci            | percutaneous coronary intervention (PCI) with balloon angioplasty or stent placement, not associated with an ER visit, for patients with stable coronary disease                                                                                      |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 26  | alg_angioplasty    | renal/visceral angioplasty or stent placement with a diagnosis of renal atherosclerosis or renovascular hypertension noted in procedure claim                                                                                                         |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 27  | alg_ivc            | inferior vena cava(IVC) filter placement in patients without pulmonary embolism or deep vein thrombosis                                                                                                                                               |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 28  | alg_cathe          | pulmonary artery cathe for monitoring purposes during an inpatient stay that involved an ICU and a nonsurgical MS-DRG and when the claim contains no diagnoses indicating pulmonary hypertension, cardiac tamponade, or preoperative assessment       |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 29  | alg_verte          | vertebroplasty or kyphoplasty for osteoporotic vertebral fracture with no bone cancers, myeloma, or hemangioma                                                                                                                                        |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 30  | alg_knee           | arthroscopic debridement / chondroplasty of the knee for patients with diagnosis of osteoarthritis or chondromalacia and no meniscal tears                                                                                                            |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 31  | alg_inject         | outpatient epidural, facet, or trigger point injections for lower back pain, excluding etanercept, for patients with no radiculopathy diagnoses in the claim                                                                                          |
+-----+--------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
