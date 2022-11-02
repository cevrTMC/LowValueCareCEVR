
%let yr_start = 2017; /* synthetic data 2008*/
%let yr_end = 2017; /* synthetic data 2008*/
%let ip_chunk=1;

%let num_cd = 200;

/* procedure condition*/
%let psa_cond = cptcode in ('G0103', '84152', '84153', '84154') ;
%let cerv_cond = cptcode in ('G0123', 'G0124', 'G0141', 'G0143', 
				'G0144', 'G0145', 'G0147', 'G0148', 
				'P3000', 'P3001', 'Q0091', '88141',
				'88142', '88143', '88147', '88148', 
				'88150', '88152', '88153', '88154', 
				'88155', '88164', '88165', '88166', 
				'88167', '88174', '88175'); 
%let crc_cond = (cptcode in:('G0328','82270')) or ('G0104'<=:cptcode<=:'G0106')or 
				('G0120'<=:cptcode<=:'G0122')or ('45330'<=:cptcode<=:'45345') or 
				('45378'<=:cptcode<=:'45392');
%let canscrn_cond = (cptcode in ('77057', 'G0202', 'G0104-G0106', 
				'G0120-G0122', 'G0328', '45330-45345', '45378-45392', 
				'82270', 'G0102', 'G0103', '84152-84154', 'G0101', 'G0123', 
				'G0124', 'G0141', 'G0143', 'G0144', 'G0145', 'G0147',
				'G0148', 'P3000', 'P3001', 'Q0091')) or
					('G0104'<=:cptcode<=:'G0106') or
					('45330'<=:cptcode<=:'45345') or
					('45378'<=:cptcode<=:'45392') or
					('84152'<=:cptcode<=:'84154');
%let hypercoagula_cond = cptcode in ('81240', '81241', '83090', '85300', '85303', '85306', '85613', '86147');
%let t3_cond = cptcode in ('84480', '84481');
%let bonemd_cpt_cond = (cptcode in ('76070', '76071', '76078', '76977','77083', '78350', '78351')) or
			  ('77078'<=:cptcode<=:'77081'); 
%let fracture_cpt_cond = (cptcode in ('25600', '25605', '25609', '25611', '73000', '73010', '73020', '73030', '73040', 
						'73050', '73060', '73070', '73080', '73085', '73090', '73092', '73100', '73110', '73115', '73120',
						'73130', '73140', '73200', '73201', '73202', '73206', '73218', '73219', '73220', '73221', '73222',
						'73223', '73225', '73300', '73301', '73302', '73303', '73309'))
						 or ('27230'<=:cptcode<=:'27248')
						 or ('23600'<=:cptcode<=:'23630')
						 or ('23665'<=:cptcode<=:'23680');

%let vitaminD_cpt_cond = cptcode in ('82306', '82307', '82562'); /*vitamin D test*/
%let imglbp_cond = cptcode in ('72010', '72020', '72052', '72100', '72110', '72114', '72120', 
						'72200', '72202', '72220', '72131', '72132', '72133', '72141', '72142',
						'72146', '72147', '72148', '72149', '72156', '72157', '72158');

%let xray_cond = (cptcode in ('71010', '71015','71030', '71034', '71035')) 
				or ('71020'<=:cptcode<=:'71023');
%let emergencycare_cond = (cptcode in ('99288')) or ('99281'<=:cptcode<=:'99285');
%let low_risk_noncard_cpt_cond = cptcode in ('19120', '19125', '47562', '47563', '49560', '58558');
%let echocardiogram_cond = (cptcode in ('93303', '93304', '93312', '93315', '93318'))
					       or ('93306'<=:cptcode<=:'93308');
%let pulmonary_cond = cptcode in ('94010');
%let eenc_cond = (cptcode in ('75574', '78460', '78461', '78464',
							'78465', '78472', '78473', '78481', '78483', '78491', '78492',
							'93350', '93351', '0146T', '0147T', '0148T', '0149T'))
							or ('75552'<=:cptcode<=:'75564')
							or ('78451'<=:cptcode<=:'78454')
							or ('93015'<=:cptcode<=:'93018');
