/*
prepare analytic data for each of 23 Low-value care service analyses
*/


/**************************************************
algorithm 1. PSA (PSA test)

Do not perform prostate-specific antigen (PSA) testing in men age 70 or older

Denominator: Men age 70 or older without prostate cancer, elevated PSA, or family history of prostate cancer
*/

%let vars_psa= desy_sort_key npi src bene_race_cd clm_dt DOB_DT GNDR_CD psa first_prostate_dx lvc; 

%macro prep_psa();
/* male, age >=70 */
data output.psa_sensitive(keep=&vars_psa);
set lvc_etl.claims_all_flag_firstDx;
lvc = psa;
if DOB_DT>=3 and GNDR_CD=1;
run;

/* no history of prostate cancer*/
data output.psa_specific;
set output.psa_sensitive;
if first_prostate_dx=. or clm_dt < first_prostate_dx;
run;

%patient_level_output(output.psa_sensitive, output.psa_sensitive_patient);
%patient_level_output(output.psa_specific, output.psa_specific_patient);
%mend prep_psa;

/********************************************************
algorithm 2. cerv (Cervical cancer screening)

Do not screen women age 65 or older for cervical cancer if they have had adequate prior screening and are not otherwise at high risk for cervical cancer

Denominator: Women age 65 or older and not at high risk for cervical cancer 
High risk indicators: history of cancer or dysplasia, diagnoses of other female genital cancers, abnormal Pap findings, HPV, 
diethylstilbestrol exposure, HIV/AIDS
*/

%let vars_cerv= desy_sort_key npi src bene_race_cd clm_dt DOB_DT GNDR_CD cerv first_cerv_ex lvc; 

%macro prep_cerv();
/*age 65+ , women*/
data output.cerv_sensitive(keep=&vars_cerv);
set lvc_etl.claims_all_flag_firstDx;
lvc = cerv;
if DOB_DT>=2 and GNDR_CD=2; 
run;

/* not at high risk for cervical cancer */
data output.cerv_specific;
set output.cerv_sensitive;
if first_cerv_ex=. or clm_dt < first_cerv_ex;
run;

%patient_level_output(output.cerv_sensitive, output.cerv_sensitive_patient);
%patient_level_output(output.cerv_specific, output.cerv_specific_patient);
%mend pre_cerv;


/**************************************************
algorithm 3: vd (vitamin D testing)

Do not perform vitamin D testing in non-high risk patients

Denominator: Patients that are not at high risk
High risk indicators: chronic kidney disease, hypercalcemia, chronic conditions, high risk medications, pregnancy, obesity, secondary hyperparathyroidism of renal origin, sarcoidosis, TB, other select neoplasms, diabetes, dialysis, osteoporosis, fragility fractures, fall/non-traumatic fracture

*/

%let vars_vd desy_sort_key npi src bene_race_cd clm_dt vitaminD_cpt first_chronic_dx last_other_risk_dx 
	pregnancy_obesity_dx_date last_fracture_vd lvc;

%macro prep_vd();
data output.vd_sensitive(keep=&vars_vd);
set lvc_etl.claims_all_flag_firstdx;
lvc = vitaminD_cpt;
run;

/* no chronic condition, 
no other risk factor or >90 days before test*,
not pregnant or clm_dt != pregancy_date 
no fracture or >365 days before test*/
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


/**************************************************
algorithm 4: imglbp (imaging for low back pain)

Don't do imaging for low back pain within the first six weeks, unless another diagnosis that warrants imaging is present

Denominator: Patients who reported having lower back pain and have no known possible cause
Known Possible Causes: cancer, external injury, trauma, IV drug abuse, neurologic impairment, osteomyelitis, fever, weight loss, malaise, night sweats, anemia not due to blood loss, myelopathy, neuritis, radiculopathy, tuberculosis, septicemia, endocarditis, intraspinal abscess
*/

%let vars_lbp desy_sort_key npi src bene_race_cd clm_dt imglbp last_imglbp_inc_dx last_imglbp_exc_dx lvc;

