/*
Low value care algorithms 
*/

%let vars_base= desy_sort_key npi src bene_race_cd clm_dt DOB_DT GNDR_CD;
%let inputdata= sub_0;

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
data output.&input._psa_sensitive(keep=&vars_psa);
set date.&input;
lvc = psa;
if DOB_DT>=3 and GNDR_CD=1;
run;

/* no history of prostate cancer*/
data output.&input._psa_specific;
set output.&input._psa_sensitive;
if first_prostate_dx=. or clm_dt < first_prostate_dx;
run;

%patient_level_output(output.&input._psa_sensitive, output.&input._psa_sensitive_p);
%patient_level_output(output.&input._psa_specific, output.&input._psa_specific_p);

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
data output.&input._cerv_sensitive(keep=&vars_cerv);
set date.&input;
lvc = cerv;
if DOB_DT>=2 and GNDR_CD=2; 
run;

/* not at high risk for cervical cancer */
data output.&input._cerv_specific;
set output.&input._cerv_sensitive;
if first_cerv_ex=. or clm_dt < first_cerv_ex;
run;

%patient_level_output(output.&input._cerv_sensitive, output.&input._cerv_sensitive_p);
%patient_level_output(output.&input._cerv_specific, output.&input._cerv_specific_p);
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
data output.&input._vd_sensitive(keep=&vars_vd);
set date.&input;
lvc = vitaminD_cpt;
run;

/* no chronic condition, 
no other risk factor or >90 days before test*,
not pregnant or clm_dt != pregancy_date 
no fracture or >365 days before test*/
data output.&input._vd_specific;
set output.&input._vd_sensitive;
if (missing(first_chronic_dx) or clm_dt<first_chronic_dx) and 
	(missing(last_other_risk_dx) or clm_dt-last_other_risk_dx>90) and 
	(missing(last_fracture_vd) or clm_dt-last_fracture_vd>365) and 
	(missing(pregnancy_obesity_dx_date) or clm_dt ne pregnancy_obesity_dx_date);
run;

%patient_level_output(output.&input._vd_sensitive, output.&input._vd_sensitive_p);
%patient_level_output(output.&input._vd_specific, output.&input._vd_specific_p);
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
data output.&input._lbp_sensitive(keep=&vars_lbp);
set date.&input;
lvc = imglbp;
if last_imglbp_inc_dx>. and clm_dt-last_imglbp_inc<=42;
run;

/*imglbp_exclusion_dx not within 6 weeks before service*/
data output.&input._lbp_specific;
set output.&input._lbp_sensitive;
if last_imglbp_exc_dx=. or clm_dt-last_imglbp_exc_dx>42;
run;

%patient_level_output(output.&input._lbp_sensitive, output.&input._lbp_sensitive_p);
%patient_level_output(output.&input._lbp_specific, output.&input._lbp_specific_p);
%mend alg_lbp;

/**************************************************
algorithm 5: crc (colorectal cancer screening)

Don't perform colorectal cancer screening for patients age 85 or older

Denominator: Patients age 85 or older without a history of colorectal cancer
*/

%let vars_crc &vars_base crc crc_dx crc_cancer_dx first_crc_cancer_dx lvc;

%macro alg_crc(input);
/* age >=85 */
data output.&input._crc_sensitive(keep=&vars_crc);
set date.&input;
lvc = (crc or crc_dx);
if DOB_DT=6;
run;

/* no crc cancer history */
data output.&input._crc_specific;
set output.&input._crc_sensitive;
if first_crc_cancer_dx=. or clm_dt < first_crc_cancer_dx;
run;

%patient_level_output(output.&input._crc_sensitive, output.&input._crc_sensitive_p);
%patient_level_output(output.&input._crc_specific, output.&input._crc_specific_p);
%mend alg_crc;

/**************************************************
algorithm 6: canscrn (cancer screening)

Don’t perform routine cancer screening for dialysis patients with limited life expectancy 

Denominator: Patients age 75 years or older and on dialysis
*/

%let vars_canscrn &vars_base canscrn canscrn_dx dialysis first_dialysis lvc;

%macro alg_canscrn(input);

/*age 75+ and on dialysis*/ 
data output.&input._canscrn_sensitive(keep=&vars_canscrn);
set date.&input;
lvc = (canscrn or canscrn_dx);
if DOB_DT>=4 and (first_dialysis>. and clm_dt>=first_dialysis); 
run;

