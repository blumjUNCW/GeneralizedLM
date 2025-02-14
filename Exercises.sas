libname mydata '/export/viya/homes/blumj@uncw.edu/GenLM';

proc format;
	value pov
	10-high = 'High Poverty'
	other = 'Low Poverty'
	;
run;

proc logistic data=mydata.cdi descending;
	class region / param=glm;
	model poverty = Region ba_bs over65;
	format poverty pov.;
	ods select modelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

/**Do Exercises 3, 5, & 6**/