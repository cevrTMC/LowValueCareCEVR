/*
prepare analytic data for statistical analysis

*/


libname output ("C:\Users\lliang1\Documents\My SAS Files\9.4\output");

/*1. PSA 
Do not perform prostate-specific antigen (PSA) testing in men age 70 or older
Men age 70 or older without prostate cancer, elevated PSA, or family history of prostate cancer
*/

%let vars_psa= desy_sort_key npi src bene_race_cd clm_dt DOB_DT GNDR_CD psa first_prostate_dx lvc; 

%macro prep_psa();
/* male, age >=70, claim from OP only */
data output.psa_sensitive(keep=&vars_psa);
set lvc_etl.claims_all_flag_firstDx;
lvc = psa;
if DOB_DT>=3 and GNDR_CD=1;
run;

/* exclude those with history of prostate cancer*/
data output.psa_specific;
set output.psa_sensitive;
if first_prostate_dx=. or clm_dt < first_prostate_dx;
run;

%patient_level_output(output.psa_sensitive, output.psa_sensitive_patient);
%patient_level_output(output.psa_specific, output.psa_specific_patient);
%mend prep_psa;

/********************************************************
/* cerv 
Cervical cancer screening
Do not screen women age 65 or older for cervical cancer if they have had adequate prior screening and are not otherwise at high risk for cervical cancer
Setting: OP
*/

%let vars_cerv= desy_sort_key npi src bene_race_cd clm_dt DOB_DT GNDR_CD cerv first_cerv_ex lvc; 

%macro prep_cerv();
/*age 65+ , women*/
data output.cerv_sensitive(keep=&vars_cerv);
set lvc_etl.claims_all_flag_firstDx;
lvc = cerv;
if DOB_DT>=2 and GNDR_CD=2; 
run;

/* exclude those with dgns since 2017*/
data output.cerv_specific;
set output.cerv_sensitive;
if first_cerv_ex=. or clm_dt < first_cerv_ex;
run;

%patient_level_output(output.cerv_sensitive, output.cerv_sensitive_patient);
%patient_level_output(output.cerv_specific, output.cerv_specific_patient);
%mend pre_cerv;


/*
algorithm 3: vd

Do not perform vitamin D testing in non-high risk patients

Patients that are not at high risk
High risk indicators: chronic kidney disease, hypercalcemia, chronic conditions, high risk medications, pregnancy, obesity, secondary hyperparathyroidism of renal origin, sarcoidosis, TB, other select neoplasms, diabetes, dialysis, osteoporosis, fragility fractures, fall/non-traumatic fracture

*/

%let vars_vd desy_sort_key npi src bene_race_cd clm_dt vitaminD_cpt first_chronic_dx last_other_risk_dx 
	pregnancy_obesity_dx_date last_fracture_vd lvc;

%macro prep_vd();
data output.vd_sensitive(keep=&vars_vd);
set lvc_etl.claims_all_flag_firstdx;
lvc = vitaminD_cpt;
run;

data output.vd_specific;
set output.vd_sensitive;
if (missing(first_chronic_dx) or clm_dt<first_chronic_dx) and 
	(missing(last_other_risk_dx) or clm_dt-last_other_risk_dx>90) and 
	(missing(last_fracture_vd) or clm_dt-last_fracture_vd>365) and 
	(missing(pregnancy_obesity_dx_date) or clm_dt ne pregnancy_obesity_dx_date);
run;

%patient_level_output(output.vd_sensitive, output.vd_sensitive_patient);
%patient_level_output(output.vd_specific, output.vd_specific_patient);
%mend prep_vd;


/*
alg 4 : imaging for low back pain

Don't do imaging for low back pain within the first six weeks, unless another diagnosis that warrants imaging is present

Patients who reported having lower back pain and have no known possible cause
Known Possible Causes: cancer, external injury, trauma, IV drug abuse, neurologic impairment, osteomyelitis, fever, weight loss, malaise, night sweats, anemia not due to blood loss, myelopathy, neuritis, radiculopathy, tuberculosis, septicemia, endocarditis, intraspinal abscess

*/

%let vars_lbp desy_sort_key npi src bene_race_cd clm_dt imglbp last_imglbp_inc_dx last_imglbp_exc_dx lvc;

%macro prep_lbp();
data output.imglbp_sensitive(keep=&vars_lbp);
set lvc_etl.claims_all_flag_firstdx;
lvc = imglbp;
if last_imglbp_inc_dx>. and clm_dt-last_imglbp_inc<=42;
run;

data output.imglbp_specific;
set output.imglbp_sensitive;
if last_imglbp_exc_dx=. or clm_dt-last_imglbp_exc_dx>42;
run;

%patient_level_output(output.imglbp_sensitive, output.imglbp_sensitive_patient);
%patient_level_output(output.imglbp_specific, output.imglbp_specific_patient);
%mend prep_lbp;

