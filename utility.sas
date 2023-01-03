/*libname lvc "C:\Users\lliang1\Documents\My SAS Files\9.4\lvc"; */

%macro listdir(dir);
 data yfiles;
 keep filename;
 length fref $8 filename $80;
 rc = filename(fref, &dir);
 if rc = 0 then
 do;
 did = dopen(fref);
 rc = filename(fref);
 end;
 else
 do;
 length msg $200.;
 msg = sysmsg();
 put msg=;
 did = .;
 end;
 if did <= 0
 then
 putlog 'ERR' 'OR: Unable to open directory.';
 dnum = dnum(did);
 do i = 1 to dnum;
 filename = dread(did, i);
 /* If this entry is a file, then output. */
 fid = mopen(did, filename);
 if fid > 0
 then
 output;
 end;
 rc = dclose(did);
 run;
%mend listdir;

%macro check(file);
%if %sysfunc(fileexist(&file)) ge 1 %then %do;
   %let rc=%sysfunc(filename(temp,&file));
   %let rc=%sysfunc(fdelete(&temp));
%end; 
%else %put The file &file does not exist;
%mend check; 



/* del files in a folder */


%let path="C:\Users\lliang1\Documents\My SAS Files\9.4\output";

%macro delete_all(path);
 %listdir(&path);
 
 data _null_;
	set yfiles;
	fname = 'todelete';
	rc = filename(fname, quote(cats(&path,'\',filename)));
	rc = fdelete(fname);
	rc = filename(fname);
 run;
%mend;


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
/*
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
*/
%mend patient_level_output;


%macro toStata;
ods output Members=Members;
proc datasets library=output memtype=data;
run;

data output_memebers;
set members;
lib_name = cat("output.", Name);
run;

proc sql; 
select Name into :strings separated by " "  from output_memebers;
quit;

%do index=1 %to %sysfunc(countw(&strings));
    %let input=%scan(&strings,&index,%str( ));
	%put 'converting' &input;
	PROC EXPORT DATA=output.&input
		OUTFILE="&outdir\&input..dta"			
		DBMS=dta REPLACE;
		fmtlib=work.formats;
	RUN;
%end;
%mend;



/*

%delete_all(&path);
%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\");

%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\");

%check(C:\Users\lliang1\Documents\My SAS Files\9.4\psa_patient_sens.dta)

options dlcreatedir;
libname output ("C:\Users\lliang1\Documents\My SAS Files\9.4\output");
*/

