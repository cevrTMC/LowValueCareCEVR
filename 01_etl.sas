options dlcreatedir;

libname ccw 'C:\Users\lliang1\Documents\My SAS Files\9.4\ccw'; 
libname etl 'C:\Users\lliang1\Documents\My SAS Files\9.4\etl';
libname output 'C:\Users\lliang1\Documents\My SAS Files\9.4\output';
libname flag 'C:\Users\lliang1\Documents\My SAS Files\9.4\flag';
libname sub 'C:\Users\lliang1\Documents\My SAS Files\9.4\sub';
libname com 'C:\Users\lliang1\Documents\My SAS Files\9.4\com';
libname date 'C:\Users\lliang1\Documents\My SAS Files\9.4\date';
libname stata 'C:\Users\lliang1\Documents\My SAS Files\9.4\stata';





proc datasets library=etl kill;
run;
quit;

%macro etl_lds_ip(year=, chunk=);
	%let ipvars = DESY_SORT_KEY claim_no clm_admsn_dt at_physn_npi bene_race_cd dob_dt gndr_cd
	hcpcs_cd1-hcpcs_cd200 icd_dgns_cd1-icd_dgns_cd25 CLM_DRG_CD;

	/* SORT INPATIENT REVENUE CENTER FILE IN PREPARATION FOR TRANSFORMATION */
	proc sort data=ccw.inp_revenuek_lds_&year._&chunk. out=ip&year._&chunk.line; 
		by DESY_SORT_KEY claim_no clm_line_num; 
	run; 

	title "SORTED INPATIENT REVENUE CENTER FILE";
	proc print data=ip&year._&chunk.line(obs=10); 
		var DESY_SORT_KEY claim_no clm_line_num hcpcs_cd; 
	run;

	/* TRANSFORM INPATIENT REVENUE CENTER FILE */
	data ip&year._&chunk.line_wide(drop=i clm_line_num hcpcs_cd);
		format  hcpcs_cd1-hcpcs_cd200 $5.;
		set ip&year._&chunk.line;
		by DESY_SORT_KEY claim_no clm_line_num;
		retain 	hcpcs_cd1-hcpcs_cd200;

		array	xhcpcs_cd(200) hcpcs_cd1-hcpcs_cd200;

		if first.claim_no then do;
			do i=1 to 200;
				xhcpcs_cd(clm_line_num)='';
			end;
		end;

		xhcpcs_cd(clm_line_num)=hcpcs_cd;
	 
		if last.claim_no then output;
	run;

	title "TRANSFORMED INPATIENT REVENUE CENTER FILE";
	proc print data=ip&year._&chunk.line_wide(obs=2); 
		var DESY_SORT_KEY claim_no hcpcs_cd1 hcpcs_cd2 hcpcs_cd3; 
	run;

	/* SORT BASE CLAIM AND TRANSFORMED REVENUE CENTER FILES IN PREPARATION FOR MERGE */
	proc sort data=ccw.inp_claimsk_lds_&year._&chunk. out=ip&year._&chunk.claim; 
		by DESY_SORT_KEY claim_no; 
	run; 

	title "SORTED INPATIENT BASE CLAIM FILE";
	proc print data=ip&year._&chunk.claim(obs=10); 
		var DESY_SORT_KEY claim_no clm_admsn_dt; 
	run;

	proc sort data=ip&year._&chunk.line_wide; by DESY_SORT_KEY claim_no; run; 

	/* MERGE INPATIENT BASE CLAIM AND TRANSFORMED REVENUE CENTER FILES */
	data etl.ip_&year._&chunk. ip_nomatch;
		merge ip&year._&chunk.claim(in=a) ip&year._&chunk.line_wide(in=b);
		by DESY_SORT_KEY claim_no;
		if a and b then output etl.ip_&year._&chunk.; else output ip_nomatch;
	run;

	title "MERGED INPATIENT REVENUE CENTER AND BASE CLAIM FILES";
	proc print data=etl.ip_&year._&chunk.(obs=2); 
		var DESY_SORT_KEY claim_no hcpcs_cd1 hcpcs_cd2 hcpcs_cd3 clm_admsn_dt; 
	run;

	data etl.ip_&year._&chunk.(keep=&ipvars);
	set etl.ip_&year._&chunk.;
	run;
%mend etl_lds_ip;

