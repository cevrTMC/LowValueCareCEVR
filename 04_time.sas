/*

Extract first, last, next service/Dx dates

*/

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
					stablecoronary_dx
					angina_dx 
					thrombosis_dx 
					bonecancer_dx
					lowbackpain_dx radiculopathy_dx
					;
%Let Dim_Var = 35;

/*This SAS macro create varibles for the earliest date, the last date, and the previous date of each of 35 
  conditions, which will be used in low-value-care algorithms. 
 */
%macro firstLastPrevDates(input);
*** Sort claims by ID and date of claim;
proc sort data=com.&input;
	by desy_sort_key clm_dt;
run;

data &input._first;
	set com.&input;
	by desy_sort_key clm_dt;

 	%DO i=1 %TO &Dim_Var.;
 		%let cond = %scan(&hist_conditions,&i,", ");
	
 		if first.desy_sort_key then do; 
			first_&cond.=.; last_&cond.=.;prev_&cond.=.;prev_hold_&cond=.; 
 		end;
 		retain first_&cond. last_&cond. prev_&cond. prev_hold_&cond;

		if not missing(prev_&cond) then prev_hold_&cond = prev_&cond;
 		prev_&cond = .;

 		if &cond then do;
			if(clm_dt ne last_&cond) then 
			  	prev_&cond. = last_&cond.;
			else 
				prev_&cond. = prev_hold_&cond.;  		

			if first_&cond.=. then first_&cond. = clm_dt; 
  			last_&cond. = clm_dt;
 		end;
 		format clm_dt first_&cond. last_&cond. prev_&cond. mmddyy10.;
		drop prev_hold_&cond.;  
 	%end;
 	format DOB_DT agefmt. gndr_cd $genderfmt. bene_race_cd $racefmt.;
run;

proc sort data=&input._first;
	by desy_sort_key clm_dt;
run;

%mend firstLastPrevDates;

%let next_conditions low_risk_noncard 
					 plantarfasciitis_dx
					 dialysis_betos;
%Let Dim_nextVar = 3;

/*This SAS macro create varibles for the next date of each of 3 
  conditions, which will be used in some low-value-care algorithms. 
  next procedure date is applicable only for the claims that that had that procedure.
 */
%macro nextDate(input);

%let sub_id = %substr(&input, 1, %length(&input)-11);
*** Sort claims by ID and date of claim;
proc sort data=&input.;
 	by desy_sort_key descending clm_dt;
run;

data &input._next;
 	set &input.;
	by desy_sort_key descending clm_dt;

 	%DO i=1 %TO &Dim_nextVar.;
 		%let cond = %scan(&next_conditions,&i,", ");

		if first.desy_sort_key then do; 
			next_&cond.=.; next_hold_&cond.=.; last_next_&cond.=.; 
		end;
		retain next_&cond. next_hold_&cond. last_next_&cond.;

		if not missing(next_&cond) then next_hold_&cond = next_&cond;
 		next_&cond = .;

		if &cond then do;
		  if(clm_dt ne last_next_&cond) then 
 			 next_&cond. = last_next_&cond.;
  	  	  else 
			next_&cond. = next_hold_&cond.;
	  	  last_next_&cond. = clm_dt;
	 	end;

		format clm_dt next_&cond. next_hold_&cond. last_next_&cond. mmddyy10.;
 		drop next_hold_&cond. last_next_&cond.;
 	%end;
 run;

proc sort data=&input._next out=date.&sub_id;
	by desy_sort_key clm_dt;
run;

%mend nextDate;



proc datasets library=date kill;
run;

%macro condition_date;
ods output Members=Members;
proc datasets library=com memtype=data;
run;

proc sql; 
select Name into :strings separated by " "  from Members;
quit;

%do index=1 %to %sysfunc(countw(&strings));
    %let input=%scan(&strings,&index,%str( ));
	%put 'date' &input;
	%firstLastPrevDates(&input);
	%nextDate(&input._first); 
	%put &input 'done';
%end;

%mend;

%condition_date;
