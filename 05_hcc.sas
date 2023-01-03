
filename inf  "C:\Users\lliang1\Documents\My SAS Files\9.4\F2422P1M";
libname library  "C:\Users\lliang1\Documents\My SAS Files\9.4";
proc cimport library=library infile=inf;
run;



%let IDVAR = desy_sort_key;
%LET N_CC=204; %*max # of HCCs;
%let FMNAME0=012224Y21Y22MC;
%let SEDITS = 0;

%let keepvars = desy_sort_key IND ICD_DGNS_CD1-ICD_DGNS_CD25 CC1-CC&N_CC HCC1-HCC&N_CC;


%MACRO V24I0ED2(AGE=, SEX=, ICD10= );
 %**********************************************************************
 ***********************************************************************
 1  MACRO NAME:  V24I0ED2
                 UDXG update V0122 for V24 model (payment HCCs only)
                 ICD10 codes valid in FY21/FY22
 2  PURPOSE:     age/sex edits on ICD10: some edits are mandatory, 
                 others - are based on MCE list to check
                 if age or sex for a beneficiary is within the
                 range of acceptable age/sex, if not- CC is set to 
                 -1.0 - invalid
 3  PARAMETERS:  AGE   - beneficiary age variable calculated by DOB
                         from a person level file
                 SEX   - beneficiary SEX variable in a person level file
                 ICD10  - diagnosis variable in a diagnosis file

 4  COMMENTS:    1. Age format AGEFMT0 and sex format SEXFMT0 are 
                    parameters in the main macro. They have to 
                    correspond to the years of data

                 2. If ICD10 code does not have any restriction on age
                    or sex then the corresponding format puts it in "-1"

                 3. AGEL format sets lower limits for age
                    AGEU format sets upper limit for age
                    for specific edit categories:
                    "0"= "0 newborn (age 0)      "
                    "1"= "1 pediatric (age 0 -17)"
                    "2"= "2 maternity (age 9 -64)"
                    "3"= "3 adult (age 15+)      "

                 4. SEDITS - parameter for the main macro
 **********************************************************************;
   %* reset of CCs that is based on beneficiary age or sex;
   IF &SEX="2" AND &ICD10 IN ("D66", "D67")  THEN CC="48"; 
   ELSE
   IF &AGE < 18 AND &ICD10 IN ("J410", "J411", "J418", "J42",  "J430",
                               "J431", "J432", "J438", "J439", "J440",
                               "J441", "J449", "J982", "J983") 
                                             THEN CC="112";
   ELSE 
   IF (&AGE < 6 OR &AGE > 18) AND &ICD10 = "F3481"
                                             THEN CC="-1.0";

  %* MCE edits if needed (should be decided by a user by setting
     parameter SEDITS);
  %IF &SEDITS = 1 %THEN %DO;
     %* check if Age is within acceptable range;
     _TAGE=PUT(&ICD10, $&AGEFMT0..);
     IF _TAGE NE "-1" AND
        (&AGE < INPUT(PUT(_TAGE, $AGEL.),8.) OR
         &AGE > INPUT(PUT(_TAGE, $AGEU.),8.)) THEN CC='-1.0';

     %* check if Sex for a person is the one in the MCE file;
     _TSEX=PUT(&ICD10, $&SEXFMT0..);
     IF _TSEX NE "-1"  & _TSEX NE &SEX THEN CC='-1.0';

  %END;
%MEND V24I0ED2;