data output.&input._canscrn_specific;
set output.&input._canscrn_sensitive;
run;

%patient_level_output(output.&input._canscrn_sensitive, output.&input._canscrn_sensitive_p);
%patient_level_output(output.&input._canscrn_specific, output.&input._canscrn_specific_p);

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

data output.&input._bonemd_sensitive(keep=&vars_bonemd);
set date.&input;
lvc=0;
if (bonemd=1 and (prev_bonemd>. and clm_dt-prev_bonemd<=730)) then lvc=1; /*LVC if within 2 years of a previous test*/
if first_osteoporosis_dx>. and clm_dt>=first_osteoporosis_dx; /*with osteoporosis*/ 
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.&input._bonemd_specific;
set output.&input._bonemd_sensitive;
if (first_cancer_dx=. or clm_dt<first_cancer_dx) and 
 (last_fracture=. or clm_dt - last_fracture>730); 
run;

%patient_level_output(output.&input._bonemd_sensitive, output.&input._bonemd_sensitive_p);
%patient_level_output(output.&input._bonemd_specific, output.&input._bonemd_specific_p);
%mend alg_bonemd;

/**************************************************
algorithm 8: hypercoagula (hypercoagulability test)

Don’t perform  hypercoagulability test in patients with deep vein thrombosis (DVT) with a known cause
denominator: Patients with pulmonary embolism or venous embolism with thrombosis

*/

%let vars_hypercoagula= &vars_base hypercoagula 
				embolism_dx first_embolism_dx last_embolism_dx lvc;

%macro alg_hypercoagula(input);
data output.&input._hypercoagula_sensitive(keep=&vars_hypercoagula);
set date.&input;
lvc=0;
if hypercoagula=1 and clm_dt-last_embolism_dx<=90 then lvc = 1;
if first_embolism_dx>.; /*Patients with pulmonary embolism  */ 
run;

data output.&input._hypercoagula_specific;
set output.&input._hypercoagula_sensitive;
run;

%patient_level_output(output.&input._hypercoagula_sensitive, output.&input._hypercoagula_sensitive_p);
%patient_level_output(output.&input._hypercoagula_specific, output.&input._hypercoagula_specific_p);
%mend alg_hypercoagula;

/**************************************************
algorithm 9: t3 (T3 level)

Don’t perform a total or free T3 level when assessing levothyroxine (T4) dose in 
hypothyroid patients

denominator: Patients with hypothyroidism
*/

%let vars_t3= &vars_base hypothyroidism_dx first_hypothyroidism_dx last_hypothyroidism_dx lvc;

%macro alg_t3(input);
data output.&input._t3_sensitive(keep=&vars_t3);
set date.&input;
lvc=0;
if t3=1 and clm_dt-last_hypothyroidism_dx<=365 then lvc = 1;
if first_hypothyroidism_dx>.; /*Patients with hypothyroidism */ 
run;

data output.&input._t3_specific;
set output.&input._t3_sensitive;
run;

%patient_level_output(output.&input._t3_sensitive, output.&input._t3_sensitive_p);
%patient_level_output(output.&input._t3_specific, output.&input._t3_specific_p);
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

data output.&input._xray_sensitive(keep=&vars_xray);
set date.&input;
lvc=0;
if xray=1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.; 
run;

/* not emergency care, not inpatient*/
data output.&input._xray_specific;
set output.&input._xray_sensitive;
if emergencycare=0 and (src in ('OP','CR'));
run;

%patient_level_output(output.&input._xray_sensitive, output.&input._xray_sensitive_p);
%patient_level_output(output.&input._xray_specific, output.&input._xray_specific_p);

%mend alg_xray;


