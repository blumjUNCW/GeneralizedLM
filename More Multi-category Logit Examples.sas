%include '~/IPEDS/RegModel Data Derivation.sas';
proc format;
	value offer
	5,6 = 'Bacc + Cert.'
	7,8 = 'Masters + Cert.'
	9 = 'Doctoral'
	;
quit;

proc standard data=regmodel out=standardized mean=0 std=1;
	var cohort rate;
run;

proc logistic data=standardized;
	format hloffer offer.;
	class hloffer / param=glm;
  model control = cohort rate hloffer / link=glogit;
	ods select responseProfile ParameterEstimates OddsRatios;
run;

/**Make hloffer the response (3 levels) and put control (3 levels) in 
		with cohort and rate as predictors**/

proc logistic data=standardized order=internal;
	format hloffer offer.;
	class control / param=glm;
  model hloffer  = cohort rate control;
	*ods select responseProfile ParameterEstimates OddsRatios;
run;

title 'Proportional Odds';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control;
	ods select fitStatistics;
run;

title 'Proportional Odds for Rate & Control';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes=cohort;
	ods select fitStatistics;
run;

title 'Proportional Odds for Rate & Cohort';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes=control;
	ods select fitStatistics;
run;

title 'Proportional Odds for Cohort & Control';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes=rate;
	ods select fitStatistics;
run;

title 'Proportional Odds for Control';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes=(cohort rate);
	ods select fitStatistics;
run;

title 'Proportional Odds for Rate';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes=(cohort control);
	ods select fitStatistics;
run;

title 'Proportional Odds for Cohort';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes=(rate control);
	ods select fitStatistics;
run;

title 'No Proportional Odds';
proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes;
	ods select fitStatistics;
run;

/***AIC says choose this...***/
title 'No Proportional Odds';
proc logistic data=standardized ;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes;
	ods select responseProfile ParameterEstimates OddsRatios;
run;

title 'No Proportional Odds';
proc logistic data=standardized descending ;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	unequalslopes link=alogit;
	ods select responseProfile ParameterEstimates OddsRatios;
	output out=alogit predprobs=(I);
run;

title 'Generalized Logit';
proc logistic data=standardized descending ;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control
						/	link=glogit;
	ods select responseProfile ParameterEstimates OddsRatios;
  output out=glogit predprobs=(I);
run;