/*
colorectal cancer screening

Don't perform colorectal cancer screening for patients age 85 or older
Patients age 85 or older without a history of colorectal cancer
*/


/* age >=85 DOB_DT 6(>=84)*/

%let vars_crc desy_sort_key npi src bene_race_cd DOB_DT clm_dt crc crc_dx first_crc_cancer_dx lvc;

%macro prep_crc();
data output.crc_sensitive(keep=&vars_crc);
set lvc_etl.claims_all_flag_firstDx;
lvc = (crc or crc_dx);
if DOB_DT=6;
run;

/* exclude those with dgns history*/
data output.crc_specific;
set output.crc_sensitive;
if first_crc_cancer_dx=. or clm_dt < first_crc_cancer_dx;
run;

%patient_level_output(output.crc_sensitive, output.crc_sensitive_patient);
%patient_level_output(output.crc_specific, output.crc_specific_patient);
%mend prep_crc;

/*
cancer screening

denominator: Patients age 75 years or older and on dialysis

issues: 
no dx code 'Z49' found 
no prcd code 'PA9','P9B' found

*/

%let vars_canscrn desy_sort_key npi src bene_race_cd DOB_DT clm_dt 
	canscrn canscrn_dx first_dialysis lvc;

%macro prep_canscrn();
data output.canscrn_sensitive(keep=&vars_canscrn);
set lvc_etl.claims_all_flag_firstDx;
lvc = (canscrn or canscrn_dx);
if DOB_DT>=4 and (not missing(first_dialysis) and clm_dt>first_dialysis); /*age 75+ and no history of dialysis*/ 
run;

%patient_level_output(output.canscrn_sensitive, output.canscrn_sensitive_patient);
%mend prep_canscrn;


/*
bonemd
Don’t perform bone mineral density testing within 2 years of a prior bone mineral density test for patients with osteoporosis

Patients with osteoporosis and without cancer or a fragility fracture
*/

%let vars_bonemd desy_sort_key npi src bene_race_cd clm_dt lvc bonemd prev_bonemd first_osteoporosis_dx first_cancer_dx last_fracture;

%macro prep_bonemd();
data output.bonemd_sensitive(keep=&vars_bonemd);
set lvc_etl.claims_all_flag_firstdx;
if (bonemd=1 and (prev_bonemd>. and clm_dt-prev_bonemd<=730)) then lvc=1;
if first_osteoporosis_dx>. and clm_dt>first_osteoporosis_dx; 
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.bonemd_specific;
set output.bonemd_sensitive;
if (first_cancer_dx=. or clm_dt<first_cancer_dx) and 
 (last_fracture=. or clm_dt - last_fracture>730); 
run;

%patient_level_output(output.bonemd_sensitive, output.bonemd_sensitive_patient);
%patient_level_output(output.bonemd_specific, output.bonemd_specific_patient);
%mend prep_bonemd;

/*

hypercoagula

Don’t perform  hypercoagulability test in patients with deep vein thrombosis (DVT) with a known cause

denominator: Patients with pulmonary embolism or venous embolism with thrombosis

*/

%let vars_hypercoagula desy_sort_key npi src bene_race_cd clm_dt hypercoagula first_embolism_dx last_embolism_dx lvc;

%macro prep_hypercoagula();
data output.hypercoagula_sensitive(keep=&vars_hypercoagula);
set lvc_etl.claims_all_flag_firstDx;
if hypercoagula=1 and clm_dt-last_embolism_dx<=90 then lvc = 1;
if first_embolism_dx>.; /*Patients with pulmonary embolism  */ 
run;

%patient_level_output(output.hypercoagula_sensitive, output.hypercoagula_sensitive_patient);
%mend prep_hypercoagula;

/*
t3
Don’t perform a total or free T3 level when assessing levothyroxine (T4) dose in 
hypothyroid patients

denominator: Patients with hypothyroidism

*/

%let vars_t3 desy_sort_key npi src t3 bene_race_cd clm_dt first_hypothyroidism_dx last_hypothyroidism_dx lvc;

%macro prep_t3();
data output.t3_sensitive(keep=&vars_t3);
set lvc_etl.claims_all_flag_firstDx;
if t3=1 and clm_dt-last_hypothyroidism_dx<=365 then lvc = 1;
if first_hypothyroidism_dx>.; /*Patients with hypothyroidism */ 
run;

%patient_level_output(output.t3_sensitive, output.t3_sensitive_patient);
%mend prep_t3;




%prep_psa();
%prep_cerv(); 
%prep_vd();
%prep_lbp();
%prep_crc();
%prep_canscrn();
%prep_bonemd();
%prep_hypercoagula();
%prep_t3();

%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\output");