/**************************************************
algorithm 11: echo (echocardiogram)

Do not perform an echocardiogram not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_echo= &vars_base lvc echocardiogram emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_echo(input);

data output.&input._echo_sensitive(keep=&vars_echo);
set date.&input;
lvc=0;
if echocardiogram =1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.; 
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.&input._echo_specific;
set output.&input._echo_sensitive;
if emergencycare=0 and (src in ('OP','CR'));;
run;

%patient_level_output(output.&input._echo_sensitive, output.&input._echo_sensitive_p);
%patient_level_output(output.&input._echo_specific, output.&input._echo_specific_p);

%mend alg_echo;


/**************************************************
algorithm 12: pft (pulmonary function test)

Do not perform a pulmonary function test (PFT) not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_pft=&vars_base lvc pulmonary emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_pft(input);
data output.&input._pft_sensitive(keep=&vars_pft);
set date.&input;
lvc=0;
if pulmonary =1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.; 
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.&input._pft_specific;
set output.&input._pft_sensitive;
if emergencycare=0 and (src ne 'IP');
run;

%patient_level_output(output.&input._pft_sensitive, output.&input._pft_sensitive_p);
%patient_level_output(output.&input._pft_specific, output.&input._pft_specific_p);

%mend alg_pft;

/**************************************************
algorithm 13: eenc (Electrocardiogram, Echocardiogram, Nuclear medicine imaging, Cardiac MRI or CT )

Do not perform electrocardiogram, echocardiogram, nuclear medicine imaging, cardiac MRI or CT angiography not associated with inpatient or emergency care and occurring within 30 days prior to a low or intermediate risk non-cardiothoracic surgical procedure

Denominator: Patients undergoing low or intermediate risk non-cardiothoracic surgical procedure
*/

%let vars_eenc = &vars_base lvc eenc emergencycare 
	next_low_risk_noncard low_risk_noncard first_low_risk_noncard;

%macro alg_eenc(input);

data output.&input._eenc_sensitive(keep=&vars_eenc);
set date.&input;
lvc=0;
if eenc =1 and (next_low_risk_noncard>. and next_low_risk_noncard-clm_dt<=30) then lvc=1;
if first_low_risk_noncard>. or next_low_risk_noncard>.;  
run;

/* no cancer patients, no fracture within 2 years of service*/
data output.&input._eenc_specific;
set output.&input._eenc_sensitive;
if emergencycare=0 and (src ne 'IP');;
run;

%patient_level_output(output.&input._eenc_sensitive, output.&input._eenc_sensitive_p);
%patient_level_output(output.&input._eenc_specific, output.&input._eenc_specific_p);
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

data output.&input._mfct_sensitive(keep=&vars_mfct);
set date.&input;
lvc=0;
if maxillofacialCT=1 then lvc=1;
if sinusitis_dx=1; 
run;

data output.&input._mfct_specific;
set output.&input._mfct_sensitive;
/*no other complication and Prior sinusitis diagnosis not within 30 to 365 days before CT*/
if other_related_comp_dx=0 and 
(not (last_sinusitis_dx>. and 30<=(clm_dt - last_sinusitis_dx)<=365)); 
run;

%patient_level_output(output.&input._mfct_sensitive, output.&input._mfct_sensitive_p);
%patient_level_output(output.&input._mfct_specific, output.&input._mfct_specific_p);

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

data output.&input._headimg_sensitive(keep=&vars_headimg);
set date.&input;
lvc=headimg;
if syncope_dx=1;	
run;

data output.&input._headimg_specific;
set output.&input._headimg_sensitive;
if warranted_img_dx=0;
run;

%patient_level_output(output.&input._headimg_sensitive, output.&input._headimg_sensitive_p);
%patient_level_output(output.&input._headimg_specific, output.&input._headimg_specific_p);

%mend alg_headimg;


/*
Algorithm 16: headimg2 (CT or MRI of head or brain)

Do not perform brain CT or MRI imaging for non-post-traumatic, nonthunderclap headache diagnosis without another diagnosis for warranted imaging.

Patients with headache and no other diagnosis for warranted imaging. Diagnoses for warranted imaging: post-tramatic or thunderclap headache, cancer, migraine with hemiplegia or infarction, giant cell arteritis, epilepsy or convulsions, cerebrovascular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA or cancer
*/

%let vars_headimg2 = &vars_base lvc 
					headimg headache_dx warranted_img2_dx;

%macro alg_headimg2(input);

data output.&input._headimg2_sensitive(keep=&vars_headimg2);
set date.&input;
lvc=headimg;
if headache_dx=1;	
run;

data output.&input._headimg2_specific;
set output.&input._headimg2_sensitive;
if warranted_img2_dx=0;
run;

%patient_level_output(output.&input._headimg2_sensitive, output.&input._headimg2_sensitive_p);
%patient_level_output(output.&input._headimg2_specific, output.&input._headimg2_specific_p);

%mend alg_headimg2;


/*
Algorithm 17: eeg (electroencephalogram)

Do not perform an EEG for headache diagnosis without epilepsy or convulsions noted in current or prior claims

Denominator:Patients with headaches and no indication of epilepsy or convulsions within 1 year before EEG and no other headache diagnosis within 2 years before EEG
*/

