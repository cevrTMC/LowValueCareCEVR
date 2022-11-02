/*
libname lvc_src 'C:\Users\lliang1\Documents\My SAS Files\9.4\lvc';
libname lvc_etl 'C:\Users\lliang1\Documents\My SAS Files\9.4\lvc_etl';
libname ccw 'C:\Users\lliang1\Documents\My SAS Files\9.4\ccw'; 
*/
%let outdir= C:\Users\lliang1\Documents\My SAS Files\9.4\output;

Proc format lib=work.formats;
value agefmt
0 = "Unknown"
1 = "<65"
2 = "65-69"
3 = "70-74"
4 = "75-79"
5 = "80-84"
6 = ">84";

value $genderfmt
'0'= "Unknown"
'1' = "Male"
'2' = "Female";

value $racefmt
'0'='Unknown'
'1'='White'
'2'='Black'
'3'='Other'
'4'='Asian'
'5'='Hispanic'
'6'='North American Native';

value racefmt
0='Unknown'
1='White'
2='Black'
3='Other'
4='Asian'
5='Hispanic'
6='North American Native';

value sexfmt
0= "Unknown"
1 = "Male"
2 = "Female";

run;

*** Find the first claim date, first claim date in the window, and last claim date for each comorbidity/service;
%let hist_conditions prostate_dx cerv_ex crc_dx dialysis hypothyroidism_dx
					 embolism_dx osteoporosis_dx cancer_dx fracture fracture_vd
					 chronic_dx other_risk_dx pregnancy_obesity_dx
					imglbp_inc_dx imglbp_exc_dx
					bonemd crc_cancer_dx
					low_risk_noncard
					sinusitis_dx
					eeg_headache_dx
					epilepsy_dx
					neurologic_dx
					syncope_dx
					footpain_dx
					ischemic_dx
					stroketia_dx
					kidney_dx
					hypercalcemia_dx
					dialysis_betos
					;
%Let Dim_Var = 29;

%macro FindFirstDxDate();
*** Sort claims by ID and date of claim;
proc sort data=lvc_etl.claims_all_flag;
	by desy_sort_key clm_dt;
run;

data lvc_etl.claims_all_flag_firstDx;
	set lvc_etl.claims_all_flag;
	by desy_sort_key clm_dt;

 	%DO i=1 %TO &Dim_Var.;
 		%let cond = %scan(&hist_conditions,&i,", ");
	
 		if first.desy_sort_key then do; 
			&cond._date=.; first_&cond.=.; last_&cond.=.;prev_&cond.=.; 
 		end;
 		retain first_&cond. last_&cond. hosp_&cond. prev_&cond.;

 		if &cond then do;
  			prev_&cond. = last_&cond.;
  			&cond._date = clm_dt;
  			if first_&cond.=. then first_&cond. = clm_dt; 
  			last_&cond. = clm_dt;
 		end;

 		format clm_dt &cond._date first_&cond. last_&cond. prev_&cond. mmddyy10.;
 	%end;
 	format DOB_DT agefmt. gndr_cd $genderfmt. bene_race_cd $racefmt.;
run;

%mend FindFirstDxDate;

%let next_conditions low_risk_noncard 
					 plantarfasciitis_dx
					 dialysis_betos;
%Let Dim_nextVar = 3;

%macro nextDxDate(input);
*** Sort claims by ID and date of claim;
proc sort data=&input.;
 	by desy_sort_key descending clm_dt;
run;

data &input._nextDx;
 	set &input.;
	by desy_sort_key descending clm_dt;

 	%DO i=1 %TO &Dim_nextVar.;
 		%let cond = %scan(&next_conditions,&i,", ");

 		if first.desy_sort_key then do; 
			next_&cond.=.; 
 		end;
 		retain next_&cond. ;

 	if &cond then do;
 		 next_&cond. = clm_dt;
 	end;
 	format clm_dt next_&cond. mmddyy10.;
 	%end;
run;

proc sort data=&input._nextDx;
	by desy_sort_key clm_dt;
run;

%mend nextDxDate;


/* list all patient ids with flag indicating whether the patient had ever received the lvc */
%macro collapse(input, flag, output);
proc sort data=&input. out=&output.;
	by desy_sort_key descending &flag.;
run;

data &output.(keep=desy_sort_key race num);
 	set &output.;
 	by desy_sort_key;
 	num = &flag.;
 	if first.desy_sort_key then output;
run;

%mend collapse;

/*output analytic data, tranfrom to STATA format */
%macro patient_level_output(input,output);

/*reformat race */
data tmp;
	set &input.;
	race_numeric = input(BENE_RACE_CD, 2.);
	format race_numeric racefmt.;
	drop BENE_RACE_CD;
	rename race_numeric=race;

	gender_numeric = input(gndr_cd, 2.);
	format gender_numeric sexfmt.;
	drop gndr_cd;
	rename gender_numeric=gender;
run;

%collapse(tmp,lvc, &output.);

proc freq data=&output.;
table num /missing;
run;

PROC EXPORT DATA=tmp
	OUTFILE="&outdir\&input..dta"			
	DBMS=dta REPLACE;
	fmtlib=work.formats;
RUN;

PROC EXPORT DATA=&output.
	OUTFILE="&outdir\&output..dta"			
	DBMS=dta REPLACE;
	fmtlib=work.formats;
RUN;

%mend patient_level_output;

%FindFirstDxDate();
%nextDxDate(lvc_etl.claims_all_flag_firstDx);

