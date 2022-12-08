/*
Low value care algorithms 
*/

%let vars_base= desy_sort_key npi src bene_race_cd clm_dt DOB_DT GNDR_CD;
%let inputdata= date.sub_0_flag_first_next;

proc datasets library=output kill;
run;
quit;

/**************************************************
algorithm 1. PSA (PSA test)

Do not perform prostate-specific antigen (PSA) testing in men age 70 or older

Denominator: Men age 70 or older without prostate cancer, elevated PSA, or family history of prostate cancer
*/

%let vars_psa= &vars_base psa prostate_dx first_prostate_dx lvc; 

%macro alg_psa(input);
/* male, age >=70 */
data output.psa_sensitive(keep=&vars_psa);
set &input;
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

%mend alg_psa;

/********************************************************
algorithm 2. cerv (Cervical cancer screening)

Do not screen women age 65 or older for cervical cancer if they have had adequate prior screening and are not otherwise at high risk for cervical cancer

Denominator: Women age 65 or older and not at high risk for cervical cancer 
High risk indicators: history of cancer or dysplasia, diagnoses of other female genital cancers, abnormal Pap findings, HPV, 
diethylstilbestrol exposure, HIV/AIDS
*/

%let vars_cerv= &vars_base cerv cerv_ex first_cerv_ex lvc; 

%macro alg_cerv(input);
/*age 65+ , women*/
data output.cerv_sensitive(keep=&vars_cerv);
set &input;
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

%let vars_vd &vars_base vitaminD_cpt chronic_dx first_chronic_dx 
		other_risk_dx last_other_risk_dx 
	pregnancy_obesity_dx_date fracture_vd last_fracture_vd lvc;

%macro alg_vd(input);
data output.vd_sensitive(keep=&vars_vd);
set &input;
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
%mend alg_vd;


/**************************************************
algorithm 4: imglbp (imaging for low back pain)

Don't do imaging for low back pain within the first six weeks, unless another diagnosis that warrants imaging is present

Denominator: Patients who reported having lower back pain and have no known possible cause
Known Possible Causes: cancer, external injury, trauma, IV drug abuse, neurologic impairment, osteomyelitis, fever, weight loss, malaise, night sweats, anemia not due to blood loss, myelopathy, neuritis, radiculopathy, tuberculosis, septicemia, endocarditis, intraspinal abscess
*/

%let vars_lbp &vars_base imglbp imglbp_inc_dx last_imglbp_inc_dx 
			imglbp_exc_dx last_imglbp_exc_dx lvc;

%macro alg_lbp(input);
/*imglbp_inclusion_dx Within 6 weeks before service*/
data output.lbp_sensitive(keep=&vars_lbp);
set &input;
lvc = imglbp;
if last_imglbp_inc_dx>. and clm_dt-last_imglbp_inc<=42;
run;

/*imglbp_exclusion_dx not within 6 weeks before service*/
data output.lbp_specific;
set output.lbp_sensitive;
if last_imglbp_exc_dx=. or clm_dt-last_imglbp_exc_dx>42;
run;

%patient_level_output(output.lbp_sensitive, output.lbp_sensitive_patient);
%patient_level_output(output.lbp_specific, output.lbp_specific_patient);
%mend alg_lbp;

/**************************************************
algorithm 5: crc (colorectal cancer screening)

Don't perform colorectal cancer screening for patients age 85 or older

Denominator: Patients age 85 or older without a history of colorectal cancer
*/

%let vars_crc &vars_base crc crc_dx crc_cancer_dx first_crc_cancer_dx lvc;

%macro alg_crc(input);
/* age >=85 */
data output.crc_sensitive(keep=&vars_crc);
set &input;
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
%mend alg_crc;

/**************************************************
algorithm 6: canscrn (cancer screening)

Don’t perform routine cancer screening for dialysis patients with limited life expectancy 

Denominator: Patients age 75 years or older and on dialysis
*/