%let vars_eeg = &vars_base lvc 
				eeg eeg_headache_dx last_eeg_headache_dx epilepsy_dx last_epilepsy_dx;

%macro alg_eeg(input);

data output.&input._eeg_sensitive(keep=&vars_eeg);
set date.&input;
lvc=eeg;
if eeg_headache_dx=1;	
run;

data output.&input._eeg_specific;
set output.&input._eeg_sensitive;
if (last_eeg_headache_dx=. or clm_dt-last_eeg_headache_dx >730) and
	(last_epilepsy_dx=. or clm_dt-last_epilepsy_dx > 365);
run;

%patient_level_output(output.&input._eeg_sensitive, output.&input._eeg_sensitive_p);
%patient_level_output(output.&input._eeg_specific, output.&input._eeg_specific_p);

%mend alg_eeg;

/*
Algorithm 18: carotid (carotid imaging)

Do not perform carotid imaging not associated with inpatient or emergency care for patients without a stroke, TIA, or focal neurological symptom in claim

Denominator: NONE ?? Should we check history or just time in the same claim??
*/

%let vars_carotid = &vars_base lvc 
				carotid emergencycare stroke_etc_dx;

%macro alg_carotid(input);

data output.&input._carotid_sensitive(keep=&vars_carotid);
set date.&input;
lvc=carotid and (src ne 'IP') and emergencycare=0;
run;

data output.&input._carotid_specific;
set output.&input._carotid_sensitive;
if stroke_etc_dx=0;
run;

%patient_level_output(output.&input._carotid_sensitive, output.&input._carotid_sensitive_p);
%patient_level_output(output.&input._carotid_specific, output.&input._carotid_specific_p);

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

data output.&input._carotidsyn_sensitive(keep=&vars_carotidsyn);
set date.&input;
lvc = carotid;
if last_syncope_dx>. and clm_dt-last_syncope_dx<=14;
run;

data output.&input._carotidsyn_specific;
set output.&input._carotidsyn_sensitive;
if first_neurologic_dx=.; 
run;

%patient_level_output(output.&input._carotidsyn_sensitive, output.&input._carotidsyn_sensitive_p);
%patient_level_output(output.&input._carotidsyn_specific, output.&input._carotidsyn_specific_p);

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

data output.&input._radio_sensitive(keep=&vars_radio);
set date.&input;
lvc = radiographic;

if (next_plantarfasciitis_dx>. and next_plantarfasciitis_dx-clm_dt<=14) and
   (last_footpain_dx>. and clm_dt- last_footpain_dx <=14);
run;

data output.&input._radio_specific;
set output.&input._radio_sensitive;
run;

%patient_level_output(output.&input._radio_sensitive, output.&input._radio_sensitive_p);
%patient_level_output(output.&input._radio_specific, output.&input._radio_specific_p);

%mend alg_radio;


/*
algorithm 21. stress (stress testing, cardiac MRI, CT angiography)

Do not perform stress testing not associated with inpatient or emergency care for patients with an established diagnosis of acute myocardial infraction

Denominator: Patients with ischemic heart disease or acute myocardial infarction diagnosis at least 6 months before testing
*/

%let vars_stress = &vars_base lvc 
				stress emergencycare ischemic_dx last_ischemic_dx;

%macro alg_stress(input);

data output.&input._stress_sensitive(keep=&vars_stress);
set date.&input;
lvc = stress and (emergencycare=0 and src ne "IP");
if last_ischemic_dx>. and (clm_dt - last_ischemic_dx)>=90;
run;

data output.&input._stress_specific;
set output.&input._stress_sensitive;
run;

%patient_level_output(output.&input._stress_sensitive, output.&input._stress_sensitive_p);
%patient_level_output(output.&input._stress_specific, output.&input._stress_specific_p);
%mend alg_stress;

/*
algorithm 22: endarterectomy (carotid endarterectomy)

Do not perform carotid endarterectomy (CEA), not associated with an ER visit, for patients without a history of stroke or TIA and without stroke, TIA, or focal neurological symptoms noted in claim

Denominator: Patients without a history of stroke or TIA, stroke or TIA, or focal neurological symptoms
*/

%let vars_endarterectomy = &vars_base lvc 
				endarterectomy stroketia_dx first_stroketia_dx;

%macro alg_endarterectomy(input);

data output.&input._endarterectomy_sensitive(keep=&vars_endarterectomy);
set date.&input;
lvc = endarterectomy;
run;