%let maxillofacialCT_cond = cptcode in ('70486', '70487', '70488');
%let headimg_cond = (cptcode in ('70450', '70460', '70470'))
					 or ('70551'<=:cptcode<=:'70553');
%let eeg_cond = cptcode in ('95812', '95813', '95816', '95819', '95822', '95827', '95830', '95957');
%let carotid_cond = (cptcode in ('70498', '93880', '93882', '3100F'))  
					 or ('70547'<=:cptcode<=:'70549');
%let radiographic_cond = cptcode in ('73620', '73630', '73650', '73718', '73719', '73720', '76880', '76881', '76882');
%let stress_cond = (cptcode in ('75574', '78460', '78461', '78464', '78465', '78472', 
							'78473', '78481', '78483', '78491', '78492', '93350', '93351'))
					or ('78451'<=:cptcode<=:'78454')
					or ('93015'<=:cptcode<=:'93018');
%let endarterectomy_cond = cptcode in ('35301');
%let homocysteine_cond = cptcode in ('83090');
%let pth_cond = cptcode in ('83970');


/* diagnosis condition */
%let crc_dx_cond = dxcode in :('Z121'); 
%let canscrn_dx_cond=dxcode in :('Z121','Z123','Z124','Z125');

%let dialysis_dx_cond = dxcode in :('Z49');


%let prostate_dx_cond = dxcode in :("C61","D075", "D400", "R972", "Z8042");

%let cerv_ex_cond= ('B20'<=:dxcode<=:'B24') or 
					(dxcode in :("C51", "C52", "C53", "C57",
					"D06", "D070", "D071", "D072", 
					"D073", "D260", "N87", "P048", "R87", 
					"Z779", "Z8741")) or 
					('Z8540'<=:dxcode<=:'Z8544');
%let embolism_dx_cond = dxcode in :('I26', 'I82');
%let hypothyroidism_dx_cond = dxcode in :('E018', 'E02', 'E03', 'E890');
%let dxa_dx_cond = dxcode in :('Z13820');
%let cancer_dx_cond= ('C00'<=:dxcode<=:'C96') or
				     ('D00'<=:dxcode<=:'D09') or 
					 ('D37'<=:dxcode<=:'D49');
%let fracture_dx_cond = dxcode in :('M485', 'M80', 'M844', 'M845', 'M846', 'S12', 'S22', 'S32', 'S42', 
						'S49', 'S52', 'S59', 'S62');

%let fracture_vd_dx_cond = dxcode in :('M485', 'M80', 'M844', 'M845', 'M846', 'S12', 'S22', 'S32', 'S42', 
						'S49', 'S52', 'S59', 'S62','Z87310', 'Z87311', 'Z9181');

%let osteoporosis_dx_cond = dxcode in :('M81');
%let chronic_dx_cond = (dxcode in :('B520', 'C44', 'C50', 'C56', 'C64', 'C65', 'C67', 'C90', 'C92',
							'C93', 'C94', 'C95', 'D45', 'E08', 'E09', 'E10', 'E11', 'E13', 'E200', 
							'E208', 'E209', 'E550', 'E559', 'E643', 'E67', 'E68', 
							'E8351', 'E8352', 'E84', 'E892', 'G737', 'I12', 'I13', 'K50', 'K51', 'K520',
							'K702', 'K7030', 'K7031', 'K7041', 'K7111', 'K7200', 'K7201', 'K7211', 'K7290', 
							'K7291', 'K74', 'K7581', 'K760',  'K762', 'K7689', 'K9089',
							'K909', 'K912',  'L408', 'L409', 'L41', 'L945',
							'M32', 'M33', 'M360', 'M80', 'M81', 'M83', 'M859', 'M88', 'M899', 'M949', 'N08',
							'N16', 'N18', 'N251', 'N2581', 'Q780', 'Q782', 'Z13820', 'Z1389', 'Z4931', 'Z4932',
							'Z795', 'Z79899', 'Z9115', 'Z9884', 'Z992')) or 
						('E210'<=:dxcode<=:'E215') or 
						('K900'<=:dxcode<=:'K904') or 
						('L400'<=:dxcode<=:'L404') or 
						('L4050'<=:dxcode<=:'L4059');