%let vars_canscrn &vars_base canscrn canscrn_dx dialysis first_dialysis lvc;

%macro alg_canscrn(input);

/*age 75+ and on dialysis*/ 
data output.canscrn_sensitive(keep=&vars_canscrn);
set &input;
lvc = (canscrn or canscrn_dx);
if DOB_DT>=4 and (first_dialysis>. and clm_dt>=first_dialysis); 
run;

data output.canscrn_specific;
set output.canscrn_sensitive;
run;

%patient_level_output(output.canscrn_sensitive, output.canscrn_sensitive_patient);
%patient_level_output(output.canscrn_specific, output.canscrn_specific_patient);

%mend alg_canscrn;


/**************************************************
algorithm 7: bonemd (bone mineral density testing)

Don’t perform bone mineral density testing within 2 years of a prior bone mineral density test for patients with osteoporosis

Denominator: Patients with osteoporosis and without cancer or a fragility fracture
*/

%let vars_bonemd &vars_base lvc bonemd prev_bonemd 
		osteoporosis_dx first_osteoporosis_dx 
		cancer_dx first_cancer_dx 
		fracture last_fracture;

%macro alg_bonemd(input);

data output.bonemd_sensitive(keep=&vars_bonemd);
set &input;
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
%mend alg_bonemd;

/**************************************************
algorithm 8: hypercoagula (hypercoagulability test)

Don’t perform  hypercoagulability test in patients with deep vein thrombosis (DVT) with a known cause
denominator: Patients with pulmonary embolism or venous embolism with thrombosis

*/

%let vars_hypercoagula= &vars_base hypercoagula 
				embolism_dx first_embolism_dx last_embolism_dx lvc;

%macro alg_hypercoagula(input);
data output.hypercoagula_sensitive(keep=&vars_hypercoagula);
set &input;
lvc=0;
if hypercoagula=1 and clm_dt-last_embolism_dx<=90 then lvc = 1;
if first_embolism_dx>.; /*Patients with pulmonary embolism  */ 
run;

data output.hypercoagula_specific;
set output.hypercoagula_sensitive;
run;

%patient_level_output(output.hypercoagula_sensitive, output.hypercoagula_sensitive_patient);
%patient_level_output(output.hypercoagula_specific, output.hypercoagula_specific_patient);
%mend alg_hypercoagula;

/**************************************************
algorithm 9: t3 (T3 level)

Don’t perform a total or free T3 level when assessing levothyroxine (T4) dose in 
hypothyroid patients

denominator: Patients with hypothyroidism
*/

%let vars_t3= &vars_base hypothyroidism_dx first_hypothyroidism_dx last_hypothyroidism_dx lvc;

%macro alg_t3(input);
data output.t3_sensitive(keep=&vars_t3);
set &input;
lvc=0;
if t3=1 and clm_dt-last_hypothyroidism_dx<=365 then lvc = 1;
if first_hypothyroidism_dx>.; /*Patients with hypothyroidism */ 
run;

data output.t3_specific;
set output.t3_sensitive;
run;

%patient_level_output(output.t3_sensitive, output.t3_sensitive_patient);
%patient_level_output(output.t3_specific, output.t3_specific_patient);
%mend alg_t3;


