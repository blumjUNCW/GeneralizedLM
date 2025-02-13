proc freq data=regmodel;
	table control hloffer;
	format control hloffer 1.;
run;
proc freq data=regmodel;
	table control hloffer;
run;

proc format;
	value publpriv
	1='Public'
	2,3='Private'
	;
run;

proc logistic data=regmodel;
	format control publpriv.;
	class hloffer / param=glm;
  model control = cohort rate hloffer;
	ods select responseProfile ParameterEstimates OddsRatios;
run;

proc means data=regmodel;
	class control;
	format control publpriv.;
	var rate cohort;
run;

proc logistic data=regmodel;
	format control publpriv.;
	class hloffer(ref='Post-master^s certificate') / param=glm ;
  model control = cohort rate hloffer;
	ods select responseProfile ParameterEstimates OddsRatios;
run;

/**Standardize cohort and rate, reduce hloffer to Below Masters, Below Doctoral, Doctoral
	and refit the model**/

proc format;
	value offer
	5,6 = 'Below Masters'
	7,8 = 'Below Doctoral'
	9 = 'Doctoral'
	;
quit;

proc standard data=regmodel out=standardized mean=0 std=1;
	var cohort rate;
run;

proc logistic data=standardized descending;
	format control publpriv. hloffer offer.;
	class hloffer / param=glm;
  model control = cohort rate hloffer;
	ods select responseProfile ParameterEstimates OddsRatios;
run;


proc logistic data=standardized descending;
	format control publpriv. hloffer offer.;
	class hloffer(ref='Below Doctoral') / param=glm;
  model control = cohort rate hloffer;
	ods select responseProfile ParameterEstimates OddsRatios;
run;


proc logistic data=standardized descending;
	format control publpriv. hloffer offer.;
	class hloffer / param=glm;
  model control = cohort|rate|hloffer @2;
	/**Like GLM, interactions are permitted on the predictor side in the same style**/
	*ods select responseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=standardized descending;
	format control publpriv. hloffer offer.;
	class hloffer / param=glm;
  model control = cohort|hloffer rate;
	/**Like GLM, interactions are permitted on the predictor side in the same style**/
	ods select responseProfile ParameterEstimates OddsRatios;
run;