%let other_risk_dx_cond= dxcode in :('A15', 'A17', 'A18', 'A19', 'B38', 'B39',
						'C81', 'C82', 'C83', 'C84', 'C85', 'C86', 'C88', 'C91',
						'C96', 'D86', 'E440', 'E83', 'G40', 'J63');
%let pregnancy_obesity_dx_cond= dxcode in :('A34', 'E65', 'E66', 'O00', 'O01', 'O02',
						'O03', 'O04', 'O07', 'O08', 'O09', 'O10', 'O11', 'O12', 'O13',
						'O14', 'O15', 'O16', 'O20', 'O21', 'O23', 'O24', 'O25', 'O26',
						'O29', 'O30', 'O31', 'O32', 'O33', 'O34', 'O35', 'O36', 'O40', 
						'O41', 'O42', 'O43', 'O44', 'O45', 'O46', 'O47', 'O48', 'O60',
						'O61', 'O62', 'O63', 'O64', 'O65', 'O66', 'O67', 'O68', 'O69',
						'O70', 'O71', 'O72', 'O73', 'O74', 'O75', 'O76', 'O77', 'O80',
						'O82', 'O90', 'O98', 'O99', 'O9A', 'P50', 'Z32', 'Z33', 'Z34',
						'Z36', 'Z68');
%let imglbp_inc_dx_cond=dxcode in :('M4327', 'M4328', 'M4646', 'M4647', 'M4720', 'M4726',
						'M4727', 'M4728', 'M47816', 'M47817', 'M47818', 'M47819', 'M47896',
						'M47897', 'M47898', 'M47899', 'M479', 'M5116', 'M5117', 'M5126', 
						'M5127', 'M5134', 'M5135', 'M5136', 'M5137', 'M5146', 'M5147', 'M5186',
						'M5187', 'M532X7', 'M532X8', 'M533', 'M5386', 'M5387', 'M5388', 
						'M5430', 'M5431', 'M5432', 'M5440', 'M5441', 'M5442', 'M545', 'M5489',
						'M549', 'M9903', 'M9904', 'M9983', 'M9984', 'S335XXA', 'S336XXA', 
						'S338XXA', 'S339XXA');
%let imglbp_exc_dx_cond = (dxcode in :('A15', 'A17', 'A18', 'A19', 'A40', 'A41', 'A427', 
						 'D649', 'F11', 'G06', 'G07', 'G834', 'G933',
						'I33', 'I39', 'L599', 'M46', 'M4710', 'M4716', 'M48', 'M510', 'M519',
						'M541', 'M6790', 'M792', 'M80', 'M84', 'M86', 'M896', 'M908', 'M97', 
						'M991', 'Q850', 'R50', 'R53', 'R61','R63', 'R680', 'R863', 
						'T07', 'T88',  
						'Y83', 'Y84', 'Y92', 'Y99')) or 
						('D00'<=:dxcode<=:'D09') or 
						('D37'<=:dxcode<=:'D49') or 
						('F13'<=:dxcode<=:'F15') or
						('C00'<=:dxcode<=:'C96') or
						('S00'<=:dxcode<=:'S99') or 
						('T14'<=:dxcode<=:'T28') or 
						('T33'<=:dxcode<=:'T85') or
						('V00'<=:dxcode<=:'V99') or
						('W00'<=:dxcode<=:'W99') or
						('X00'<=:dxcode<=:'X99') or
						('Y00'<=:dxcode<=:'Y69');