data output.&input._endarterectomy_specific;
set output.&input._endarterectomy_sensitive;
if first_stroketia_dx = . ;
run;

%patient_level_output(output.&input._endarterectomy_sensitive, output.&input._endarterectomy_sensitive_p);
%patient_level_output(output.&input._endarterectomy_specific, output.&input._endarterectomy_specific_p);

%mend alg_endarterectomy;

/*
algorithm 23: homocysteine ( homocysteine testing)

Do not perform homocysteine testing with no diagnoses of folate or B12 deficiencies in the claim

Denominator: Patients without a diagnosis of folate or B12 deficiencies
*/

%let vars_homocysteine = &vars_base lvc 
					homocysteine folate_dx;

%macro alg_homocysteine(input);

data output.&input._homocysteine_sensitive(keep=&vars_homocysteine);
set date.&input;
lvc = homocysteine;
run;

data output.&input._homocysteine_specific;
set output.&input._homocysteine_sensitive;
if folate_dx=0;
run;

%patient_level_output(output.&input._homocysteine_sensitive, output.&input._homocysteine_sensitive_p);
%patient_level_output(output.&input._homocysteine_specific, output.&input._homocysteine_specific_p);

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

data output.&input._pth_sensitive(keep=&vars_pth);
set date.&input;
lvc = pth;
if first_kidney_dx>.;
run;

data output.&input._pth_specific;
set output.&input._pth_sensitive;
if (not (last_hypercalcemia_dx>. and clm_dt-last_hypercalcemia_dx<=365)) and 
   (not (first_dialysis_betos>. or (next_dialysis_betos>. and next_dialysis_betos-clm_dt<=30)));
run;

%patient_level_output(output.&input._pth_sensitive, output.&input._pth_sensitive_p);
%patient_level_output(output.&input._pth_specific, output.&input._pth_specific_p);

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

data output.&input._pci_sensitive(keep=&vars_pci);
set date.&input;
lvc = pci;
if last_stablecoronary_dx>. and clm_dt-last_stablecoronary_dx>180;
run;

data output.&input._pci_specific;
set output.&input._pci_sensitive;
if not (last_angina_dx>. and clm_dt - last_angina_dx <=14);
run;

%patient_level_output(output.&input._pci_sensitive, output.&input._pci_sensitive_p);
%patient_level_output(output.&input._pci_specific, output.&input._pci_specific_p);

%mend alg_pci;


/*
algorithm 26. angioplasty  (Patients that received a renal/visceral angioplasty or stent placement)

Do not perform renal/visceral angioplasty or stent placement with a diagnosis of renal atherosclerosis or renovascular hypertension noted in procedure claim

Denominator: Patients with a diagnosis of renal atherosclerosis or renovascular hypertension and without fibromuscular dysplasia
*/

%let vars_angioplasty = &vars_base lvc 
				angioplasty atherosclerosis_dx fibromuscular_dx;

%macro alg_angioplasty(input);

data output.&input._angioplasty_sensitive(keep=&vars_angioplasty);
set date.&input;
lvc = angioplasty;
if atherosclerosis_dx=1;
run;

data output.&input._angioplasty_specific;
set output.&input._angioplasty_sensitive;
if fibromuscular_dx=0;
run;

%patient_level_output(output.&input._angioplasty_sensitive, output.&input._angioplasty_sensitive_p);
%patient_level_output(output.&input._angioplasty_specific, output.&input._angioplasty_specific_p);

%mend alg_angioplasty;

/*
algorithm 27. ivc (inferior vena cava (IVC) placement)

Do not perform IVC filter placement in patients without pulmonary embolism or deep vein thrombosis

Denominator: Patients without a history of or current pulmonary embolism or deep vein thrombosis in previous year
*/


%let vars_ivc = &vars_base lvc 
				ivc thrombosis_dx last_thrombosis_dx;

%macro alg_ivc(input);

data output.&input._ivc_sensitive(keep=&vars_ivc);
set date.&input;
lvc = ivc;
run;

data output.&input._ivc_specific;
set output.&input._ivc_sensitive;
if not (last_thrombosis_dx>. and clm_dt - last_thrombosis_dx <=365);
run;

%patient_level_output(output.&input._ivc_sensitive, output.&input._ivc_sensitive_p);
%patient_level_output(output.&input._ivc_specific, output.&input._ivc_specific_p);

%mend alg_ivc;