%macro prep_lbp();
/*imglbp_inclusion_dx Within 6 weeks before service*/
data output.imglbp_sensitive(keep=&vars_lbp);
set lvc_etl.claims_all_flag_firstdx;
lvc = imglbp;
if last_imglbp_inc_dx>. and clm_dt-last_imglbp_inc<=42;
run;

/*imglbp_exclusion_dx not within 6 weeks before service*/
data output.imglbp_specific;
set output.imglbp_sensitive;
if last_imglbp_exc_dx=. or clm_dt-last_imglbp_exc_dx>42;
run;

%patient_level_output(output.imglbp_sensitive, output.imglbp_sensitive_patient);
%patient_level_output(output.imglbp_specific, output.imglbp_specific_patient);
%mend prep_lbp;

/**************************************************
algorithm 5: crc (colorectal cancer screening)

Don't perform colorectal cancer screening for patients age 85 or older

Denominator: Patients age 85 or older without a history of colorectal cancer
*/

%let vars_crc desy_sort_key npi src bene_race_cd DOB_DT clm_dt crc crc_dx first_crc_cancer_dx lvc;

%macro prep_crc();
/* age >=85 */
data output.crc_sensitive(keep=&vars_crc);
set lvc_etl.claims_all_flag_firstDx;
lvc = (crc or crc_dx);
if DOB_DT=6;
run;

/* no crc cancer history */
data output.crc_specific;
set output.crc_sensitive;
if first_crc_cancer_dx=. or clm_dt < first_crc_cancer_dx;
run;

%patient_level_output(output.crc_sensitive, output.crc_sensitive_patient);
%patient_level_output(output.crc_specific, output.crc_specific_patient);
%mend prep_crc;

/**************************************************
algorithm 6: canscrn (cancer screening)

Don’t perform routine cancer screening for dialysis patients with limited life expectancy 

Denominator: Patients age 75 years or older and on dialysis
*/

%let vars_canscrn desy_sort_key npi src bene_race_cd DOB_DT clm_dt 
	canscrn canscrn_dx first_dialysis lvc;

%macro prep_canscrn();

/*age 75+ and on dialysis*/ 
data output.canscrn_sensitive(keep=&vars_canscrn);
set lvc_etl.claims_all_flag_firstDx;
lvc = (canscrn or canscrn_dx);
if DOB_DT>=4 and (first_dialysis>. and clm_dt>=first_dialysis); 
run;

%patient_level_output(output.canscrn_sensitive, output.canscrn_sensitive_patient);
%mend prep_canscrn;


/**************************************************
algorithm 7: bonemd (bone mineral density testing)

Don’t perform bone mineral density testing within 2 years of a prior bone mineral density test for patients with osteoporosis

Denominator: Patients with osteoporosis and without cancer or a fragility fracture
*/

%let vars_bonemd desy_sort_key npi src bene_race_cd clm_dt lvc bonemd prev_bonemd first_osteoporosis_dx first_cancer_dx last_fracture;

%macro prep_bonemd();

data output.bonemd_sensitive(keep=&vars_bonemd);
set lvc_etl.claims_all_flag_firstdx;
lvc=0;
if (bonemd=1 and (prev_bonemd>. and clm_dt-prev_bonemd<=730)) then lvc=1; /*LVC if within 2 years of a previous test*/
if first_osteoporosis_dx>. and clm_dt>=first_osteoporosis_dx; /*with osteoporosis*/ 
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

/**************************************************
algorithm 8: hypercoagula (hypercoagulability test)

Don’t perform  hypercoagulability test in patients with deep vein thrombosis (DVT) with a known cause
denominator: Patients with pulmonary embolism or venous embolism with thrombosis

*/

%let vars_hypercoagula desy_sort_key npi src bene_race_cd clm_dt hypercoagula first_embolism_dx last_embolism_dx lvc;