%let crc_cancer_dx_cond = dxcode in :('C18');
%let sinusitis_dx_cond = dxcode in :('J01','J32');
%let other_related_comp_dx_cond = (dxcode in :('B20', 'B9735', 'D80', 'D810', 'D811', 'D812', 'D814', 
											'D816', 'D817', 'D8189', 'D819', 'D893', 'D894', 
											'D898', 'E84', 'H00', 'H01', 'H0500', 'J33', 'L0889', 'M359', 
											 'S16', 'S19')) or
									('D82'<=:dxcode<=:'D84') or
									('S00'<=:dxcode<=:'S16');	
%let syncope_dx_cond = dxcode in :('R55', 'T671XXA');
%let warranted_img_dx_cond=(dxcode in :('G40', 'G45', 'G46', 'L0889', 'R20', 
									'R410', 'R414', 'R4182', 'R43', 'R47', 'R56', 'R683', 
									'S05', 'S06', 'S16', 'S19', 'Z85', 'Z8673')) or
									('I60'<=:dxcode<=:'I69') or
									('S08'<=:dxcode<=:'S10') or 
									('S00'<=:dxcode<=:'S02') or
									('R25'<=:dxcode<=:'R29');
%let headache_dx_cond = dxcode in :('G430', 'G431', 'G435', 'G437', 'G438', 'G439', 'G43A', 'G43B', 
									'G43C', 'G43D', 'G440', 'G441', 'G442', 'G444', 'G4451', 'G4452',
									'G4459', 'G448', 'R51');
%let warranted_img2_dx_cond = (dxcode in :('G40', 'G434', 'G436', 'G443', 'G4453', 
							'G45', 'G46', 'L0889', 'M315', 'M316', 'Q85', 'R20', 'R410',
							'R414', 'R4182', 'R41842', 'R43', 'R47', 'R56', 'R683', 'S05', 'S06', 
							'S16', 'S19', 'Z85', 'Z8673')) or
							('C00'<=:dxcode<=:'C99') or
							('D00'<=:dxcode<=:'D09') or
							('D37'<=:dxcode<=:'D49') or
							('I60'<=:dxcode<=:'I69') or
							('R25'<=:dxcode<=:'R29') or
							('S08'<=:dxcode<=:'S10') or 
							('S00'<=:dxcode<=:'S02');
%let eeg_headache_dx_cond = dxcode in :('G43', 'G44', 'R51');
%let epilepsy_dx_cond = dxcode in :('G40', 'R25', 'R56');
%let stroke_etc_dx_cond = dxcode in :('G45', 'G460', 'G461', 'G462', 'G819', 'G9731', 'G9732', 
									'H34', 'H3582', 'I60', 'I61', 'I63', 'I66', 'I652', 'I672', 
									'I67841', 'I67848', 'I6789', 'I978', 'R098', 'R20', 'R220', 
									'R221', 'R25', 'R26', 'R27', 'R29', 'R414', 'R43', 'R47', 
									'R55', 'R683', 'R900', 'Z8673');
%let neurologic_dx_cond = dxcode in :('G45', 'G460', 'G461', 'G462', 'G973', 'H34', 'H3582', 'I60', 
									'I61', 'I63', 'I66', 'I6784', 'I6789', 'I9781', 'I9782', 'R20', 
									'R25', 'R26', 'R27', 'R29', 'R414', 'R43', 'R47', 'R683', 'Z8673');
%let plantarfasciitis_dx_cond = dxcode in :('M722', 'M729');
%let footpain_dx_cond = dxcode in :('M2557', 'M7967');
%let ischemic_dx_cond = dxcode in :('I21', 'I22', 'I248', 'I249', 'I25');
%let stroketia_dx_cond = dxcode in :('G45', 'G460', 'G461', 'G462', 'G973', 'H34', 'H3582', 'I60', 'I61',
								'I63', 'I66', 'I6784', 'I6789', 'I9781', 'I9782', 'R20', 'R25', 'R26', 
								'R27', 'R29', 'R414', 'R43', 'R47', 'R683', 'Z8673');
%let folate_dx_cond = dxcode in :('D51', 'D52', 'D649', 'D81818', 'D81819', 'E538', 'E539', 'E721');
%let kidney_dx_cond = dxcode in :('I12', 'I13', 'N18');
%let hypercalcemia_dx_cond = dxcode in :('E8352');

