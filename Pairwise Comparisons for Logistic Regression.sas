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

proc logistic data=sashelp.heart;
	format bp_status $status.;
	class chol_status(ref='Desirable') / param=glm;
	model bp_status = weight chol_status;
	lsmeans chol_status / exp diff adjust=tukey at weight=125;
	lsmeans chol_status / exp diff adjust=tukey at weight=150;
	lsmeans chol_status / exp diff adjust=tukey at weight=175;
	/**this is parallel lines in the log-odds space,
			so odds ratios among cholesterol status are constant across weight**/
	*ods select lsmeans;
	*ods output diffs=diff;
run;

proc logistic data=sashelp.heart;
	format bp_status $status.;
	class chol_status(ref='Desirable') / param=glm;
	model bp_status = weight|chol_status;
	/**if this interaction is signficant, I expect that the odds ratios
			across cholesterol status will change as weight changes**/
	lsmeans chol_status / exp diff adjust=tukey at weight=100 cl;
	lsmeans chol_status / exp diff adjust=tukey at weight=150 cl;
	lsmeans chol_status / exp diff adjust=tukey at weight=200 cl;
	ods select none;/**turn off the logistic output for stuff like this...**/
	ods output diffs=diffs;/**...send to data set**/
run;

ods select all;
/**Print what I want**/
proc print data=diffs label;
	by weight;
	id weight;
	var chol_status _chol_status expEstimate adjLowerExp adjUpperExp;
	label expEstimate='Odds Ratio'
				adjLowerExp='Lower Limit' adjUpperExp='Upper Limit';
run;


ods graphics off;
proc logistic data=sashelp.heart;
	format chol_status $status.;
	class bp_status sex / param=glm;
	model chol_status = bp_status|sex;
	lsmeans bp_status*sex / exp diff ;
	ods select lsmeans;
	ods output diffs=diff;
run;
Title 'BP Status Comparisons, Conditional on Sex';
proc print data=diff noobs label;
	var sex bp_status _bp_status expEstimate probz;
	where sex eq _sex;
	label expEstimate='Odds Ratio'
				probz='Un-adjusted p-value';
run;
Title 'Sex Comparisons, Conditional on BP Status';
proc print data=diff noobs label;
	var bp_status sex _sex expEstimate probz;
	where bp_status eq _bp_status;
	label expEstimate='Odds Ratio'
				probz='Un-adjusted p-value';
run;

proc logistic data=sashelp.heart;
	format chol_status $status.;
	class bp_status sex / param=glm;
	model chol_status = bp_status|sex;
	slice bp_status*sex  / sliceby=sex diff adjust=tukey exp;
	slice bp_status*sex / sliceby=bp_status diff exp;
	/**slicing categorical interactions is done in its own statement
			in logistic
		options for diff and adjust are there (and exp is also)**/
	ods select sliceTests sliceDiffs;
run;

proc logistic data=sashelp.heart;
	class weight_status / param=glm;
	model bp_status = weight_status;
	lsmeans weight_status / diff adjust=tukey exp cl alpha=0.10;
	ods select responseprofile cumulativemodeltest parameterEstimates OddsRatios
							lsmeans diffs;
run;

proc logistic data=sashelp.heart;
	class chol_status(ref='Desirable') / param=glm;
	model bp_status = weight|chol_status;
	lsmeans chol_status / exp diff adjust=tukey at weight=100;
	lsmeans chol_status / exp diff adjust=tukey at weight=150;
	lsmeans chol_status / exp diff adjust=tukey at weight=200;
	ods select cumulativemodeltest modelanova;
	ods output diffs=diffs;
run;
proc print data=diffs label;
	by weight;
	id weight;
	var chol_status _chol_status expEstimate adjp;
	label expEstimate='Odds Ratio';
run;


proc format;
	value $chol
	'Desirable' = '1. Desirable'
	'Borderline' = '2. Borderline'
	'High' = '3. High'
	;
run;
proc logistic data=sashelp.heart;
	format chol_status $chol.;
	class bp_status sex / param=glm;
	model chol_status = bp_status|sex ;
	ods select cumulativemodeltest;
run;/**Proportional odds fails for this one...**/

proc logistic data=sashelp.heart;
	format chol_status $chol.;
	class bp_status sex / param=glm;
	model chol_status = bp_status|sex / unequalslopes=sex;
	lsmeans bp_status*sex / diff;
	slice bp_status*sex;
	*ods select responseprofile modelanova diffs sliceTests;
	/**if unequalslopes is used on any effect, LSMEANS and SLICE are 
			not available**/
run;

proc logistic data=sashelp.heart;
	format chol_status $chol.;
	class bp_status sex / param=glm;
	model chol_status = bp_status|sex / unequalslopes=sex;
	oddsratio bp_status;
	oddsratio sex;
	*ods select responseprofile;
	ods output OddsRatiosWald=odds;
run;
proc report data=odds;
	column effect oddsratioest lowercl uppercl;
	define effect / order;
	define lowercl / 'Lower Limit';
	define uppercl / 'Upper Limit';
run;

proc logistic data=sashelp.heart;
	class chol_status / param=glm;
	model bp_status = weight|chol_status;
	*oddsratio chol_status / at (weight=100 150 200);
	units weight=10 sd;
	oddsratio weight;
	*ods select OddsRatiosWald;
run;


