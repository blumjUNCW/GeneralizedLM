libname mydata '~/GenLM';

/*1a*/
ods graphics off;
proc glm data=mydata.cdi;
	class region;
 	model inc_per_cap = ba_bs region;
	lsmeans region / diff adjust=tukey cl lines;
run;

/*1b*/
ods graphics off;
proc glm data=mydata.cdi;
	class region;
 	model inc_per_cap = ba_bs|region / solution;
	lsmeans region / diff adjust=tukey at ba_bs=15 lines;
	lsmeans region / diff adjust=tukey at ba_bs=20 lines;
	lsmeans region / diff adjust=tukey at ba_bs=25 lines;
/**pull these from a quartile summary on BA/BS**/
	ods select lsmlines;
run; 


proc means data=mydata.cdi min q1 median mean q3 max;
	class region;
	var ba_bs;
run;

/**check the slope differences...**/
proc glm data=mydata.cdi;
	class region;
 	model inc_per_cap = ba_bs|region / solution;
	estimate 'BA-BS Effect, Region 1 vs Region 2' ba_bs*region 1 -1 0 0;
	estimate 'BA-BS Effect, Region 1 vs Region 3' ba_bs*region 1 0 -1 0;
	estimate 'BA-BS Effect, Region 1 vs Region 4' ba_bs*region 1 0 0 -1;
	estimate 'BA-BS Effect, Region 2 vs Region 3' ba_bs*region 0 1 -1 0;
	estimate 'BA-BS Effect, Region 2 vs Region 4' ba_bs*region 0 1 0 -1;
	estimate 'BA-BS Effect, Region 3 vs Region 4' ba_bs*region 0 0 1 -1;
run;

/**4**/
proc format;
	value babs
	low-<20 = 'Below 20%'
	other = 'At least 20%'
	;
	value old
	low-<12 = 'Below 12%'
	other = 'At least 12%'
	;
run;

proc glm data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs|over65;
run;

proc glm data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs|over65 @2;
run;

proc glm data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs region|over65;
run;

proc glm data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs over65;
run;/**this is where we should land...**/

ods graphics off;
proc glm data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs over65;
	lsmeans over65 / diff;
run;

ods graphics off;
proc mixed data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs over65;
	slice region*ba_bs / sliceby=region diff;
	slice region*ba_bs / sliceby=ba_bs diff adjust=tukey;
run;

/**get a comparison of the difference between regions 1 and 2 for their average difference
		across the ba/bs categories -- i.e. test to see if the 6306.01 is significantly more
													than the 3376.85**/

ods graphics off;
proc mixed data=mydata.cdi;
	class region ba_bs over65;
	format ba_bs babs. over65 old.;
	model inc_per_cap = region|ba_bs over65;
	slice region*ba_bs / sliceby=region diff;
	lsmeans region*ba_bs; 
	lsmestimate region*ba_bs 'BA/BS comparison for region 1'  1 -1 0 0 0 0 0 0;
	lsmestimate region*ba_bs 'BA/BS comparison for region 2'  0 0 1 -1 0 0 0 0;
	lsmestimate region*ba_bs 'Compare those ^^^' 1 -1 -1 1 0 0 0 0;
	lsmestimate region*ba_bs 'Region 3 vs Region 4 BA/BS effect' 0 0 0 0 1 -1 -1 1 ;
run;

/**5**/
proc format;
	value poverty
	10-high='High Poverty'
	other='Low Poverty'
	;
run;

proc logistic data=mydata.cdi;
	class region;
	format poverty poverty.;
	model poverty = region|ba_bs|over65;
run;
ods graphics off;
proc logistic data=mydata.cdi;
	class region / param=glm;
	format poverty poverty.;
	model poverty = region|ba_bs|over65 @2;
	lsmeans region / exp diff adjust=tukey at ba_bs=15 lines;
	lsmeans region / exp diff adjust=tukey at ba_bs=20 lines;
	lsmeans region / exp diff adjust=tukey at ba_bs=25 lines;
