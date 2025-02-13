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

proc logistic data=standardized;
	format hloffer offer.;
	class control / param=glm;
  model hloffer(order=internal)  = cohort rate control;
	*ods select responseProfile ParameterEstimates OddsRatios;
run;