/**************************************************
algorithm 10: xray (X-ray)

Do not perform a chest X-ray not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure
Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_xray= &vars_base lvc xray emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_xray(input);

data output.xray_sensitive(keep=&vars_xray);
set &input;
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

%mend alg_xray;


/**************************************************
algorithm 11: echo (echocardiogram)

Do not perform an echocardiogram not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_echo= &vars_base lvc echocardiogram emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_echo(input);

data output.echo_sensitive(keep=&vars_echo);
set &input;
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

%mend alg_echo;


/**************************************************
algorithm 12: pft (pulmonary function test)

Do not perform a pulmonary function test (PFT) not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_pft=&vars_base lvc pulmonary emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_pft(input);
data output.pft_sensitive(keep=&vars_pft);
set &input;
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

%mend alg_pft;

/**************************************************
algorithm 13: eenc (Electrocardiogram, Echocardiogram, Nuclear medicine imaging, Cardiac MRI or CT )

Do not perform electrocardiogram, echocardiogram, nuclear medicine imaging, cardiac MRI or CT angiography not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_eenc = &vars_base lvc eenc emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_eenc(input);

data output.eenc_sensitive(keep=&vars_eenc);
set &input;
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
%mend alg_eenc;


/*
Algorithm 14: mfct(maxillofacial CT study)

Do not perform maxillofacial CT study with a diagnosis of sinusitis and no other complications and no sinusitis diagnosis within 30 to 365 days before CT

Denominator: Patients with sinusitis and with no other related complications and with no prior sinusitis diagnosis
Other related complications: complications of sinusitis, immune deficiencies, nasal polyps, head/face trauma
*/

%let vars_mfct=&vars_base lvc maxillofacialCT sinusitis_dx 
			   other_related_comp_dx sinusitis_dx last_sinusitis_dx;

%macro alg_mfct(input);

data output.mfct_sensitive(keep=&vars_mfct);
set &input;
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

%mend alg_mfct;


/*
Algorithm 15: headimg (CT or MRI of head or brain)

Do not perform CT or MRI imaging for a diagnosis of syncope without another diagnosis for warranted imaging

Denominator:Patients with syncope and without a diagnosis for warranted imaging. 
Diagnoses for warranted imaging: epilepsy or convulsions, cerebrovacular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA
*/

%let vars_headimg = &vars_base lvc 
					headimg syncope_dx warranted_img_dx;

%macro alg_headimg(input);

data output.headimg_sensitive(keep=&vars_headimg);
set &input;
lvc=headimg;
if syncope_dx=1;	
run;

data output.headimg_specific;
set output.headimg_sensitive;
if warranted_img_dx=0;
run;

%patient_level_output(output.headimg_sensitive, output.headimg_sensitive_patient);
%patient_level_output(output.headimg_specific, output.headimg_specific_patient);

%mend alg_headimg;


/*
Algorithm 16: headimg2 (CT or MRI of head or brain)

Do not perform brain CT or MRI imaging for non-post-traumatic, nonthunderclap headache diagnosis without another diagnosis for warranted imaging.

Patients with headache and no other diagnosis for warranted imaging. Diagnoses for warranted imaging: post-tramatic or thunderclap headache, cancer, migraine with hemiplegia or infarction, giant cell arteritis, epilepsy or convulsions, cerebrovascular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA or cancer
*/

%let vars_headimg2 = &vars_base lvc 
					headimg headache_dx warranted_img2_dx;

%macro alg_headimg2(input);

data output.headimg2_sensitive(keep=&vars_headimg2);
set &input;
lvc=headimg;
if headache_dx=1;	
run;

data output.headimg2_specific;
set output.headimg2_sensitive;
if warranted_img2_dx=0;
run;

%patient_level_output(output.headimg2_sensitive, output.headimg2_sensitive_patient);
%patient_level_output(output.headimg2_specific, output.headimg2_specific_patient);

%mend alg_headimg2;


/*
Algorithm 17: eeg (electroencephalogram)

Do not perform an EEG for headache diagnosis without epilepsy or convulsions noted in current or prior claims

Denominator:Patients with headaches and no indication of epilepsy or convulsions within 1 year before EEG and no other headache diagnosis within 2 years before EEG
*/

%let vars_eeg = &vars_base lvc 
				eeg eeg_headache_dx last_eeg_headache_dx epilepsy_dx last_epilepsy_dx;

%macro alg_eeg(input);

data output.eeg_sensitive(keep=&vars_eeg);
set &input;
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

%mend alg_eeg;

/*
Algorithm 18: carotid (carotid imaging)

Do not perform carotid imaging not associated with inpatient or emergency care for patients without a stroke, TIA, or focal neurological symptom in claim

Denominator: NONE ?? Should we check history or just time in the same claim??
*/

