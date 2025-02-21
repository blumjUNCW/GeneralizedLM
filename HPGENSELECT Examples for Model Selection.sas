proc format;
	value publpriv
	1='Public'
	2,3='Private'
	;
run;


proc hpgenselect data=regmodel;
	format control publpriv.;
	class iclevel hloffer--cbsatype;
	model control = rate cohort grantRate--InStateF iclevel hloffer--cbsatype / dist=binomial;
		/**default distribution is normal (and identity link),
			to get any kind of logistic, you have to put in a dist=**/
run;
/**there is no default selection method for this procedure**/

proc hpgenselect data=regmodel;
	format control publpriv.;
	class iclevel hloffer--cbsatype;
	model control = rate cohort grantRate--InStateF iclevel hloffer--cbsatype / dist=binomial;
	selection;
	/**You do get a selection with an empty SELECTION statement--
			method is stepwise, criterion is significance level (slentry and stay 
			are 0.05)**/
run;

proc hpgenselect data=regmodel;
	format control publpriv.;
	class iclevel hloffer--cbsatype;
	model control = rate cohort grantRate--InStateF iclevel hloffer--cbsatype / dist=binomial;
	selection method=stepwise(choose=sbc);
	/****/
run;

proc hpgenselect data=regmodel;
	format control publpriv.;
	class iclevel hloffer--cbsatype;
	model control = rate cohort grantRate--InStateF iclevel hloffer--cbsatype / dist=binomial;
	selection method=stepwise(choose=sbc slentry=0.10 slstay=0.10 );
	/****/
run;


proc hpgenselect data=regmodel;
	format control publpriv.;
	class iclevel hloffer--cbsatype;
	model control = rate|cohort|grantRate|InStateF|iclevel|hloffer|cbsatype @2 / dist=binomial;
	selection method=stepwise(choose=sbc slentry=0.10 slstay=0.10 );
	/****/
run;

proc hpgenselect data=regmodel;
	format control publpriv.;
	class iclevel hloffer--cbsatype;
	model control = rate|cohort|grantRate|InStateF|iclevel|hloffer|cbsatype @2 / dist=binomial;
	selection method=stepwise(choose=sbc slentry=0.10 slstay=0.10) hierarchy=single;
	/****/
run;