%macro prep_hypercoagula();
data output.hypercoagula_sensitive(keep=&vars_hypercoagula);
set lvc_etl.claims_all_flag_firstDx;
lvc=0;
if hypercoagula=1 and clm_dt-last_embolism_dx<=90 then lvc = 1;
if first_embolism_dx>.; /*Patients with pulmonary embolism  */ 
run;

%patient_level_output(output.hypercoagula_sensitive, output.hypercoagula_sensitive_patient);
%mend prep_hypercoagula;

/**************************************************
algorithm 9: t3 (T3 level)

Don’t perform a total or free T3 level when assessing levothyroxine (T4) dose in 
hypothyroid patients

denominator: Patients with hypothyroidism
*/

%let vars_t3 desy_sort_key npi src t3 bene_race_cd clm_dt first_hypothyroidism_dx last_hypothyroidism_dx lvc;

%macro prep_t3();
data output.t3_sensitive(keep=&vars_t3);
set lvc_etl.claims_all_flag_firstDx;
lvc=0;
if t3=1 and clm_dt-last_hypothyroidism_dx<=365 then lvc = 1;
if first_hypothyroidism_dx>.; /*Patients with hypothyroidism */ 
run;

%patient_level_output(output.t3_sensitive, output.t3_sensitive_patient);
%mend prep_t3;


/**************************************************
algorithm 10: xray (X-ray)

Do not perform a chest X-ray not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure
Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_xray desy_sort_key npi src bene_race_cd clm_dt lvc xray emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro prep_xray();

data output.xray_sensitive(keep=&vars_xray);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=0;
if xray=1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.; 
run;

/* not emergency care, not inpatient*/
data output.xray_specific;
set output.xray_sensitive;
if emergencycare=0 and (src in ('OP','CR'));
run;

%patient_level_output(output.xray_sensitive, output.xray_sensitive_patient);
%patient_level_output(output.xray_specific, output.xray_specific_patient);

%mend prep_xray;


/**************************************************
algorithm 11: echo (echocardiogram)

Do not perform an echocardiogram not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_echo desy_sort_key npi src bene_race_cd clm_dt lvc echocardiogram emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro prep_echo();

data output.echo_sensitive(keep=&vars_echo);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=0;
if echocardiogram =1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.; 
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.echo_specific;
set output.echo_sensitive;
if emergencycare=0 and (src in ('OP','CR'));;
run;

%patient_level_output(output.echo_sensitive, output.echo_sensitive_patient);
%patient_level_output(output.echo_specific, output.echo_specific_patient);

%mend prep_echo;


/**************************************************
algorithm 12: pft (pulmonary function test)

Do not perform a pulmonary function test (PFT) not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_pft desy_sort_key npi src bene_race_cd clm_dt lvc pulmonary emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro prep_pft();
data output.pft_sensitive(keep=&vars_pft);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=0;
if pulmonary =1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.; 
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.pft_specific;
set output.pft_sensitive;
if emergencycare=0 and (src ne 'IP');
run;

%patient_level_output(output.pft_sensitive, output.pft_sensitive_patient);
%patient_level_output(output.pft_specific, output.pft_specific_patient);

%mend prep_pft;

/**************************************************
algorithm 13: eenc (Electrocardiogram, Echocardiogram, Nuclear medicine imaging, Cardiac MRI or CT )

Do not perform electrocardiogram, echocardiogram, nuclear medicine imaging, cardiac MRI or CT angiography not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_eenc desy_sort_key npi src bene_race_cd clm_dt lvc eenc emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro prep_eenc();

data output.eenc_sensitive(keep=&vars_eenc);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=0;
if eenc =1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.;  
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.eenc_specific;
set output.eenc_sensitive;
if emergencycare=0 and (src ne 'IP');;
run;

%patient_level_output(output.eenc_sensitive, output.eenc_sensitive_patient);
%patient_level_output(output.eenc_specific, output.eenc_specific_patient);
%mend prep_eenc;


/*
Algorithm 14: mfct(maxillofacial CT study)

Do not perform maxillofacial CT study with a diagnosis of sinusitis and no other complications and no sinusitis diagnosis within 30 to 365 days before CT

Denominator: Patients with sinusitis and with no other related complications and with no prior sinusitis diagnosis
Other related complications: complications of sinusitis, immune deficiencies, nasal polyps, head/face trauma
*/

