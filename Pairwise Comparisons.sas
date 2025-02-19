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