/* betos conditions */
%let dialysis_betos_cond = betos in :('P9A','P9B'); /* BETOS */
%let low_risk_noncard_betos_cond = betos in : ('P1','P3D', 'P4A', 'P4B', 'P4C', 'P5C', 'P5D', 
							'P8A', 'P8G');

/********************************************************************************/
/* flag conditions */
/********************************************************************************/

%let conditions = psa cerv crc canscrn crc_dx canscrn_dx 
				  dialysis_dx prostate_dx cerv_ex dialysis
				  hypercoagula embolism_dx
				  t3 hypothyroidism_dx
				  bonemd_cpt dxa_dx bonemd
				  fracture_cpt cancer_dx fracture_dx osteoporosis_dx fracture
				  vitaminD_cpt chronic_dx other_risk_dx pregnancy_obesity_dx
				  imglbp imglbp_inc_dx imglbp_exc_dx
				  crc_cancer_dx dialysis_betos
				  xray emergencycare low_risk_noncard_betos low_risk_noncard_cpt low_risk_noncard
				  fracture_vd_dx fracture_vd
				  echocardiogram
				  pulmonary
				  eenc
				  maxillofacialCT sinusitis_dx other_related_comp_dx
				  headimg syncope_dx warranted_img_dx
				  headache_dx warranted_img2_dx
				  eeg eeg_headache_dx epilepsy_dx
			  	  carotid stroke_etc_dx
				  neurologic_dx
				  radiographic
				  plantarfasciitis_dx
				  footpain_dx
				  stress ischemic_dx
				  endarterectomy
				  stroketia_dx
				  homocysteine
				  folate_dx
				  pth kidney_dx hypercalcemia_dx
				;

