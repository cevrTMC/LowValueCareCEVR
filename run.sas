proc datasets library=sub kill;
run;

%split_all();

proc datasets library=com kill;
run;
%combine_all();

proc datasets library=date kill;
run;
%condition_date;

proc datasets library=hcc kill;
run;
%condition_hcc;

proc datasets library=output kill;
run;
quit;

%let inputdata= sub_0;

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
/*32*/%alg_tract(&inputdata);
/*33*/%alg_eleccard(&inputdata);
/*34*/%alg_cardistress(&inputdata);
/*35*/%alg_echocard(&inputdata);
/*36*/%alg_advimg(&inputdata);
/*40*/%alg_echocard40(&inputdata);
/*41*/%alg_cardistress41(&inputdata);
/*42*/%alg_echocard42(&inputdata);
/*43*/%alg_xray43(&inputdata);
/*44*/%alg_advimg44(&inputdata);
%toStata;	
/*%listdir("C:\Users\lliang1\Documents\My SAS Files\9.4\output");*/
