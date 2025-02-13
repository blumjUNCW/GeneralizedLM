proc format;
	value $type
		'Sedan','Wagon'='Car'
		'Truck','SUV'='Truck'
	;
run;/**Classify cars and trucks with a format...**/

proc logistic data=sashelp.cars descending;
	where type not in ('Sports','Hybrid');/**..leave others out**/
	model type = weight enginesize; 
	/**response is type--which is a character variable, but that is fine--response is treated as categorical
			and, like other statements/options for categorical variables, the active format determines the categories**/
	format type $type.;
run;

proc genmod data=sashelp.cars;
	where type not in ('Sports','Hybrid');
	format type $type.;
	model type = weight enginesize / dist=binomial ;
	/**depending on your choice for DIST=, the response variable may be treated as categorical...
		DIST=BINOMIAL sets up the binary/Bernoulli response. The default link is logit and the response
		is taken as categorical and uses the active format to define categories**/
run;

proc standard data=sashelp.cars out=carsSTD mean=0 std=1;
	var weight engineSize;
run;
proc logistic data=carsSTD descending;
	where type not in ('Sports','Hybrid');/**..leave others out**/
	model type = weight enginesize; 
	/**response is type--which is a character variable, but that is fine--response is treated as categorical
			and, like other statements/options for categorical variables, the active format determines the categories**/
	format type $type.;
	output out=predict predprobs=(I);
run;


proc logistic data=carsSTD;
	where type not in ('Sports','Hybrid');
	class origin;
	model type = origin weight enginesize;
	format type $type.;
	ods select ParameterEstimates;
	ods output parameterEstimates=parameters;
run;

proc genmod data=carsSTD;
	where type not in ('Sports','Hybrid');
	format type $type.;
	class origin;
	model type = origin weight enginesize / dist=binomial link=logit;
	ods select ParameterEstimates;
run;

ods trace on;
proc logistic data=carsSTD;
	where type not in ('Sports','Hybrid');
	class origin / param=glm;
	/**PARAM= is technically an option, but usually it is best to include PARAM=GLM when using categorical predictors**/
	model type = origin weight enginesize;
	format type $type.;
	ods select ParameterEstimates OddsRatios responseprofile;
run;

proc logistic data=sashelp.cars;
	where type not in ('Sports','Hybrid');
	class origin / param=glm;
	/**PARAM= is technically an option, but usually it is best to include PARAM=GLM when using categorical predictors**/
	model type = origin weight enginesize;
	format type $type.;
	ods select ParameterEstimates OddsRatios;
run;