%macro flag(clmtype=,year=, chunk=,);
data lvc_etl.&clmtype._&year._&chunk._flag;
	set lvc_etl.&clmtype._&year._&chunk.;
	array hcpcscd(&num_cd.) hcpcs_cd1-hcpcs_cd&num_cd.;
	array dxcodes(25) icd_dgns_cd1-icd_dgns_cd25;
	array betoscd(&num_cd.) betos_cd1-betos_cd&num_cd.;

	array _conditions &conditions;
	
	do over _conditions; _conditions = 0; end;
	
	do i=1 to dim(hcpcscd);
	  if not missing(hcpcscd(i)) then do;
	  		cptcode = upcase(hcpcscd(i));
			if &psa_cond then psa=1;
			if &cerv_cond then cerv=1;
			if &crc_cond then crc = 1;
			if &canscrn_cond then canscrn=1;
			if &hypercoagula_cond then hypercoagula=1;
			if &t3_cond then t3=1;
			if &bonemd_cpt_cond then bonemd_cpt=1;
			if &fracture_cpt_cond then fracture_cpt=1;
			if &vitaminD_cpt_cond then vitaminD_cpt=1;
			if &imglbp_cond then imglbp=1;
			if &xray_cond then xray=1;
			if &emergencycare_cond then emergencycare=1;
			if &low_risk_noncard_cpt_cond then low_risk_noncard_cpt=1;
			if &echocardiogram_cond then echocardiogram=1;
			if &pulmonary_cond then pulmonary=1;
			if &eenc_cond then eenc=1;
			if &maxillofacialCT_cond then maxillofacialCT=1;
			if &headimg_cond then headimg=1;
			if &eeg_cond then eeg =1;
			if &carotid_cond then carotid=1;
			if &radiographic_cond then radiographic=1;
			if &stress_cond then stress=1;
			if &endarterectomy_cond then endarterectomy=1;
			if &homocysteine_cond then homocysteine=1;
			if &pth_cond then pth=1;
	  end;
	end;

	do i=1 to dim(dxcodes);
	  if not missing(dxcodes(i)) then do;
	  		dxcode = upcase(dxcodes(i));
			if &crc_dx_cond then crc_dx=1;
			if &canscrn_dx_cond then canscrn_dx=1;
			if &prostate_dx_cond then prostate_dx=1;
			if &dialysis_dx_cond then dialysis_dx=1;
			if &cerv_ex_cond then cerv_ex =1;
			if &embolism_dx_cond then embolism_dx=1;
			if &hypothyroidism_dx_cond then hypothyroidism_dx=1;
			if &dxa_dx_cond then dxa_dx =1;
			if &cancer_dx_cond then cancer_dx=1;
			if &fracture_dx_cond then fracture_dx=1;
			if &osteoporosis_dx_cond then osteoporosis_dx=1;
			if &chronic_dx_cond  then chronic_dx=1;
			if &chronic_dx_cond then chronic_dx=1;
			if &other_risk_dx_cond then other_risk_dx=1;
			if &pregnancy_obesity_dx_cond then pregnancy_obesity_dx=1;
			if &imglbp_inc_dx_cond  then imglbp_inc_dx=1;
			if &imglbp_exc_dx_cond  then imglbp_exc_dx=1;
			if &crc_cancer_dx_cond  then crc_cancer_dx=1;
			if &fracture_vd_dx_cond then fracture_vd_dx=1;
			if &sinusitis_dx_cond then sinusitis_dx=1;
			if &other_related_comp_dx_cond then other_related_comp_dx=1;
			if &syncope_dx_cond then syncope_dx=1;
			if &warranted_img_dx_cond then warranted_img_dx=1;
			if &headache_dx_cond then headache_dx=1;
			if &warranted_img2_dx_cond then warranted_img2_dx=1;
			if &eeg_headache_dx_cond then eeg_headache_dx=1;
			if &epilepsy_dx_cond then epilepsy_dx=1;
			if &stroke_etc_dx_cond then stroke_etc_dx=1;
			if &neurologic_dx_cond then neurologic_dx=1;
			if &plantarfasciitis_dx_cond then plantarfasciitis_dx=1;
			if &footpain_dx_cond then footpain_dx=1;
			if &ischemic_dx_cond then ischemic_dx=1;
			if &stroketia_dx_cond then stroketia_dx=1;
			if &folate_dx_cond then folate_dx=1;
			if &kidney_dx_cond then kidney_dx=1;
			if &hypercalcemia_dx_cond then hypercalcemia_dx=1;
	  end;
	end;
	
	%if &clmtype=cr %then %do;
	
		do i=1 to dim(betoscd);
		  if not missing(betoscd(i)) then do;
		  		betos = upcase(betoscd(i));
				if &dialysis_betos_cond then dialysis_betos=1;
				if &low_risk_noncard_betos_cond then low_risk_noncard_betos=1;
		  end;
		end;
	
	%end;

	dialysis = (dialysis_dx or dialysis_betos);
	fracture = (fracture_dx or fracture_cpt);
	fracture_vd = (fracture_vd_dx or fracture_cpt);
	bonemd=(bonemd_cpt or dxa_dx);
	low_risk_noncard = (low_risk_noncard_cpt or low_risk_noncard_betos);
	drop i cptcode dxcode hcpcs_cd1-hcpcs_cd&num_cd. icd_dgns_cd1-icd_dgns_cd25 betos_cd1-betos_cd&num_cd.;
run;

proc freq data=lvc_etl.&clmtype._&year._&chunk._flag;
table &conditions;
run;
%mend flag;


*inpatient;

%macro process_ip();

	%do yr = &yr_start. %to &yr_end.;
		%do nchunk = 1 %to &ip_chunk.;
			%flag(clmtype=ip, year=&yr.,chunk=&nchunk.); 
		%end;
	%end;
	
	data lvc_etl.ip_flag;
	rename clm_admsn_dt = clm_dt;
	rename at_physn_npi = npi;
	set 
	%do yr = &yr_start. %to &yr_end.;
		%do nchunk = 1 %to &ip_chunk.;
			lvc_etl.ip_&yr._&nchunk._flag;     
		%end;
	%end;
	;
	SRC = "IP";
	run;
	
