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
/**3**/
proc format;
	value babs
	20-high = 'High BA/BS'
	other = 'Low BA/BS'
	;
run;

data cdi;
	set mydata.cdi;
	popDensity = (pop/land)/100;
  crimeRate = (crimes/pop)*100;
run;

proc logistic data=cdi;
	class region / param=glm;
	model ba_bs = region over65 popDensity crimeRate;
	format ba_bs babs.;
	ods select modelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

/**5**/
ods trace on;
proc logistic data=mydata.cdi;
	model region = ba_bs inc_per_cap pop18_34 / link=glogit;
	ods select modelInfo ResponseProfile ModelANOVA  OddsRatios;
run;

proc standard data=mydata.cdi out=cdiStd mean=0 std=1;
	var inc_per_cap;
run;

proc logistic data=cdiStd;
	model region = ba_bs inc_per_cap pop18_34 / link=glogit;
	ods select modelInfo ResponseProfile ModelANOVA  OddsRatios;
	output out=predict predprobs=(I);
run;
proc freq data=predict;
	table _from_*_into_;
run;

/*6*/
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool;
	*ods select modelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

Title 'Proportional Odds';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool;
	ods select fitstatistics;
run;

Title 'unequalslopes=(sq_ft)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(sq_ft);
	ods select fitstatistics;
run;

Title 'unequalslopes=(price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(price);
	ods select fitstatistics;
run;

Title 'unequalslopes=(pool)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(pool);
	ods select fitstatistics;
run;

Title 'unequalslopes=(sq_ft price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(sq_ft price);
	ods select fitstatistics;
run;

Title 'unequalslopes=(sq_ft pool)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(sq_ft pool);
	ods select fitstatistics;
run;

Title 'unequalslopes=(price pool)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(price pool);
	ods select fitstatistics;
run;

Title 'unequalslopes=(sq_ft price pool)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(sq_ft price pool);
	ods select fitstatistics;
run;

Title 'SBC says use: unequalslopes=(price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(price);
	*ods select ParameterEstimates ResponseProfile OddsRatios;
run;

Title 'AIC says use: unequalslopes=(sq_ft price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(sq_ft price) link=alogit;
	*ods select ParameterEstimates OddsRatios;
run;

/**For these two models, and the proportional odds model,
		check the classification rates and see what they tell you about which one you'd choose**/
Title 'Proportional Odds';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool;
	ods select none;
	output out=Default predprobs=(I);
run;
ods select all;
proc freq data=default;
	table _from_*_into_;
run;

Title 'SBC says use: unequalslopes=(price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(price);
	ods select none;
	output out=SBC predprobs=(I);
run;
ods select all;
proc freq data=SBC;
	table _from_*_into_;
run;

Title 'AIC says use: unequalslopes=(sq_ft price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool / unequalslopes=(sq_ft price) link=alogit;
	ods select none;
	output out=AIC predprobs=(I);
run;
ods select all;
proc freq data=AIC;
	table _from_*_into_;
run;

Title 'Another Choice: GLOGIT';
proc logistic data=mydata.realestate;
	model quality = sq_ft price pool /  link=glogit;
	ods select none;
	output out=Another predprobs=(I);
run;
ods select all;
proc freq data=Another;
	table _from_*_into_;
run;

proc sgpanel data=mydata.realestate;
	panelby pool;
	scatter x=sq_ft y=price / group=quality;
run;

/**Remove Pool First...**/
Title 'Proportional Odds';
proc logistic data=mydata.realestate;
	model quality = sq_ft price;
	ods select fitstatistics;
run;

Title 'unequalslopes=(sq_ft)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price / unequalslopes=(sq_ft);
	ods select fitstatistics;
run;

Title 'unequalslopes=(price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price / unequalslopes=(price);
	ods select fitstatistics;
run;

Title 'unequalslopes=(sq_ft price)';
proc logistic data=mydata.realestate;
	model quality = sq_ft price  / unequalslopes=(sq_ft price);
	ods select fitstatistics;
run;

proc logistic data=mydata.realestate;
	model quality = sq_ft price pool /  link=glogit;
	ods select none;
	output out=AnotherB predprobs=(I);
run;
ods select all;
Title 'Another Choice: GLOGIT';
proc freq data=Another;
	table _from_*_into_;
run;
Title 'Another Choice: GLOGIT (remove pool)';
proc freq data=AnotherB;
	table _from_*_into_;
run;