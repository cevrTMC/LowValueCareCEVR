

proc datasets library=sub kill;
run;

%let grp_ids = 0 1 2 3 4 5 6 7 8 9;

%macro split_on_id(input);
%do i=1 %to %sysfunc(countw(&grp_ids));
	%let cond = %scan(&grp_ids,&i,", ");
	data sub.&input._sub_&cond.;
		set flag.&input;
		grp= substr(desy_sort_key,9,1); 
		if grp =&cond. then output; 
	run;
%end;
%mend;

%macro split_all();
ods output Members=Members;
proc datasets library=flag memtype=data;
run;

data flag_memebers;
set members;
lib_name = cat("flag.", Name);
run;

proc sql; 
select Name into :strings separated by " "  from flag_memebers;
quit;

%do index=1 %to %sysfunc(countw(&strings));
    %let input=%scan(&strings,&index,%str( ));
	%put 'splitting' &input;
    %split_on_id(&input);
	%put &input 'done';
%end;

%mend;


proc datasets library=com kill;
run;

%macro combine_on_id(grp);
ods output Members=subMembers;
proc datasets library=sub memtype=data;
run;

data subMembers;
set subMembers;
lib_name = cat("sub.", Name); 
run;

proc sql; 
select lib_name into :subid separated by " "  from subMembers 
where Name contains "&grp";
quit;

data com.&grp._flag;
set &subid.;
drop betos claim_no clm_drg_cd drg;
run;
%mend;


%macro combine_all();
%do i=1 %to %sysfunc(countw(&grp_ids));
	%let cond = %scan(&grp_ids,&i,", ");
	%combine_on_id(SUB_&cond);
%end;

%mend;

%split_all();
%combine_all();