run;

proc means data=mydata.cdi min q1 median mean q3 max;
	class region;
	var ba_bs over65;
run;

ods graphics off;
proc logistic data=mydata.cdi;
	class region / param=glm;
	format poverty poverty.;
	model poverty = region|ba_bs|over65 @2;
	lsmeans region / exp diff adjust=tukey at over65=9 lines;
	lsmeans region / exp diff adjust=tukey at over65=11 lines;
	lsmeans region / exp diff adjust=tukey at over65=13 lines;
run;

ods graphics off;
proc logistic data=mydata.cdi;
	class region / param=glm;
	format poverty poverty.;
	model poverty = region|ba_bs|over65 @2;
	estimate 'BA-BS Effect, Region 1 vs Region 2' ba_bs*region 1 -1 0 0 / exp;
	estimate 'BA-BS Effect, Region 1 vs Region 3' ba_bs*region 1 0 -1 0 / exp;
	estimate 'BA-BS Effect, Region 1 vs Region 4' ba_bs*region 1 0 0 -1 / exp;
	estimate 'BA-BS Effect, Region 2 vs Region 3' ba_bs*region 0 1 -1 0 / exp;
	estimate 'BA-BS Effect, Region 2 vs Region 4' ba_bs*region 0 1 0 -1 / exp;
	estimate 'BA-BS Effect, Region 3 vs Region 4' ba_bs*region 0 0 1 -1 / exp;
run;

ods graphics off;
proc logistic data=mydata.cdi;
	class region / param=glm;
	format poverty poverty.;
	model poverty = region|ba_bs|over65 @2;
	estimate 'Over 65 Effect, Region 1 vs Region 2'over65*region 1 -1 0 0 / exp;
	estimate 'Over 65 Effect, Region 1 vs Region 3'over65*region 1 0 -1 0 / exp;
	estimate 'Over 65 Effect, Region 1 vs Region 4'over65*region 1 0 0 -1 / exp;
	estimate 'Over 65 Effect, Region 2 vs Region 3'over65*region 0 1 -1 0 / exp;
	estimate 'Over 65 Effect, Region 2 vs Region 4'over65*region 0 1 0 -1 / exp;
	estimate 'Over 65 Effect, Region 3 vs Region 4'over65*region 0 0 1 -1 / exp;
run;

/**9**/
data sale;
	set sashelp.prdsale;
	if predict eq 0 then ratio = 1000;
		else 	ratio = actual/predict;
	diff = actual-predict;
run;

proc format;
	value diff
	0-high = 'Exceeds Prediction'
	other = 'Less than Predicted'
	;
run;

proc means data=sashelp.prdsale q1 median q3;
	var predict;
	class quarter;
run;

ods graphics off;
proc logistic data=sale;
	class quarter / param=glm;
	model diff = predict|quarter;
	format diff diff.;
	lsmeans quarter / diff adjust=tukey exp at predict=250 lines alpha=0.10;
	lsmeans quarter / diff adjust=tukey exp at predict=500 lines alpha=0.10;
	lsmeans quarter / diff adjust=tukey exp at predict=750 lines alpha=0.10;
	estimate 'Predict Effect, Quarter 1 vs Quarter 2' predict*quarter 1 -1 0 0 / exp;
	estimate 'Predict Effect, Quarter 1 vs Quarter 3' predict*quarter 1 0 -1 0 / exp;
	estimate 'Predict Effect, Quarter 1 vs Quarter 4' predict*quarter 1 0 0 -1 / exp;
	estimate 'Predict Effect, Quarter 2 vs Quarter 3' predict*quarter 0 1 -1 0 / exp;
	estimate 'Predict Effect, Quarter 2 vs Quarter 4' predict*quarter 0 1 0 -1 / exp;
	estimate 'Predict Effect, Quarter 3 vs Quarter 4' predict*quarter 0 0 1 -1 / exp;
run;