proc format;
	value $status
	'High'='High'
	other = 'Not High'
	;
run;
proc logistic data=sashelp.heart;
	format bp_status $status.;
	class weight_status / param=glm;
	model bp_status = weight_status;
	lsmeans weight_status / diff;
	/**works like LSMEANS in GLM, but everything is log-odds...**/
	ods select parameterEstimates lsmeans diffs;
run;

proc logistic data=sashelp.heart;
	format bp_status $status.;
	class weight_status / param=glm;
	model bp_status = weight_status;
	lsmeans weight_status / exp diff;
	/**EXP--exponentiate everything -> change log-odds to odds**/
	ods select parameterEstimates oddsratios lsmeans diffs;
run;

proc logistic data=sashelp.heart;
	format bp_status $status.;
	class weight_status / param=glm;
	model bp_status = weight_status;
	lsmeans weight_status / exp diff adjust=tukey;
	/**Tukey adjustment (and others) are still available for the comparisons...**/
	ods select parameterEstimates oddsratios lsmeans diffs;
run;


proc logistic data=sashelp.heart;
	format bp_status $status.;
	class weight_status / param=glm;
	model bp_status = weight_status;
	lsmeans weight_status / exp diff adjust=tukey cl;
	/**...and you can put intervals on all of it**/
	ods select parameterEstimates oddsratios lsmeans diffs;
run;

proc logistic data=sashelp.heart;
	format bp_status $status.;
	class chol_status(ref='Desirable') / param=glm;
	model bp_status = weight chol_status;
	lsmeans chol_status / exp diff adjust=tukey;
	*ods select lsmeans;
	*ods output diffs=diff;
run;

proc means data=sashelp.heart;
	var weight;
run;

proc logistic data=sashelp.heart;
	format bp_status $status.;
	class chol_status(ref='Desirable') / param=glm;
	model bp_status = weight chol_status;
	lsmeans chol_status / exp diff adjust=tukey at weight=153;
	/**just like LSMEANS in GLM, the mean is used for any quantitative predictor**/
	*ods select lsmeans;
	*ods output diffs=diff;
run;