%MACRO V24H86H1; 
 %**********************************************************************
 1  MACRO NAME: V24H86H1
 2  PURPOSE:    HCC HIERARCHIES: version 24 of HCCs,
                only 86 CMS HCCs are included
 3  COMMENT:    it is assumed that:
                 -MAX number of CCs are placed into global macro 
                  variable N_CC in the main program
                 -the following arrays are set in the main program
                  ARRAY C(&N_CC)   CC1-CC&N_CC
                  ARRAY HCC(&N_CC) HCC1-HCC&N_CC
                 -format ICD to CC creates only 86 out of &N_CC CMS CCs
 **********************************************************************;
 %* set to 0 HCCs in HIER parameter;
 %MACRO SET0( CC=, HIER= );
     IF HCC&CC=1 THEN DO I = &HIER; HCC(I) = 0; END;
 %MEND SET0;

 %*to copy CC into HCC;
  DO K=1 TO &N_CC;
     HCC(K)=C(K);
  END;

 %*imposing hierarchies;
 /*Neoplasm 1 */   %SET0(CC=8     , HIER=%STR(9, 10, 11, 12 ));
 /*Neoplasm 2 */   %SET0(CC=9     , HIER=%STR(10, 11, 12 ));
 /*Neoplasm 3 */   %SET0(CC=10    , HIER=%STR(11, 12 ));
 /*Neoplasm 4 */   %SET0(CC=11    , HIER=%STR(12 ));
 /*Diabetes 1 */   %SET0(CC=17    , HIER=%STR(18, 19 ));
 /*Diabetes 2 */   %SET0(CC=18    , HIER=%STR(19 ));
 /*Liver 1 */      %SET0(CC=27    , HIER=%STR(28, 29, 80 ));
 /*Liver 2 */      %SET0(CC=28    , HIER=%STR(29 ));
 /*Blood 1 */      %SET0(CC=46    , HIER=%STR(48 ));
 /*Cognitive 2 */  %SET0(CC=51    , HIER=%STR(52 ));
 /*SUD 1 */        %SET0(CC=54    , HIER=%STR(55, 56 ));
 /*SUD 2 */        %SET0(CC=55    , HIER=%STR(56 ));
 /*Psychiatric 1 */%SET0(CC=57    , HIER=%STR(58, 59, 60 ));
 /*Psychiatric 2 */%SET0(CC=58    , HIER=%STR(59, 60 ));
 /*Psychiatric 3 */%SET0(CC=59    , HIER=%STR(60 ));
 /*Spinal 1 */     %SET0(CC=70    , HIER=%STR(71, 72, 103, 104, 169 ));
 /*Spinal 2 */     %SET0(CC=71    , HIER=%STR(72, 104, 169 ));
 /*Spinal 3 */     %SET0(CC=72    , HIER=%STR(169 ));
 /*Arrest 1 */     %SET0(CC=82    , HIER=%STR(83, 84 ));
 /*Arrest 2 */     %SET0(CC=83    , HIER=%STR(84 ));
 /*Heart 2 */      %SET0(CC=86    , HIER=%STR(87, 88 ));
 /*Heart 3 */      %SET0(CC=87    , HIER=%STR(88 ));
 /*CVD 1 */        %SET0(CC=99    , HIER=%STR(100 ));
 /*CVD 5 */        %SET0(CC=103   , HIER=%STR(104 ));
 /*Vascular 1 */   %SET0(CC=106   , HIER=%STR(107, 108, 161, 189 ));
 /*Vascular 2 */   %SET0(CC=107   , HIER=%STR(108 ));
 /*Lung 1 */       %SET0(CC=110   , HIER=%STR(111, 112 ));
 /*Lung 2 */       %SET0(CC=111   , HIER=%STR(112 ));
 /*Lung 5 */       %SET0(CC=114   , HIER=%STR(115 ));
 /*Kidney 3 */     %SET0(CC=134   , HIER=%STR(135, 136, 137, 138 ));
 /*Kidney 4 */     %SET0(CC=135   , HIER=%STR(136, 137, 138 ));
 /*Kidney 5 */     %SET0(CC=136   , HIER=%STR(137, 138 ));
 /*Kidney 6 */     %SET0(CC=137   , HIER=%STR(138 ));
 /*Skin 1 */       %SET0(CC=157   , HIER=%STR(158, 159, 161 ));
 /*Skin 2 */       %SET0(CC=158   , HIER=%STR(159, 161 ));
 /*Skin 3 */       %SET0(CC=159   , HIER=%STR(161 ));
 /*Injury 1 */     %SET0(CC=166   , HIER=%STR(80, 167 ));

%MEND V24H86H1;



/*
DOB_DT 
0 = Unknown
1 = <65
2 = 65 Thru 69
3 = 70 Thru 74
4 = 75 Thru 79
5 = 80 Thru 84
6 = >84
*/


%macro hcc(input);

data hcc.&input;
LENGTH CC $4. 
       CC1-CC&N_CC HCC1-HCC&N_CC 3.;
LENGTH dgscd $5.; 
RETAIN CC1-CC&N_CC 0 ;
ARRAY C(&N_CC)  CC1-CC&N_CC;
ARRAY HCC(&N_CC) HCC1-HCC&N_CC; 
array dxcodes(25) $10 ICD_DGNS_CD1-ICD_DGNS_CD25;

set date.&input.;
by desy_sort_key clm_dt; 
if first.desy_sort_key then do;
	do i =1 to &N_CC;
		C(i)=0;
	end;
end;

do i=1 to dim(dxcodes);
   if not missing(dxcodes(i)) then do;
	   dgscd = upcase(dxcodes(i));  
	   CC="9999";
	   %V24I0ED2(age=65, sex=GNDR_CD, ICD10=dgscd);
       IF CC NE "-1.0" AND CC NE "9999" THEN DO;
           IND=INPUT(CC,4.);
           IF 1 <= IND <= &N_CC THEN C(IND)=1;
        END;
        ELSE IF CC="9999" THEN DO;
           ** assignment 1 **;
           IND = INPUT(LEFT(PUT(dgscd,$IAS1&FMNAME0..)),4.);
           IF 1 <= IND <= &N_CC THEN C(IND)=1;
           ** assignment 2 **;
           IND = INPUT(LEFT(PUT(dgscd,$IAS2&FMNAME0..)),4.);
           IF 1 <= IND <= &N_CC THEN C(IND)=1;
      
       END;
    end;
end;
%V24H86H1;

drop CC CC1-CC&N_CC IND i K ICD_DGNS_CD1-ICD_DGNS_CD25; 
run;
%mend hcc;


/*
proc catalog c = library.formats;
contents stat;
run;
*/


%macro condition_hcc;
ods output Members=Members;
proc datasets library=date memtype=data;
run;

proc sql; 
select Name into :strings separated by " "  from Members;
quit;

%do index=1 %to %sysfunc(countw(&strings));
    %let input=%scan(&strings,&index,%str( ));
	%put 'date' &input;
	%hcc(&input); 
	%put &input 'done';
%end;

%mend;