%let vars_mfct=desy_sort_key npi src bene_race_cd clm_dt lvc maxillofacialCT sinusitis_dx 
			   other_related_comp_dx last_sinusitis_dx;

%macro prep_mfct();

data output.mfct_sensitive(keep=&vars_mfct);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=0;
if maxillofacialCT=1 then lvc=1;
if sinusitis_dx=1; 
run;

data output.mfct_specific;
set output.mfct_sensitive;
/*no other complication and Prior sinusitis diagnosis not within 30 to 365 days before CT*/
if other_related_comp_dx=0 and 
(not (last_sinusitis_dx>. and 30<=(clm_dt - last_sinusitis_dx)<=365)); 
run;

%patient_level_output(output.mfct_sensitive, output.mfct_sensitive_patient);
%patient_level_output(output.mfct_specific, output.mfct_specific_patient);

%mend prep_mfct;


/*
Algorithm 15: headimg (CT or MRI of head or brain)

Do not perform CT or MRI imaging for a diagnosis of syncope without another diagnosis for warranted imaging

Denominator:Patients with syncope and without a diagnosis for warranted imaging. 
Diagnoses for warranted imaging: epilepsy or convulsions, cerebrovacular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA
*/

%let vars_headimg = desy_sort_key npi src bene_race_cd clm_dt lvc 
					headimg syncope_dx warranted_img_dx;

%macro prep_headimg();

data output.headimg_sensitive(keep=&vars_headimg);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=headimg;
if syncope_dx=1;	
run;

data output.headimg_specific;
set output.headimg_sensitive;
if warranted_img_dx=0;
run;

%patient_level_output(output.headimg_sensitive, output.headimg_sensitive_patient);
%patient_level_output(output.headimg_specific, output.headimg_specific_patient);

%mend prep_headimg;


/*
Algorithm 16: headimg2 (CT or MRI of head or brain)

Do not perform brain CT or MRI imaging for non-post-traumatic, nonthunderclap headache diagnosis without another diagnosis for warranted imaging.

Patients with headache and no other diagnosis for warranted imaging. Diagnoses for warranted imaging: post-tramatic or thunderclap headache, cancer, migraine with hemiplegia or infarction, giant cell arteritis, epilepsy or convulsions, cerebrovascular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA or cancer
*/

%let vars_headimg2 = desy_sort_key npi src bene_race_cd clm_dt lvc 
					headimg headache_dx warranted_img2_dx;

%macro prep_headimg2();

data output.headimg2_sensitive(keep=&vars_headimg2);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=headimg;
if headache_dx=1;	
run;

data output.headimg2_specific;
set output.headimg2_sensitive;
if warranted_img2_dx=0;
run;

%patient_level_output(output.headimg2_sensitive, output.headimg2_sensitive_patient);
%patient_level_output(output.headimg2_specific, output.headimg2_specific_patient);

%mend prep_headimg2;


/*
Algorithm 17: eeg (electroencephalogram)

Do not perform an EEG for headache diagnosis without epilepsy or convulsions noted in current or prior claims

Denominator:Patients with headaches and no indication of epilepsy or convulsions within 1 year before EEG and no other headache diagnosis within 2 years before EEG
*/

%let vars_eeg = desy_sort_key npi src bene_race_cd clm_dt lvc 
				eeg eeg_headache_dx last_eeg_headache_dx last_epilepsy_dx;

%macro prep_eeg();

data output.eeg_sensitive(keep=&vars_eeg);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=eeg;
if eeg_headache_dx=1;	
run;

data output.eeg_specific;
set output.eeg_sensitive;
if (last_eeg_headache_dx=. or clm_dt-last_eeg_headache_dx >730) and
	(last_epilepsy_dx=. or clm_dt-last_epilepsy_dx > 365);
run;

