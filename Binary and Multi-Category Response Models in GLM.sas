data cars;
	set sashelp.cars;
	select(type);
		when('Sedan','Wagon') car=1;
		when('Truck','SUV') car=0;
		otherwise delete;
	end;
run;/**Dummy encode car or not**/

proc standard data=cars out=carsSTD mean=0;
	var weight enginesize;
run;/**Center a couple of predictors...**/

ods graphics off;
proc glm data=carsSTD;
	model car = weight enginesize / solution;
		/**Model with the car/not variable as the response**/
	ods select ParameterEstimates;/**Get the parameter estimates for the two predictors**/
	output out=pred predicted=Pcar;/**Output the predicted values (y-hat)**/
run;

proc sgplot data=pred;
	scatter x=weight y=enginesize /
			markerattrs=(symbol=circlefilled) colorresponse=Pcar;
run;

%macro BinaryClass(split=0.5);
data class;
	set pred;
	length PredType $5;
	if Pcar gt &split then PredType='Car';
		else PredType='Truck';
run;
proc format;
	value $type
		'Sedan','Wagon'='Car'
		'Truck','SUV'='Truck'
	;
run;

proc freq data=class order=formatted;
	table type*PredType;
	format type $type.;
run;	

proc sgplot data=class;
	scatter x=weight y=enginesize /
		markerattrs=(symbol=circlefilled) group=PredType name='Scatter';
	lineparm x=0 y=%sysevalf((&split-0.7766)/0.099159)
						slope=%sysevalf(0.000402/0.099159);
	yaxis values=(-2 to 4 by 1);
	keylegend 'Scatter' / position=topleft location=inside title='' across=1;
run;
%mend;
%BinaryClass;
%BinaryClass(split=0.6);
%BinaryClass(split=0.4);


data cars;
	set sashelp.cars;
	Asia=0;Europe=0;USA=0;
	select(origin);
		when('Asia') Asia=1;
		when('Europe') Europe=1;
		when('USA') USA=1;
	end;
run;

ods graphics off;
ods select none;
proc glm data=cars;
	model Asia Europe USA = horsepower weight mpg_city msrp length;
	output out=predictions predicted=PAsia PEurope PUSA;
	where type ne 'Hybrid';
run;

data try;
	set predictions;
	total = PAsia+PEurope+PUSA;
	keep origin PAsia PEurope PUSA total;
run;

ods select all;
proc sgplot data=predictions;
	scatter y=origin x=PASIA / jitter legendlabel='PAsia'
			markerattrs=(symbol=circle color=blue);
	scatter y=origin x=PEurope / jitter legendlabel='PEurope'
			markerattrs=(symbol=square color=red);
	scatter y=origin x=PUSA / jitter legendlabel='PUSA'
			markerattrs=(symbol=triangle color=green);
	xaxis label='Predicted';
	keylegend / across=1 position=topright location=inside;
run;

data class;
	set predictions;
	max=max(PEurope,PAsia,PUSA);
	if PEurope = max then POrigin='Europe';
	if PAsia = max then POrigin='Asia';
	if PUSA = max then POrigin='USA';
run;

ods select all;
proc freq data=class;
	table origin*Porigin;
run;

ods graphics off;
ods select none;
proc glm data=cars;
	model Asia Europe = horsepower weight mpg_city msrp length;
	output out=predictionsB predicted=PAsia PEurope PUSA;
	where type ne 'Hybrid';
run;

data class;
	set predictionsB;
	PUSA = 1 - (PAsia + PEurope);
	max=max(PEurope,PAsia,PUSA);
	if PEurope = max then POrigin='Europe';
	if PAsia = max then POrigin='Asia';
	if PUSA = max then POrigin='USA';
run;