%let vars_carotid = &vars_base lvc 
				carotid emergencycare stroke_etc_dx;

%macro alg_carotid(input);

data output.carotid_sensitive(keep=&vars_carotid);
set &input;
lvc=carotid and (src ne 'IP') and emergencycare=0;
run;

data output.carotid_specific;
set output.carotid_sensitive;
if stroke_etc_dx=0;
run;

%patient_level_output(output.carotid_sensitive, output.carotid_sensitive_patient);
%patient_level_output(output.carotid_specific, output.carotid_specific_patient);

%mend alg_carotid;

/*
Algorithm 19: carotidsyn (imaging of the carotid arteries for simply syncope) 

Do not perform imaging of the carotid arteries for simply syncope without other neurologic symptoms

Denominator: Patients with syncope and without other neurologic symptoms and no previous syncope diagnosis within 2 years before imaging
Other neurologic symptoms: without stroke or TIA, history of stroke or TIA, retinal vascular occlusion or ischemia, or nervous or musculoskeletal symptoms

*/

%let vars_carotidsyn = &vars_base lvc 
				carotid syncope_dx last_syncope_dx prev_syncope_dx 
				neurologic_dx first_neurologic_dx;

%macro alg_carotidsyn(input);

data output.carotidsyn_sensitive(keep=&vars_carotidsyn);
set &input;
lvc = carotid;
if last_syncope_dx>. and clm_dt-last_syncope_dx<=14;
run;

data output.carotidsyn_specific;
set output.carotidsyn_sensitive;
if first_neurologic_dx=.; 
run;

%patient_level_output(output.carotidsyn_sensitive, output.carotidsyn_sensitive_patient);
%patient_level_output(output.carotidsyn_specific, output.carotidsyn_specific_patient);

%mend alg_carotidsyn;


/*
algorithm 20: radio (radiographic or MR imaging)

Do not perform radiographic or MR imaging with diagnosis of plantar faciitis occuring within 2 weeks of initial foot pain diagnosis

Denominator: Patients with reported foot pain and with plantar fasciitis diagnosis within four weeks of initial foot pain
*/

%let vars_radio = &vars_base lvc 
				radiographic plantarfasciitis_dx next_plantarfasciitis_dx 
				footpain_dx last_footpain_dx ;
%macro alg_radio(input);

data output.radio_sensitive(keep=&vars_radio);
set &input;
lvc = radiographic;

if (next_plantarfasciitis_dx>. and next_plantarfasciitis_dx-clm_dt<=14) and
   (last_footpain_dx>. and clm_dt- last_footpain_dx <=14);
run;

data output.radio_specific;
set output.radio_sensitive;
run;

%patient_level_output(output.radio_sensitive, output.radio_sensitive_patient);
%patient_level_output(output.radio_specific, output.radio_specific_patient);

%mend alg_radio;


/*
algorithm 21. stress (stress testing, cardiac MRI, CT angiography)

Do not perform stress testing not associated with inpatient or emergency care for patients with an established diagnosis of acute myocardial infraction

Denominator: Patients with ischemic heart disease or acute myocardial infarction diagnosis at least 6 months before testing
*/

%let vars_stress = &vars_base lvc 
				stress emergencycare ischemic_dx last_ischemic_dx;

%macro alg_stress(input);

data output.stress_sensitive(keep=&vars_stress);
set &input;
lvc = stress and (emergencycare=0 and src ne "IP");
if last_ischemic_dx>. and (clm_dt - last_ischemic_dx)>=90;
run;

data output.stress_specific;
set output.stress_sensitive;
run;

%patient_level_output(output.stress_sensitive, output.stress_sensitive_patient);
%patient_level_output(output.stress_specific, output.stress_specific_patient);
%mend alg_stress;