%patient_level_output(output.eeg_sensitive, output.eeg_sensitive_patient);
%patient_level_output(output.eeg_specific, output.eeg_specific_patient);

%mend prep_eeg;

/*
Algorithm 18: carotid (carotid imaging)

Do not perform carotid imaging not associated with inpatient or emergency care for patients without a stroke, TIA, or focal neurological symptom in claim

Denominator: NONE ?? Should we check history or just time in the same claim??
*/

%let vars_carotid = desy_sort_key npi src bene_race_cd clm_dt lvc 
				carotid emergencycare stroke_etc_dx;

%macro prep_carotid();

data output.carotid_sensitive(keep=&vars_carotid);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc=carotid and (src ne 'IP') and emergencycare=0;
run;

data output.carotid_specific;
set output.carotid_sensitive;
if stroke_etc_dx=0;
run;

%patient_level_output(output.carotid_sensitive, output.carotid_sensitive_patient);
%patient_level_output(output.carotid_specific, output.carotid_specific_patient);

%mend prep_carotid;

/*
Algorithm 19: carotidsyn (imaging of the carotid arteries for simply syncope) 

Do not perform imaging of the carotid arteries for simply syncope without other neurologic symptoms

Denominator: Patients with syncope and without other neurologic symptoms and no previous syncope diagnosis within 2 years before imaging
Other neurologic symptoms: without stroke or TIA, history of stroke or TIA, retinal vascular occlusion or ischemia, or nervous or musculoskeletal symptoms

*/

%let vars_carotidsyn = desy_sort_key npi src bene_race_cd clm_dt lvc 
				carotid syncope_dx last_syncope_dx prev_syncope_dx first_neurologic_dx;

%macro prep_carotidsyn();

data output.carotidsyn_sensitive(keep=&vars_carotidsyn);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc = carotid;
if last_syncope_dx>. and clm_dt-last_syncope_dx<=14;
run;

data output.carotidsyn_specific;
set output.carotidsyn_sensitive;
if first_neurologic_dx=.; 
run;

%patient_level_output(output.carotidsyn_sensitive, output.carotidsyn_sensitive_patient);
%patient_level_output(output.carotidsyn_specific, output.carotidsyn_specific_patient);

%mend prep_carotidsyn;


/*
algorithm 20: radio (radiographic or MR imaging)

Do not perform radiographic or MR imaging with diagnosis of plantar faciitis occuring within 2 weeks of initial foot pain diagnosis

Denominator: Patients with reported foot pain and with plantar fasciitis diagnosis within four weeks of initial foot pain
*/

%let vars_radio = desy_sort_key npi src bene_race_cd clm_dt lvc 
				radiographic next_plantarfasciitis_dx last_footpain_dx ;
%macro prep_radio();

data output.radio_sensitive(keep=&vars_radio);
set lvc_etl.claims_all_flag_firstdx_nextdx;
lvc = radiographic;

if (next_plantarfasciitis_dx>. and next_plantarfasciitis_dx-clm_dt<=14) and
   (last_footpain_dx>. and clm_dt- last_footpain_dx <=14);
run;


%patient_level_output(output.radio_sensitive, output.radio_sensitive_patient);

%mend prep_radio;


proc datasets library=output kill;
run;
quit;

/*1*/%prep_psa();
/*2*/%prep_cerv(); 
/*3*/%prep_vd();
/*4*/%prep_lbp();
/*5*/%prep_crc();
/*6*/%prep_canscrn();
/*7*/%prep_bonemd();
/*8*/%prep_hypercoagula();
/*9*/%prep_t3();
/*10*/%prep_xray();
/*11*/%prep_echo();
/*12*/%prep_pft();
/*13*/%prep_eenc();
/*14*/%prep_mfct();
/*15*/%prep_headimg();	
/*16*/%prep_headimg2();	
/*17*/%prep_eeg();	
/*18*/%prep_carotid();	
/*19*/%prep_carotidsyn();	
/*20*/%prep_radio();	
/*%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\output");*/
