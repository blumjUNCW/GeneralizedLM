libname mydata '~/GenLM';

/*1a*/
ods graphics off;
proc glm data=mydata.cdi;
	class region;
 	model inc_per_cap = ba_bs region;
	lsmeans region / diff adjust=tukey cl lines;
run;

/*1b*/
ods graphics off;
proc glm data=mydata.cdi;
	class region;
 	model inc_per_cap = ba_bs|region / solution;
	lsmeans region / diff adjust=tukey at ba_bs=15 lines;
	lsmeans region / diff adjust=tukey at ba_bs=20 lines;
	lsmeans region / diff adjust=tukey at ba_bs=25 lines;
/**pull these from a quartile summary on BA/BS**/
	ods select lsmlines;
run; 


proc means data=mydata.cdi min q1 median mean q3 max;
	class region;
	var ba_bs;
run;