proc logistic data=sashelp.cars;
	model origin = horsepower weight mpg_city msrp length;
 /** If the response variable has more than 2 levels (formatted) logistic assumes multinomial...
			but it also assumes an ordinal response and applies the cumulative logit link**/
	*ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

proc logistic data=sashelp.cars;
	model origin(ref='Europe')= horsepower weight mpg_city msrp length / link=glogit;
	/**for nominal responses, you'll want to use LINK=GLOGIT to get the generalized logit**/
	*ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
  ods select responseProfile;
	ods output parameterEstimates=params oddsRatios=odds;
run;

proc report data=params;
	column Response variable estimate WaldChiSq ProbChiSq;
	define Response / group;
	define estimate / display;
run;

proc report data=odds;
	column Response effect oddsratioest LowerCl UpperCL;
	define Response / group;
	define oddsratioest--uppercl / format=f20.10;
run;

proc standard data=sashelp.cars out=carsSTD mean=0 std=1;
	var horsepower weight mpg_city msrp length;
run;

proc logistic data=carsSTD;
	model origin(ref='Europe') = horsepower weight mpg_city msrp length / link=glogit;
	/**for nominal responses, you'll want to use LINK=GLOGIT to get the generalized logit**/
	*ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
  ods select responseProfile;
	ods output parameterEstimates=params oddsRatios=odds;
run;

proc report data=params;
	column Response variable estimate WaldChiSq ProbChiSq;
	define Response / group;
	define estimate / display;
run;

proc report data=odds;
	column Response effect oddsratioest LowerCl UpperCL;
	define Response / group;
	define oddsratioest--uppercl / format=f5.3;
run;