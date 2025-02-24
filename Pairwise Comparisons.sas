proc glm data=sashelp.heart;
	class weight_status;
	model systolic = weight_status / solution;
	/**lsmeans-> least-squares means, or model means
		estimates of average in groups via model parameters**/
	lsmeans weight_status  / diff ;
	/**lsmeans --class variable(s)--**/
	/**DIFF requests differences, among all pairs by default**/
	ods select parameterEstimates lsmeans diff;
run;

proc means data=sashelp.heart;
	class weight_status;
	var systolic;
run;/**In this case, model means are same as arithmetic means,
		but not always true**/

proc glm data=sashelp.heart;
	class weight_status;
	model systolic = weight_status / solution;
	lsmeans weight_status  / diff adjust=bon;
	/**adjust= adjusts the test statistic or p-values for multiple testing**/
	ods select parameterEstimates lsmeans diff;
run;

proc glm data=sashelp.heart;
	class weight_status;
	model systolic = weight_status / solution;
	lsmeans weight_status  / diff adjust=tukey;
	/**adjust= tukey is most common for comparing all pairs of categories**/
	ods select parameterEstimates lsmeans diff;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class smoking_status;
	model systolic = smoking_status;
	lsmeans smoking_status / lines adjust=tukey;
	*ods select lsmlines;
run;

ods graphics;
proc glm data=sashelp.heart;
	class smoking_status;
	model systolic = smoking_status;
	lsmeans smoking_status / lines adjust=tukey;
	*ods select lsmlines;
run;

ods graphics;
proc glm data=sashelp.heart;
	class smoking_status;
	model systolic = smoking_status;
	lsmeans smoking_status / diff cl lines adjust=tukey;
	*ods select lsmlines;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class chol_status;
	model systolic = weight chol_status / solution;
	lsmeans chol_status / diff adjust=tukey cl;
	*ods select lsmeans diff;
run;

proc standard data=sashelp.heart out=HeartCentered mean=0;
	var weight;
run;
ods graphics off;
proc glm data=HeartCentered;
	class chol_status;
	model systolic = weight chol_status / solution;
	lsmeans chol_status / diff adjust=tukey;
	/**the plug-in estimator uses the mean for all quantitative predictors**/
	*ods select lsmeans diff;
run;
proc means data=sashelp.heart;
	class chol_status;
	var systolic;
run;/**These are different, the ones from the model
		are adjusted for weight, these are not**/

ods trace on;
proc glm data=sashelp.heart;
	class chol_status;
	model systolic = weight chol_status;
	/**Variable= allows you to select the plug-in value for quantitative stuff...**/
	lsmeans chol_status / diff at weight=100 adjust=tukey cl;
	lsmeans chol_status / diff at weight=125 adjust=tukey cl;
	lsmeans chol_status / diff at weight=150 adjust=tukey cl;
	lsmeans chol_status / diff at weight=200 adjust=tukey cl;
	ods select lsmeans LSMeanDiffCL;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class smoking_status;
	model cholesterol = weight|smoking_status;
	lsmeans smoking_status / diff at weight=100 adjust=tukey;
	lsmeans smoking_status / diff at weight=150 adjust=tukey;
	lsmeans smoking_status / diff at weight=200 adjust=tukey;
	ods select lsmeans diff;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class bp_status sex;
	model cholesterol = bp_status sex / solution;
	lsmeans bp_status / diff adjust=tukey;
	lsmeans sex / diff;
	*ods select lsmeans diff;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class bp_status sex;
	model cholesterol = bp_status sex / solution;
	lsmeans bp_status sex / diff adjust=tukey;
	ods select lsmeans diff;
run;


ods graphics off;
proc glm data=sashelp.heart;
	class bp_status sex;
	model cholesterol = bp_status|sex / solution;
	lsmeans bp_status sex / diff adjust=tukey;
	/**when an interaction is present, we typically do 
		not analyze the individual effects (main effects)
		because we no longer presume they are additive**/
run;

proc glm data=sashelp.heart;
	class bp_status sex;
	model cholesterol = bp_status|sex / solution;
	lsmeans bp_status*sex;
	/**look at a plot of the means...**/
	ods output lsmeans=means;
run;

proc sgplot data=means;
	series x=bp_status y=lsmean / group=sex markers;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class bp_status sex;
	model cholesterol = bp_status|sex / solution;
	lsmeans bp_status*sex / slice=bp_status slice=sex;
		/**slice=effect -- creates a comparison at each level of the listed effect, 
				comparison is across other effect(s) present in the interaction*/
	lsmeans bp_status*sex / diff adjust=tukey lines;
		/**can also ask for all pairwise comparisons among all combinations
			defined by the interaction
			But this often adjusts for things you do not care about...**/
	ods select lsmeans slicedanova lsmlines;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class bp_status sex;
	model cholesterol = bp_status|sex / solution;
	lsmeans bp_status*sex / slice=bp_status slice=sex;
	lsmeans bp_status*sex / diff ;
	lsmeans bp_status*sex / diff adjust=bon alpha=0.10 lines;
	ods select lsmeans slicedanova diff lsmlines;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class bp_status sex weight_status;
	model cholesterol = bp_status|sex|weight_status;
	lsmeans bp_status*sex / slice=bp_status slice=sex;
	lsmeans weight_status / diff adjust=tukey;
run;

ods graphics off;
/**Don't need this in this case, but legal...**/
proc glm data=sashelp.heart;
	class bp_status sex weight_status;
	model cholesterol = bp_status|sex|weight_status;
	lsmeans bp_status*sex*weight_status / slice=bp_status*sex slice=sex*weight_status slice=bp_status*weight_status;
	ods output lsmeans=means;
run;

proc sgpanel data=means;
	panelby sex;
 	series x=bp_status y=CholesterolLSMean / group=weight_status markers;
run;