/*
algorithm 22: endarterectomy (carotid endarterectomy)

Do not perform carotid endarterectomy (CEA), not associated with an ER visit, for patients without a history of stroke or TIA and without stroke, TIA, or focal neurological symptoms noted in claim

Denominator: Patients without a history of stroke or TIA, stroke or TIA, or focal neurological symptoms
*/

%let vars_endarterectomy = &vars_base lvc 
				endarterectomy stroketia_dx first_stroketia_dx;

%macro alg_endarterectomy(input);

data output.endarterectomy_sensitive(keep=&vars_endarterectomy);
set &input;
lvc = endarterectomy;
run;

data output.endarterectomy_specific;
set output.endarterectomy_sensitive;
if first_stroketia_dx = . ;
run;

%patient_level_output(output.endarterectomy_sensitive, output.endarterectomy_sensitive_patient);
%patient_level_output(output.endarterectomy_specific, output.endarterectomy_specific_patient);

%mend alg_endarterectomy;

/*
algorithm 23: homocysteine ( homocysteine testing)

Do not perform homocysteine testing with no diagnoses of folate or B12 deficiencies in the claim

Denominator: Patients without a diagnosis of folate or B12 deficiencies
*/

%let vars_homocysteine = &vars_base lvc 
					homocysteine folate_dx;

%macro alg_homocysteine(input);

data output.homocysteine_sensitive(keep=&vars_homocysteine);
set &input;
lvc = homocysteine;
run;

data output.homocysteine_specific;
set output.homocysteine_sensitive;
if folate_dx=0;
run;

%patient_level_output(output.homocysteine_sensitive, output.homocysteine_sensitive_patient);
%patient_level_output(output.homocysteine_specific, output.homocysteine_specific_patient);

%mend alg_homocysteine;


/*
algorithm 24. pth (parathyroid hormone (PTH) measurement)

Do not perform parathyroid hormone (PTH) measurement for patients with chronic kidney disease and no dialysis services before PTH testing or within 30 days following testing, as well as no hypercalcemia diagnosis during the year

Denominator: Patients with chronic kidney disease and not on dialysis and no hypercalcemia diagnosis
*/

%let vars_pth = &vars_base lvc 
				pth kidney_dx first_kidney_dx 
				hypercalcemia_dx last_hypercalcemia_dx 
				dialysis_betos first_dialysis_betos next_dialysis_betos;

%macro alg_pth(input);

data output.pth_sensitive(keep=&vars_pth);
set &input;
lvc = pth;
if first_kidney_dx>.;
run;

data output.pth_specific;
set output.pth_sensitive;
if (not (last_hypercalcemia_dx>. and clm_dt-last_hypercalcemia_dx<=365)) and 
   (not (first_dialysis_betos>. or (next_dialysis_betos>. and next_dialysis_betos-clm_dt<=30)));
run;

%patient_level_output(output.pth_sensitive, output.pth_sensitive_patient);
%patient_level_output(output.pth_specific, output.pth_specific_patient);

%mend alg_pth;

/*
algorithm 25. pci (percutaneous coronary intervention (PCI))

Do not perform percutaneous coronary intervention (PCI) with balloon angioplasty or stent placement, not associated with an ER visit, for patients with stable coronary disease  

Denominator: Patients with stable coronary disease (defined as ischemic heart disease or acute myocardial infarction more than 6 months before PCI) and without unstable angina or myocardial infarction in two weeks before claim
*/

%let vars_pci = &vars_base lvc 
			pci stablecoronary_dx last_stablecoronary_dx 
			angina_dx last_angina_dx;

%macro alg_pci(input);

data output.pci_sensitive(keep=&vars_pci);
set &input;
lvc = pci;
if last_stablecoronary_dx>. and clm_dt-last_stablecoronary_dx>180;
run;

data output.pci_specific;
set output.pci_sensitive;
if not (last_angina_dx>. and clm_dt - last_angina_dx <=14);
run;

