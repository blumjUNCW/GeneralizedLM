proc freq data=sashelp.heart;
	table bp_status chol_status;
run;

proc logistic data=sashelp.heart descending;
	model bp_status = AgeAtStart Weight / link=logit;
	/**If the response is multi-category, logit becomes cumulative logit by default...**/
	*ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=sashelp.heart descending;
	model bp_status = AgeAtStart Weight / link=alogit;
	/**You can request adjacent categories logits with LINK=ALOGIT**/
	*ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=sashelp.heart;
	model bp_status = AgeAtStart Weight / link=logit;
	output out=cumulative predprobs=(I);
run;

proc logistic data=sashelp.heart;
	model bp_status = AgeAtStart Weight / link=alogit;
	output out=adjacent predprobs=(I);
run;

proc freq data=cumulative;
	table _from_*_into_;
run;


proc format;
	value $CholReOrder
	'Desirable'='1. Desirable'
	'Borderline'='2. Borderline'
	'High'='3. High'
	;
run;
proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit;
	*ods select ResponseProfile FitStatistics CumulativeModelTest
		ParameterEstimates OddsRatios;
run;/**Default parameterization of proportional odds for age and
			weight fails (p-value is 0.0675)**/

Title 'Full Proportional Odds';
proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit;
	ods select FitStatistics;
run;

Title 'Proportional odds on weight, not on age';
proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit unequalslopes=AgeAtStart;
	ods select FitStatistics;
run;

Title 'Proportional odds on age, not on weight';
proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit unequalslopes=weight;
	ods select FitStatistics;
run;

Title 'No proportional odds';
proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit unequalslopes;
	ods select FitStatistics;
run;

/**AIC says pick this one...**/
Title 'Proportional odds on age, not on weight';
proc logistic data=sashelp.heart;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit unequalslopes=weight;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc standard data=sashelp.heart out=heartSTD mean=0 std=1;
	var ageAtStart weight;
run;
proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=logit unequalslopes=weight;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	model chol_status = AgeAtStart Weight / link=alogit unequalslopes=weight;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;

/***What if we want to use bp_status (along with age and weight) as a predictor for chol_status?**/
proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	class bp_status(ref='High') / param=glm;
	model chol_status = bp_status AgeAtStart Weight / link=logit;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;/**proportional odds is fine for this...**/

proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	class bp_status / param=glm;
	model chol_status = bp_status AgeAtStart Weight / link=alogit;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	class bp_status(ref='High') / param=glm;
	model chol_status = bp_status|AgeAtStart|Weight @2 / link=logit;
	*ods select ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	class bp_status(ref='High') / param=glm;
	model chol_status = bp_status|AgeAtStart AgeAtStart|Weight / link=logit;
	*ods select ResponseProfile ParameterEstimates OddsRatios;
run;


proc logistic data=heartSTD;
	format chol_status $CholReOrder.;
	class bp_status(ref='High') / param=glm;
	model chol_status = bp_status AgeAtStart|Weight / link=logit;
	*ods select ResponseProfile ParameterEstimates OddsRatios;
run;