%mend process_ip;

%let op_chunk=1;

%macro process_op();
	%do yr = &yr_start. %to &yr_end.;
		%do nchunk = 1 %to &op_chunk.;
			%flag(clmtype=op, year=&yr.,chunk=&nchunk.); 
		%end;
	%end;
	
	data lvc_etl.op_flag;
	rename clm_thru_dt = clm_dt;
	rename at_physn_npi = npi;
	set 
	%do yr = &yr_start. %to &yr_end.;
		%do nchunk = 1 %to &op_chunk.;
			lvc_etl.op_&yr._&nchunk._flag;     
		%end;
	%end;
	
	SRC = "OP";
	run;
%mend process_op;

%let cr_chunk=1;
%macro process_cr();
	%do yr = &yr_start. %to &yr_end.;
		%do nchunk = 1 %to &cr_chunk.;
			%flag(clmtype=cr, year=&yr.,chunk=&nchunk.); 
		%end;
	%end;
	
	data lvc_etl.cr_flag;
	rename clm_thru_dt = clm_dt;
	rename rfr_physn_npi = npi;
	set 
	%do yr = &yr_start. %to &yr_end.;
		%do nchunk = 1 %to &cr_chunk.;
			lvc_etl.cr_&yr._&nchunk._flag;     
		%end;
	%end;
	SRC = "CR";
	run;
%mend process_cr;