%patient_level_output(output.pci_sensitive, output.pci_sensitive_patient);
%patient_level_output(output.pci_specific, output.pci_specific_patient);

%mend alg_pci;


/*
algorithm 26. angioplasty  (Patients that received a renal/visceral angioplasty or stent placement)

Do not perform renal/visceral angioplasty or stent placement with a diagnosis of renal atherosclerosis or renovascular hypertension noted in procedure claim

Denominator: Patients with a diagnosis of renal atherosclerosis or renovascular hypertension and without fibromuscular dysplasia
*/

%let vars_angioplasty = &vars_base lvc 
				angioplasty atherosclerosis_dx fibromuscular_dx;

%macro alg_angioplasty(input);

data output.angioplasty_sensitive(keep=&vars_angioplasty);
set &input;
lvc = angioplasty;
if atherosclerosis_dx=1;
run;

data output.angioplasty_specific;
set output.angioplasty_sensitive;
if fibromuscular_dx=0;
run;

%patient_level_output(output.angioplasty_sensitive, output.angioplasty_sensitive_patient);
%patient_level_output(output.angioplasty_specific, output.angioplasty_specific_patient);

%mend alg_angioplasty;

/*
algorithm 27. ivc (inferior vena cava (IVC) placement)

Do not perform IVC filter placement in patients without pulmonary embolism or deep vein thrombosis

Denominator: Patients without a history of or current pulmonary embolism or deep vein thrombosis in previous year
*/


%let vars_ivc = &vars_base lvc 
				ivc thrombosis_dx last_thrombosis_dx;

%macro alg_ivc(input);

data output.ivc_sensitive(keep=&vars_ivc);
set &input;
lvc = ivc;
run;

data output.ivc_specific;
set output.ivc_sensitive;
if not (last_thrombosis_dx>. and clm_dt - last_thrombosis_dx <=365);
run;

%patient_level_output(output.ivc_sensitive, output.ivc_sensitive_patient);
%patient_level_output(output.ivc_specific, output.ivc_specific_patient);

%mend alg_ivc;


/*
algorithm 28. cathe (pulmonary artery cathe (Swan-Ganz replacement))

Do not perform pulmonary artery cathe for monitoring purposes during an inpatient stay that involved an ICU and a nonsurgical MS-DRG and when the claim contains no diagnoses indicating pulmonary hypertension, cardiac tamponade, or preoperative assessment

Denominator:Patients who were hospitalized (inpatient) without a surgical MS-DRG and do not have pulmonary hypertension or cardiac tamponade
*/

%let vars_cathe = &vars_base lvc 
				catheterization pulmonaryhypertension_dx surgical_drg;

%macro alg_cathe(input);

data output.cathe_sensitive(keep=&vars_cathe);
set &input;
lvc = catheterization;
if src ='IP';
run;

data output.cathe_specific;
set output.cathe_sensitive;
if pulmonaryhypertension_dx=0 and surgical_drg=0;
run;

%patient_level_output(output.cathe_sensitive, output.cathe_sensitive_patient);
%patient_level_output(output.cathe_specific, output.cathe_specific_patient);

%mend alg_cathe;

/*
algorithm 29. verte (vertebroplasty or kyphoplasty)

Do not perform vertebroplasty or kyphoplasty for osteoporotic vertebral fracture with no bone cancers, myeloma, or hemangioma

Denominator: Patients with osteoporosis and with vertebral fractures and without bone cancer, myeloma, hemongioma
*/

%let vars_verte = &vars_base lvc 
				verte vertebralfracture_dx 
				osteoporosis_dx last_osteoporosis_dx 
				bonecancer_dx last_bonecancer_dx;

%macro alg_verte(input);

data output.verte_sensitive(keep=&vars_verte);
set &input;
lvc = verte;
if vertebralfracture_dx=1 and 
   (last_osteoporosis_dx>. and clm_dt-last_osteoporosis_dx<= 365);
run;

