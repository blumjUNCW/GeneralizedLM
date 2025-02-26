ods graphics off;
proc glm data=sashelp.heart;
	class smoking_status;
	model systolic = smoking_status / solution;
	lsmeans smoking_status;
	estimate 'Non-Smokers vs Smokers' smoking_status 
								-0.25 -0.25 -0.25 1 -0.25;
	/**ESTIMATE 'label' model-effect coefficient/weights <more effects and coefficients>**/
	estimate 'Non-Smokers vs Smokers v2' smoking_status 1 1 1 -4 1 / divisor=4;
	estimate 'Lighter Smokers vs Heavier Smokers' smoking_status -1 1 1 0 -1
						/ divisor=2;
	estimate 'Light Smokers vs Other Smokers' smoking_status -1 3 -1 0 -1
						/ divisor=3;
	*ods select ParameterEstimates lsmeans estimates;
run;

ods graphics off;
proc glm data=sashelp.heart;
	class smoking_status;
	model systolic = smoking_status / solution;
	lsmeans smoking_status;
	estimate 'Non-Smokers vs Smokers' smoking_status 
								-0.25 -0.25 -0.25 1 0;
	/**Sometimes things that seem like they should work do not...
			but we can fix this in MIXED**/
run;

proc mixed data=sashelp.heart;
	class smoking_status;
	model systolic = smoking_status;
	lsmeans smoking_status;
	/**LSMESTIMATE->construct the estimate based on the LSMEANS, not
			the model parameters**/
	lsmestimate smoking_status 'Non-Smokers vs Smokers' 1 1 1 -4 1 / divisor=4;
	lsmestimate smoking_status 'Lighter Smokers vs Heavier Smokers' -1 1 1 0 -1
			/ divisor=2;
	lsmestimate smoking_status 'Light Smokers vs Other Smokers' -1 3 -1 0 -1
			/ divisor=3;
	ods select lsmestimates;
run;

proc glm data=sashelp.heart;
		class smoking_status;
		model systolic = smoking_status;
		lsmeans smoking_status;
		*contrast 'Non-Smokers vs Smokers' smoking_status 1 1 1 -4 1;
		*contrast 'Non-Smokers vs Smokers B' smoking_status -0.25 -0.25 -0.25 1 -0.25;
		contrast 'What is this?' smoking_status 1 -1 0 0 0,
														 smoking_status 1 1 -2 0 0,
														 smoking_status 1 1 1 -3 0,
														 smoking_status 1 1 1 1 -4;
														/**can give a comma-separated list of contrasts, which
																results in the sum of all of those contrasts**/
		contrast 'And this?'     smoking_status 1 -1 0 0 0,
														 smoking_status 1 0 -1 0 0,
														 smoking_status 1 0 0 -1 0,
														 smoking_status 1 0 0 0 -1,
														 smoking_status 0 1 -1 0 0,
														 smoking_status 0 1 0 -1 0,
														 smoking_status 0 1 0 0 -1,
														 smoking_status 0 0 1 -1 0,
														 smoking_status 0 0 1 0 -1,
														 smoking_status 0 0 0 1 -1
															;		
		ods select 'Type III Model ANOVA' contrasts lsmeans;
run;

proc glm data=sashelp.heart;
	class smoking_status;
	model cholesterol = weight|smoking_status / solution;
	estimate 'Light v. Non-Smoker Slopes' weight*smoking_status 0 1 0 -1 0;
	estimate 'Non-Smoker Slope' weight 1 weight*smoking_status 0 0 0 1 0;
	estimate 'Light Smoker Slope' weight 1 weight*smoking_status 0 1 0 0 0;
	*ods select parameterestimates estimates;
run;

proc mixed data=sashelp.heart;
	class smoking_status;
	model cholesterol = weight|smoking_status / solution;
	estimate 'Light v. Non-Smoker Slopes' weight*smoking_status 0 1 0 -1 0 / cl;
	estimate 'Non-Smoker Slope' weight 1 weight*smoking_status 0 0 0 1 0 / cl;
	estimate 'Light Smoker Slope' weight 1 weight*smoking_status 0 1 0 0 0 / cl;
	*ods select parameterestimates estimates;
run;


proc format;
	value $status
	'High'='High'
	other = 'Not High'
	;
run;
proc logistic data=sashelp.heart;
	format bp_status $status.;
	class chol_status / param=glm;
	model bp_status = weight|chol_status;
	estimate 'Weight Effect, Borderline v. Desirable Cholesterol'
							weight*chol_status 1 -1 0 / exp cl;
	estimate 'Weight Effect, Borderline Cholesterol'
							weight 1 weight*chol_status 1 0 0 / exp cl;
	estimate 'Weight Effect, Desirable Cholesterol'
						weight 1 weight*chol_status 0 1 0 / exp cl;
	*ods select none;
	*ods output estimates=ests;
run;

proc logistic data=sashelp.heart;
	class chol_status / param=glm;
	model bp_status = weight|chol_status;
	estimate 'Weight Effect, Borderline v. Desirable Cholesterol'
							weight*chol_status 1 -1 0 / exp cl;
	estimate 'Weight Effect, Borderline Cholesterol'
							weight 1 weight*chol_status 1 0 0 / exp cl;
	estimate 'Weight Effect, Desirable Cholesterol'
							weight 1 weight*chol_status 0 1 0 / exp cl;
	*ods select cumulativemodeltest;
	*ods output estimates=ests;
run;