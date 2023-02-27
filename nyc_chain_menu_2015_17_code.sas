/*Code for results in “Sodium content of menu items in New York City chain restaurants following enforcement of the sodium warning icon rule, 2015-2017”*/
/*Dataset posted on Github: https://github.com/nychealth/sodium-icon-menu-analysis/blob/main/nyc_chain_menu_2015_17.sas7bdat*/
/*Please review accompanying README file and codebook posted on Github: https://github.com/nychealth/sodium-icon-menu-analysis*/

/*Call in dataset - example call-in satement below*/
libname sodium_icon_menu_analysis 'C:\MyFolder'; /*replace libname if another preference; replace filepath to location where dataset saved*/
/*1763 observations and 17 variables.*/

data long;
set sodium_icon_menu_analysis.nyc_chain_menu_2015_17; /*set statement = libname assigned in call-in statement above, filename of dataset posted to github repository*/
run;
/*1763 observations and 17 variables.*/

/***************************************************
Tables 1 & 2****************************************
***************************************************/

title 'All items';
proc means data=long n mean;
	var sodium_per_serv warn;
		by year meal_type;
run;

proc sort; by year full_service meal_type; run;
proc means data=long n mean;
	var sodium_per_serv warn;
		by year full_service meal_type;
run;

proc sort data=long; by year full_service; run;

proc means data=long n mean;
	var sodium_per_serv warn;
		by year full_service;
run;

proc sort; by year; run;

proc means data=long n mean;
	var sodium_per_serv warn;
		by year;
run;

proc sort data=long; by year meal_type full_service; run;

title 'Items available in both years';

proc means data=long n mean;
	var sodium_per_serv warn;
		by year meal_type;
			where match_id = 'M';
run;

proc means data=long n mean;
	var sodium_per_serv warn;
		by year meal_type full_service;
			where match_id = 'M';
run;

proc sort; by year full_service; run;

proc means data=long n mean;
	var sodium_per_serv warn;
		by year full_service;
			where match_id = 'M';
run;

proc sort; by year; run;

proc means data=long n mean;
	var sodium_per_serv warn;
		by year;
			where match_id = 'M';
run;


proc sort; by year meal_type full_service; run;

title 'Items introduced/discontinued in year 2';

proc means data=long n mean ;
	var sodium_per_serv warn;
		by year meal_type;
			where match_id in('D','N');
run;

proc means data=long n mean ;
	var sodium_per_serv warn;
		by year meal_type full_service;
			where match_id in('D','N');
run;

proc sort; by year full_service; run;

proc means data=long n mean ;
	var sodium_per_serv warn;
		by year full_service;
			where match_id in('D','N');
run;

proc sort; by year; run;

proc means data=long n mean;
	var sodium_per_serv warn;
		by year;
			where match_id in('D','N');
run;

/**************************************************************************
Figure 2******************************************************************
***************************************************************************/
title 'All food items, adjusted';
proc sort data=long; by descending year;
proc mixed data=long method=reml covtest order=data;
	ods output LSMeans=lsm_all SolutionF=est_all;
    class restaurant_id year;
   	model sodium_per_serv = year full_service non_main combo/solution ddfm=bw cl outp=check_mix;
	random int /subject=restaurant_id ;
	lsmeans year/cl;
run;
quit;

title 'Matched food items';
proc sort data=long; by descending year;
proc mixed data=long method=reml covtest order=data;
	ods output LSMeans=lsm_all SolutionF=est_all;
	where match_id = 'M';
    class restaurant_id year;
   	model sodium_per_serv = year full_service non_main combo/solution ddfm=bw cl outp=check_mix;
	random int /subject=restaurant_id ;
	lsmeans year/cl;
	lsmeans year/ at non_main = 1 cl;
	lsmeans year/ at non_main = 0 cl;
run;
quit;

title 'New v. discontinued food items';
proc sort data=long; by descending year;
proc mixed data=long method=reml covtest order=data;
	ods output LSMeans=lsm_all SolutionF=est_all;
	where match_id in('N','D');
    class restaurant_id year;
   	model sodium_per_serv = year full_service non_main combo /solution ddfm=bw cl outp=check_mix;
	random int /subject=restaurant_id ;
	lsmeans year/cl;
	lsmeans year/ at non_main = 1 cl;
	lsmeans year/ at non_main = 0 cl;
run;
quit;

/**************************************************************************
Figure 3******************************************************************
***************************************************************************/

title 'Logistic regression, with random intercept';
title2 'All food';

proc glimmix data=long;
class restaurant_id;
model warn = year full_service non_main combo/dist=binomial  link=logit s oddsratio (diff=first label);
random intercept /subject=restaurant_id;
run;

title2 'Matched food';
title3 'All';
proc glimmix data=long;
where match_id = 'M';
class restaurant_id;
model warn = year full_service non_main combo/dist=binomial  link=logit s oddsratio (diff=first label);
random intercept /subject=restaurant_id;
run;

title2 'New vs. discontinued food';
title3 'All';
proc glimmix data=long;
 where food = 1 and match_id in('N','D');
class restaurant_id;
model warn = year full_service non_main combo/dist=binomial  link=logit s oddsratio (diff=first label);
random intercept /subject=restaurant_id;
run;

/**************END***************/