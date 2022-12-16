
# Hierarchical Condition Categorie (HCC)

To calculate HCC, this program uses part of codes from [2023 CMS-HCC
Risk Adjustment Model
Software](https://www.cms.gov/medicarehealth-plansmedicareadvtgspecratestatsrisk-adjustors/2023-model-softwareicd-10-mappings)

More information on HCC

[CMS HCC Software
guide](https://www.cms.gov/files/document/hhs-hcc-software-v0417-127-m2-descriptionpdf)
.

### Input data files for HHS-CC/HCC variable creation

This section describes the two input data files needed to create HHS-CC
and HHS-HCC grouping and regression variables—a person-level file and a
diagnosis-level file. It is the responsibility of the user to create
these input data files with the variables listed in this section.

Person-level dataset example (PERSON) containing six variables; we use
ID as the person identifier variable to illustrate: - person level file
has the following variables:

-   :&IDVAR - person ID variable (it is a macro parameter)
-   :DOB - date of birth
-   :SEX - sex
-   :OREC - original reason for entitlement
-   :LTIMCAID - Medicaid dummy variable for LTI
-   :NEMCAID - Medicaid dummy variable for new enrollees

| ID  | DOB      | SEX |
|-----|----------|-----|
| 201 | 19541201 | M   |
| 202 | 20040315 | F   |
| 301 | 19680101 | F   |
| 302 | 19660131 | M   |

-   Diagnosis dataset example (DIAGNOSIS) containing three variables; we
    use ID as the person identifier variable and ICD-10 diagnoses to
    illustrate:

| ID  | DIAG   |
|-----|--------|
| 201 | E118   |
| 201 | M9319  |
| 201 | M532X9 |
| 202 | Z430   |

Algorithm to produce output

Step 1: First, the program crosswalks diagnoses to Condition Categories
(CCs) using SAS formats

1.  perform diag edits using macro &EDITMAC0

2.  create CC using corresponding formats for ICD10

3.  assign additional CC using provided additional formats

Step 2: creates Hierarchical Condition Categories (HCCs) by imposing
hierarchies on the CCs.

-   using hierarchies (macro &HIERMAC)

Step 3: After HCCs are created the program computes predicted scores
from 9 regression models (We don’t need this step).

macro &HIERMAC

``` sas
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
```

SAS Macro to calculate HCC

``` sas
 %MACRO V2422P2M(INP=, IND=, OUTDATA=, IDVAR=, KEEPVAR=, SEDITS=,
                 DATE_ASOF=, DATE_ASOF_EDIT=, 
                 FMNAME0=012224Y21Y22MC, 
                 AGEFMT0=IAGEHYBCY21MCE, 
                 SEXFMT0=ISEXHYBCY21MCE, DF=1, 
                 AGESEXMAC=AGESEXV2, LABELMAC=V24H86L1, 
                 EDITMAC0=V24I0ED2,  
                 HIERMAC=V24H86H1, SCOREMAC=SCOREVAR);

%**********************************************************************
 * Assumptions about input files:
 *   - both files are sorted by person ID
 *   - person level file has the following variables:
 *     :&IDVAR   - person ID variable (it is a macro parameter)
 *     :DOB      - date of birth
 *     :SEX      - sex
 *     :OREC     - original reason for entitlement
 *     :LTIMCAID - Medicaid dummy variable for LTI
 *     :NEMCAID  - Medicaid dummy variable for new enrollees
 *
 *   - diagnosis level file has the following variables:
 *     :&IDVAR  - person ID variable (it is a macro parameter)
 *     :DIAG    - diagnosis
 *
 * Parameters:
 * INP            - input person dataset
 * IND            - input diagnosis dataset
 * OUTDATA        - output dataset
 * IDVAR          - name of person id variable (MBI for Medicare data)
 * KEEPVAR        - variables to keep in the output file
 * SEDITS         - a switch that controls whether to perform MCE edits 
 *                  on ICD10. 1-YES, 0-NO
 * DATE_ASOF      - reference date to calculate age. Set to February 1
 *                  of the payment year for consistency with CMS.
 * DATE_ASOF_EDIT - reference date to calculate age used for 
 *                  validation of diagnoses (MCE edits)
 * FMNAME0        - format name (crosswalk ICD10 to V24 CCs)
 * AGEFMT0        - format name (crosswalk ICD10 to acceptable age range
 *                  in case MCE edits on diags are to be performed)
 * SEXFMT0        - format name (crosswalk ICD10 to acceptable sex in 
 *                  case MCE edits on diags are to be performed)
 * DF             - normalization factor.
 *                  Default=1
 * AGESEXMAC      - external macro name: create age/sex,
 *                  originally disabled, disabled vars
 * EDITMAC0       - external macro name: perform edits to ICD10
 * LABELMAC       - external macro name: assign labels to HCCs
 * HIERMAC        - external macro name: set HCC=0 according to
 *                  hierarchies
 * SCOREMAC       - external macro name: calculate a score variable
 *
 **********************************************************************;

 %**********************************************************************
 * step1: include external macros
 **********************************************************************;
 %IF "&AGESEXMAC" ne "" %THEN %DO;
     %INCLUDE IN0(&AGESEXMAC) /SOURCE2; %* create demographic variables;
 %END;
 %IF "&EDITMAC0" ne "" %THEN %DO;
     %INCLUDE IN0(&EDITMAC0)   /SOURCE2; %* perform edits on ICD10;
 %END;
 %IF "&LABELMAC" ne "" %THEN %DO;
     %INCLUDE IN0(&LABELMAC)  /SOURCE2; %* hcc labels;
 %END;
 %IF "&HIERMAC" ne "" %THEN %DO;
     %INCLUDE IN0(&HIERMAC)   /SOURCE2; %* hierarchies;
 %END;
 %IF "&SCOREMAC" ne "" %THEN %DO;
     %INCLUDE IN0(&SCOREMAC)  /SOURCE2; %* calculate score variable;
 %END;

 %**********************************************************************
 * step2: define internal macro variables
 **********************************************************************;

 %LET N_CC=204; %*max # of HCCs;


 %**********************************************************************
 * step3: merge person and diagnosis files outputting one record
 *        per person with score and HCC variables for each input person
 *        level record
 ***********************************************************************;

 DATA &OUTDATA(KEEP=&KEEPVAR );
   %****************************************************
    * step3.1: declaration section
    ****************************************************;

    %IF "&LABELMAC" ne "" %THEN %&LABELMAC;  *HCC labels;

   %* length of new variables (length for other age/sex vars is set in
      &AGESEXMAC macro);
    LENGTH CC $4. 
           AGEF 
           OriginallyDisabled_Female  
           OriginallyDisabled_Male
           &NE_REG
           CC1-CC&N_CC
           HCC1-HCC&N_CC
           &DIAG_CAT
           &INTERRACC_VARSA
           &INTERRACC_VARSD
           &INTERRACI_VARS 
           AGEF_EDIT 
           HCC_pymt &ADDZ
           3.;

    %*retain cc vars;
    RETAIN CC1-CC&N_CC 0  AGEF AGEF_EDIT;
    %*arrays;
    ARRAY C(&N_CC)  CC1-CC&N_CC;
    ARRAY HCC(&N_CC) HCC1-HCC&N_CC;
    %*interaction vars;
    ARRAY RV &INTERRACC_VARSA &INTERRACC_VARSD 
          &INTERRACI_VARS &DIAG_CAT HCC_pymt &ADDZ;

    %***************************************************
    * step3.2: to bring in regression coefficients
    ****************************************************;
    IF _N_ = 1 THEN SET INCOEF.HCCCOEFN;
    %***************************************************
    * step3.3: merge
    ****************************************************;
    MERGE &INP(IN=IN1)
          &IND(IN=IN2);
    BY &IDVAR;

    IF IN1 THEN DO;

    %*******************************************************
    * step3.4: for the first record for a person set CC to 0
    ********************************************************;

       IF FIRST.&IDVAR THEN DO;
          %*set ccs to 0;
           DO I=1 TO &N_CC;
            C(I)=0;
           END;
           %* age;
           AGEF =FLOOR((INTCK(
                'MONTH',DOB,&DATE_ASOF)-(DAY(&DATE_ASOF)<DAY(DOB)))/12);
           IF AGEF<0 THEN AGEF=0;

           %IF "&DATE_ASOF_EDIT" ne "" %THEN  
           AGEF_EDIT =FLOOR((INTCK('MONTH',DOB,&DATE_ASOF_EDIT)
                -(DAY(&DATE_ASOF_EDIT)<DAY(DOB)))/12);
           %ELSE AGEF_EDIT=AGEF;
           ;
       END;         

    %***************************************************
    * step3.5 if there are any diagnoses for a person
    *         then do the following:
    *         - perform diag edits using macro &EDITMAC0
    *         - create CC using corresponding formats for ICD10
    *         - assign additional CC using provided additional formats
    ****************************************************;

     IF IN1 & IN2 THEN DO;
          %*initialize;
          CC="9999";
          
     %IF "&FMNAME0" NE "" %THEN %DO;     
      %IF "&EDITMAC0" NE "" %THEN 
                 %&EDITMAC0(AGE=AGEF_EDIT,SEX=SEX,ICD10=DIAG); 
            IF CC NE "-1.0" AND CC NE "9999" THEN DO;
               IND=INPUT(CC,4.);
               IF 1 <= IND <= &N_CC THEN C(IND)=1;
            END;
            ELSE IF CC="9999" THEN DO;
               ** assignment 1 **;
               IND = INPUT(LEFT(PUT(DIAG,$IAS1&FMNAME0..)),4.);
               IF 1 <= IND <= &N_CC THEN C(IND)=1;
               ** assignment 2 **;
               IND = INPUT(LEFT(PUT(DIAG,$IAS2&FMNAME0..)),4.);
               IF 1 <= IND <= &N_CC THEN C(IND)=1;
          
           END;
          %END;
          
       END; %*CC creation;  


    %*************************************************************
    * step3.6 for the last record for a person do the
    *         following:
    *         - create demographic variables needed (macro &AGESEXMAC)
    *         - create HCC using hierarchies (macro &HIERMAC)
    *         - create HCC interaction variables
    *         - create HCC and DISABL interaction variables
    *         - set HCCs and interaction vars to zero if there
    *           are no diagnoses for a person
    *         - create scores for community models
    *         - create score for institutional model
    *         - create score for new enrollee model
    *         - create score for SNP new enrollee model
    **************************************************************;
       IF LAST.&IDVAR THEN DO;

           %****************************
           * demographic vars
           *****************************;
           %*create age/sex cells, originally disabled, disabled vars;
           %IF "&AGESEXMAC" ne "" %THEN
           %&AGESEXMAC(AGEF=AGEF, SEX=SEX, OREC=OREC);


           IF IN1 & IN2 THEN DO;
            %**********************
            * hierarchies
            **********************;
            %IF "&HIERMAC" ne "" %THEN %&HIERMAC;
 
           END; *there are some diagnoses for a person;
           ELSE DO;
              DO I=1 TO &N_CC;
                 HCC(I)=0;
              END;
              DO OVER RV;
                 RV=0;
              END;
           END;
           *HCC Counts;
           ARRAY CHPYMT(86) &HCCV24_list86;
           ARRAY ZS(9) D1-D9;
           HCC_pymt = sum(of CHPYMT(*));
           do i = 1 to dim(ZS) ;
              ZS(i)=(HCC_pymt=i);
           end ;
           D10P=(HCC_pymt>=10);

           LABEL
              ;

           %*score calculation;

          OUTPUT &OUTDATA;
       END; %*last record for a person;
     END; %*there is a person record;
 RUN;

 %MEND V2422P2M;
```

1.  perform diag edits using macro &EDITMAC0

``` sas
%MACRO V22I0ED3(AGE=, SEX=, ICD10= );
 %**********************************************************************
 ***********************************************************************
 1  MACRO NAME:  V22I0ED3
                 UDXG update V122 for V22 model 
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
 %MEND V22I0ED3;
```