%macro combine_types();
	data lvc_etl.claims_all_flag;
	set lvc_etl.ip_flag 
		lvc_etl.op_flag
		lvc_etl.cr_flag;
	label 
	 psa  = 'HCPCS: PSA test'
	 lvc  = 'flag for Low value care, 1 (Yes) 0(No)'
	 SRC  = 'Source of claim, CR (Carrier) IP(Inpatient) OP(Outpatient)'
	 prostate_dx = 'ICD-10: prostate cancer, elevated PSA, or family history of prostate cancer'
	 cerv = 'HCPCS: cervical cancer screening'
	 cerv_ex= 'ICD-10: High risk for cervical cancer screening' 
	 vitaminD_cpt ='HCPCS:Vitamin D test'
	 chronic_dx ='ICD-10: Chronic conditions for vitaminD test'
	 other_risk_dx ='ICD-10:Other risk factors for vitaminD test'
	 pregnancy_obesity_dx ='Pregnancy/obesity condition for vitaminD test'
	 imglbp = 'HCPCS:imaging of the lower back'
	 imglbp_inc_dx='ICD-10: lower back pain'
	 imglbp_exc_dx='ICD-10: known possible cause for lower back pain'
	 crc ='HCPCS: Colon cancer screening, sigmoidoscopy, colonoscopy, barium enema or Blood occult test' 
	 crc_dx = 'ICD-10: condition for crc'
	 crc_cancer_dx = 'ICD-10:colorectal cancer'
	 canscrn = 'HCPCS:  breast, cervix, colon, or prostate cancer screening'
	 canscrn_dx = 'ICD-10: breast, cervix, colon, or prostate cancer screening'
	 dialysis_dx ='ICD-10: dialysis'
	 dialysis_betos ='BETOS: dialysis'
	 dialysis = 'dialysis (ICD-10 or BETOS)'
	 bonemd_cpt = 'HCPCS: bone mineral density test or dual-energy x-ray absorptiometry (DXA)'
	 dxa_dx ='ICD-10: bone mineral density test or dual-energy x-ray absorptiometry (DXA)' 
	 bonemd = 'Bone mineral density test or dual-energy x-ray absorptiometry (DXA)'
	 osteoporosis_dx = 'ICD-10:osteoporosis' 
	 cancer_dx='ICD-10: cancer'
	 fracture_dx='ICD-10: fragility fracture'
	 fracture_cpt='HCPCS:fragility fracture'
	 fracture = 'fragility fracture (HCPCS and ICD)'
	 hypercoagula='HCPCS:hypercoagulability test'
	 embolism_dx = 'ICD-10: pulmonary embolism or venous embolism with thrombosis'
	 t3 = 'HCPCS:total or free T3 testing'
	 hypothyroidism_dx ='ICD-10: hypothyroidism'
	 fracture_vd_dx = 'ICD-10: fragility fracture, used in labeling LVC for VitaminD test'
	 fracture_vd = 'fragility fracture (HCPCS and ICD), used in labelling LVC for vitaminD test'
	 xray = 'HCPCS: chest x-ray'
	 emergencycare= 'HCPCS: Emergency care'
	 low_risk_noncard_cpt = 'HCPCS:low or intermediate risk non-cardiothoracic surgical procedure'
	 low_risk_noncard_betos='BETOS:low or intermediate risk non-cardiothoracic surgical procedure'
	 low_risk_noncard = 'low or intermediate risk non-cardiothoracic surgical procedure, (HCPCS and BETOS)'
	 echocardiogram = 'HCPCS:echocardiogram' 
	 pulmonary = 'HCPCS: pulmonary function test (PFT)'
	 eenc = 'HCPCS: electrocardiogram, echocardiogram, nuclear medicine imaging, cardiac MRI or CT angiography'
	 maxillofacialCT= 'HCPCS: CT of maxillofacial area'
	 sinusitis_dx ='ICD-10:sinusitis'
	 other_related_comp_dx="ICD-10:other related complications for algorithm 14"
	 headimg = "HCPCS: CT or MRI of head or brain"
	 syncope_dx="ICD-10:syncope"
	 warranted_img_dx="ICD-10:Diagnoses for warranted imaging: epilepsy or convulsions, cerebrovacular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA"
	 headache_dx="ICD-10:diagnoses for headache"
	 warranted_img2_dx="ICD-10: Patients with headache and no other diagnosis for warranted imaging. Diagnoses for warranted imaging: post-tramatic or thunderclap headache, cancer, migraine with hemiplegia or infarction, giant cell arteritis, epilepsy or convulsions, cerebrovascular diseases including stroke/TIA and subarachnoid hemorrhage, head or face trauma, altered mental status, nervous and musculoskeletal system symptoms including gait abnormality, meningismus, disturbed skin sensation and speech deficits, personal history of stroke/TIA or cancer"
	 eeg = "HCPCS:electroencephalogram (EEG)"
	 eeg_headache_dx = "ICD-10: diagnoses for headache, asoociated with EEG LVC labeling"
	 epilepsy_dx="ICD-10:epilepsy or convulsions"
	 carotid = "HCPCS: carotid imaging "
	 stroke_etc_dx="ICD-10: stroke/TIA, retinal vascular occlusion/ischemia, or nervous and musculoskeletal symptoms, asoociated with carotic LVC labeling"
	 neurologic_dx="ICD-10:Other neurologic symptoms: stroke or TIA, history of stroke or TIA, retinal vascular occlusion or ischemia, or nervous or musculoskeletal symptoms"
	 radiographic = "HCPCS: radiographic imaging: foot radiograph, foot MRI, or extemity ultrasound"
	 plantarfasciitis_dx = "ICD-10: Plantar faciitis"
	 footpain_dx = "ICD-10: foot pain"
	 stree = "HCPCS: stress testing, cardiac MRI, CT angiography"
	 ischemic_dx = "ICD: ischemic heart disease or acute myocardial infarction diagnosis" 
	 endarterectomy ="HCPCS: carotid endarterectomy"
	 stroketia_dx = "ICD: stroke or TIA, stroke or TIA, or focal neurological symptoms"
	 homocysteine="HCPCS: homocysteine testing"
	 folate_dx = "ICD:diagnosis of folate or B12 deficiencies"
	 pth = "HCPCS: parathyroid hormone (PTH) measurement" 
	 kidney_dx ="ICD: chronic kidney disease"
	 hypercalcemia_dx = "ICD: hypercalcemia diagnosis"
	;
	drop betos;
	run;
%mend combine_types;


%process_op();
%process_ip();
%process_cr();
%combine_types();