%macro etl_lds_op(year=, chunk=);
	%let opvars = DESY_SORT_KEY claim_no clm_thru_dt at_physn_npi bene_race_cd dob_dt gndr_cd
	hcpcs_cd1-hcpcs_cd200 icd_dgns_cd1-icd_dgns_cd25;
	/* SORT OUTPATIENT REVENUE CENTER FILE IN PREPARATION FOR TRANSFORMATION */
	proc sort data=ccw.out_revenuek_lds_&year._&chunk. out=op&year._&chunk.line; 
		by DESY_SORT_KEY claim_no clm_line_num; 
	run; 

	title "SORTED OUTPATIENT REVENUE CENTER FILE";
	proc print data=op&year._&chunk.line(obs=10); 
		var DESY_SORT_KEY claim_no clm_line_num hcpcs_cd; 
	run;

	/* TRANSFORM INPATIENT REVENUE CENTER FILE */
	data op&year._&chunk.line_wide(drop=i clm_line_num hcpcs_cd);
		format  hcpcs_cd1-hcpcs_cd200 $5.;
		set op&year._&chunk.line;
		by DESY_SORT_KEY claim_no clm_line_num;
		retain 	hcpcs_cd1-hcpcs_cd200;

		array	xhcpcs_cd(200) hcpcs_cd1-hcpcs_cd200;

		if first.claim_no then do;
			do i=1 to 200;
				xhcpcs_cd(clm_line_num)='';
			end;
		end;

		xhcpcs_cd(clm_line_num)=hcpcs_cd;
	 
		if last.claim_no then output;
	run;

	title "TRANSFORMED OUTPATIENT REVENUE CENTER FILE";
	proc print data=op&year._&chunk.line_wide(obs=2); 
		var DESY_SORT_KEY claim_no hcpcs_cd1 hcpcs_cd2 hcpcs_cd3; 
	run;

	/* SORT BASE CLAIM AND TRANSFORMED REVENUE CENTER FILES IN PREPARATION FOR MERGE */
	proc sort data=ccw.out_claimsk_lds_&year._&chunk. out=op&year._&chunk.claim; 
		by DESY_SORT_KEY claim_no; 
	run; 

	title "SORTED OUTPATIENT BASE CLAIM FILE";
	proc print data=op&year._&chunk.claim(obs=10); 
		var DESY_SORT_KEY claim_no clm_thru_dt; 
	run;

	proc sort data=op&year._&chunk.line_wide; by DESY_SORT_KEY claim_no; run; 

	/* MERGE INPATIENT BASE CLAIM AND TRANSFORMED REVENUE CENTER FILES */
	data etl.op_&year._&chunk. op_nomatch;
		merge op&year._&chunk.claim(in=a) op&year._&chunk.line_wide(in=b);
		by DESY_SORT_KEY claim_no;
		if a and b then output etl.op_&year._&chunk.; else output op_nomatch;
	run;

	title "MERGED OUTPATIENT REVENUE CENTER AND BASE CLAIM FILES";
	proc print data=etl.op_&year._&chunk.(obs=2); 
		var DESY_SORT_KEY claim_no hcpcs_cd1 hcpcs_cd2 hcpcs_cd3 clm_thru_dt; 
	run;

	data etl.op_&year._&chunk.(keep=&opvars);
	set etl.op_&year._&chunk.;
	run;
%mend etl_lds_op;

%macro etl_lds_cr(year=, chunk=);
	%let crvars = DESY_SORT_KEY claim_no clm_thru_dt rfr_physn_npi bene_race_cd dob_dt gndr_cd
	hcpcs_cd1-hcpcs_cd200 icd_dgns_cd1-icd_dgns_cd25 betos_cd1-betos_cd200;
	/* SORT CARRIER REVENUE CENTER FILE IN PREPARATION FOR TRANSFORMATION */
	proc sort data=ccw.car_linek_lds_&year._&chunk. out=car&year._&chunk.line; 
		by DESY_SORT_KEY claim_no line_num; 
	run; 

	proc print data=car&year._&chunk.line(obs=10); 
		var DESY_SORT_KEY claim_no line_num hcpcs_cd; 
	run;

	data car&year._&chunk.line_wide(drop=i line_num hcpcs_cd);
		format  hcpcs_cd1-hcpcs_cd200 betos_cd1-betos_cd200 $5.;
		set car&year._&chunk.line;
		by DESY_SORT_KEY claim_no line_num;
		retain 	hcpcs_cd1-hcpcs_cd200 betos_cd1-betos_cd200;

		array	xhcpcs_cd(200) hcpcs_cd1-hcpcs_cd200;
		array  xbetos_cd(200) betos_cd1-betos_cd200;
		if first.claim_no then do;
			do i=1 to 200;
				xhcpcs_cd(line_num)='';
				xbetos_cd(line_num)='';
			end;
		end;

		xhcpcs_cd(line_num)=hcpcs_cd;
		xbetos_cd(line_num)=betos_cd;
	 
		if last.claim_no then output;
	run;

	proc print data=car&year._&chunk.line_wide(obs=2); 
		var DESY_SORT_KEY claim_no hcpcs_cd1 hcpcs_cd2 hcpcs_cd3; 
	run;

	proc sort data=ccw.car_claimsk_lds_&year._&chunk. out=car&year._&chunk.claim; 
		by DESY_SORT_KEY claim_no; 
	run; 

	title "SORTED CARRIER BASE CLAIM FILE";
	proc print data=car&year._&chunk.claim(obs=10); 
		var DESY_SORT_KEY claim_no clm_thru_dt; 
	run;

	proc sort data=car&year._&chunk.line_wide; by DESY_SORT_KEY claim_no; run; 

	data etl.cr_&year._&chunk. car_nomatch;
		merge car&year._&chunk.claim(in=a) car&year._&chunk.line_wide(in=b);
		by DESY_SORT_KEY claim_no;
		if a and b then output etl.cr_&year._&chunk.; else output car_nomatch;
	run;

	title "MERGED CARRIER REVENUE CENTER AND BASE CLAIM FILES";
	proc print data=etl.cr_&year._&chunk.(obs=2); 
		var DESY_SORT_KEY claim_no hcpcs_cd1 hcpcs_cd2 hcpcs_cd3 clm_thru_dt; 
	run;

	data etl.cr_&year._&chunk.(keep=&crvars);
	set etl.cr_&year._&chunk.;
	run;
	
%mend etl_lds_cr;

%etl_lds_cr(year=2017, chunk=1);
%etl_lds_ip(year=2017, chunk=1);
%etl_lds_op(year=2017, chunk=1);