data output.verte_specific;
set output.verte_sensitive;
if not (last_bonecancer_dx>. and clm_dt-last_bonecancer_dx<=365);
run;

%patient_level_output(output.verte_sensitive, output.verte_sensitive_patient);
%patient_level_output(output.verte_specific, output.verte_specific_patient);

%mend alg_verte;


/*
algorithm 30. knee (arthroscopic debridement/ chondroplasty of the knee)

Do not perform arthroscopic debridement / chondroplasty of the knee for patients with diagnosis of osteoarthritis or chondromalacia and no meniscal tears

Patients with diagnosis of osteoarthritis or chondromalacia and without meniscal tears
*/

%let vars_knee = &vars_base lvc 
				knee osteoarthritis_dx meniscaltear_dx;

%macro alg_knee(input);

data output.knee_sensitive(keep=&vars_knee);
set &input;
lvc = knee;
if osteoarthritis_dx=1;
run;

data output.knee_specific;
set output.knee_sensitive;
if meniscaltear_dx=0;
run;

%patient_level_output(output.knee_sensitive, output.knee_sensitive_patient);
%patient_level_output(output.knee_specific, output.knee_specific_patient);

%mend alg_knee;


/*
algorithm31. inject (epidural, facet, or trigger point injections)

Do not perform outpatient epidural, facet, or trigger point injections for lower back pain, excluding etanercept, for patients with no radiculopathy diagnoses in the claim

Patients with lower back pain without radiculopathy
*/

%let vars_inject = &vars_base lvc 
				inject etanercept 
				lowbackpain_dx last_lowbackpain_dx 
				radiculopathy_dx last_radiculopathy_dx;

%macro alg_inject(input);

data output.inject_sensitive(keep=&vars_inject);
set &input;
lvc = inject and (not etanercept) and (src ne "IP");
if (last_lowbackpain_dx>. and clm_dt-last_lowbackpain_dx<=14);
run;

data output.inject_specific;
set output.inject_sensitive;
if not ((src = "IP") or (last_radiculopathy_dx>. and clm_dt-last_radiculopathy_dx<=14));
run;

%patient_level_output(output.inject_sensitive, output.inject_sensitive_patient);
%patient_level_output(output.inject_specific, output.inject_specific_patient);

%mend alg_inject;

proc datasets library=output kill;
run;
quit;

/*1*/%alg_psa(&inputdata);
/*2*/%alg_cerv(&inputdata); 
/*3*/%alg_vd(&inputdata);
/*4*/%alg_lbp(&inputdata);
/*5*/%alg_crc(&inputdata);
/*6*/%alg_canscrn(&inputdata);
/*7*/%alg_bonemd(&inputdata);
/*8*/%alg_hypercoagula(&inputdata);
/*9*/%alg_t3(&inputdata);
/*10*/%alg_xray(&inputdata);
/*11*/%alg_echo(&inputdata);
/*12*/%alg_pft(&inputdata);
/*13*/%alg_eenc(&inputdata);
/*14*/%alg_mfct(&inputdata);
/*15*/%alg_headimg(&inputdata);	
/*16*/%alg_headimg2(&inputdata);	
/*17*/%alg_eeg(&inputdata);	
/*18*/%alg_carotid(&inputdata);	
/*19*/%alg_carotidsyn(&inputdata);	
/*20*/%alg_radio(&inputdata);
/*21*/%alg_stress(&inputdata);	
/*22*/%alg_endarterectomy(&inputdata);	
/*23*/%alg_homocysteine(&inputdata);	
/*24*/%alg_pth(&inputdata);	
/*25*/%alg_pci(&inputdata);	
/*26*/%alg_angioplasty(&inputdata);	
/*27*/%alg_ivc(&inputdata);	
/*28*/%alg_cathe(&inputdata);	
/*29*/%alg_verte(&inputdata);	
/*30*/%alg_knee(&inputdata);	
/*31*/%alg_inject(&inputdata);	

%toStata;	
/*%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\output");*/