/*
algorithm 28. cathe (pulmonary artery cathe (Swan-Ganz replacement))

Do not perform pulmonary artery cathe for monitoring purposes during an inpatient stay that involved an ICU and a nonsurgical MS-DRG and when the claim contains no diagnoses indicating pulmonary hypertension, cardiac tamponade, or preoperative assessment

Denominator:Patients who were hospitalized (inpatient) without a surgical MS-DRG and do not have pulmonary hypertension or cardiac tamponade
*/

%let vars_cathe = &vars_base lvc 
				catheterization pulmonaryhypertension_dx surgical_drg;

%macro alg_cathe(input);

data output.&input._cathe_sensitive(keep=&vars_cathe);
set date.&input;
lvc = catheterization;
if src ='IP';
run;

data output.&input._cathe_specific;
set output.&input._cathe_sensitive;
if pulmonaryhypertension_dx=0 and surgical_drg=0;
run;

%patient_level_output(output.&input._cathe_sensitive, output.&input._cathe_sensitive_p);
%patient_level_output(output.&input._cathe_specific, output.&input._cathe_specific_p);

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

data output.&input._verte_sensitive(keep=&vars_verte);
set date.&input;
lvc = verte;
if vertebralfracture_dx=1 and 
   (last_osteoporosis_dx>. and clm_dt-last_osteoporosis_dx<= 365);
run;

data output.&input._verte_specific;
set output.&input._verte_sensitive;
if not (last_bonecancer_dx>. and clm_dt-last_bonecancer_dx<=365);
run;

%patient_level_output(output.&input._verte_sensitive, output.&input._verte_sensitive_p);
%patient_level_output(output.&input._verte_specific, output.&input._verte_specific_p);

%mend alg_verte;


/*
algorithm 30. knee (arthroscopic debridement/ chondroplasty of the knee)

Do not perform arthroscopic debridement / chondroplasty of the knee for patients with diagnosis of osteoarthritis or chondromalacia and no meniscal tears

Patients with diagnosis of osteoarthritis or chondromalacia and without meniscal tears
*/

%let vars_knee = &vars_base lvc 
				knee osteoarthritis_dx meniscaltear_dx;

%macro alg_knee(input);

data output.&input._knee_sensitive(keep=&vars_knee);
set date.&input;
lvc = knee;
if osteoarthritis_dx=1;
run;

data output.&input._knee_specific;
set output.&input._knee_sensitive;
if meniscaltear_dx=0;
run;

%patient_level_output(output.&input._knee_sensitive, output.&input._knee_sensitive_p);
%patient_level_output(output.&input._knee_specific, output.&input._knee_specific_p);

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

data output.&input._inject_sensitive(keep=&vars_inject);
set date.&input;
lvc = inject and (not etanercept) and (src ne "IP");
if (last_lowbackpain_dx>. and clm_dt-last_lowbackpain_dx<=14);
run;

data output.&input._inject_specific;
set output.&input._inject_sensitive;
if not ((src = "IP") or (last_radiculopathy_dx>. and clm_dt-last_radiculopathy_dx<=14));
run;

%patient_level_output(output.&input._inject_sensitive, output.&input._inject_sensitive_p);
%patient_level_output(output.&input._inject_specific, output.&input._inject_specific_p);

%mend alg_inject;


/*
algoirthm 32: Do not perform upper tract imaging in patients with benign prostatic hyperplasia (BPH) without another indication for imaging
denominator: Patients with benign prostatic hyperplasia (BPH) and without another indication for imaging
Other indication for imaging: chronic renal failure, nephritis, nephrotic syndrome, and nephrosis, other pyelonephritis or pyonephrosis not specified as acute or chronic, calculus of kidney and ureter, kidney stones, urinary tract infections, hematuria, fever, urinary retention, abdominal pain, cancer except non-melanoma skin cancer
*/

%let vars_tract = &vars_base lvc 
				   uppertract bph_dx indicateimg_dx;

%macro alg_tract(input);

data output.&input._tract_sensitive(keep=&vars_tract);
set date.&input;
lvc = uppertract;
if bph_dx=1;
run;

data output.&input._tract_specific;
set output.&input._tract_sensitive;
if not (indicateimg_dx=1);
run;

%patient_level_output(output.&input._tract_sensitive, output.&input._tract_sensitive_p);
%patient_level_output(output.&input._tract_specific, output.&input._tract_specific_p);

%mend alg_tract;



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
/*32*/%alg_tract(&inputdata)
%toStata;	
/*%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\output");*/
