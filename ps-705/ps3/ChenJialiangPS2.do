# delimit ;
capture log close;
log using "ChenJialiangPS2.log", replace;

clear all;
use Economics-705-Fall-2022-NJS-Data, clear;

*****************************************;
* exploratory analysis;
*****************************************;

label list; * list the underlying values of labeled variables;
sum;

*****************************************;
* Problems;
*****************************************;

* restore data after termination;
preserve; 

* Problem1;
* Keep only adult women;
keep if sex == 0 & age >= 22; 
sum age sex; * safety check;

* Problem2;
* Generate 1/0 treatment indicator;
gen treat = 1 if ra_stat == 1;
replace treat = 0 if ra_stat == 2;
tab ra_stat treat; * check;

* Problem3;
* Requires: ssc inst missings;
* Report number of N/As;
missings report esum18i; 
* Drop missing observations with N/As;
keep if !missing(esum18i); 
* Rescale earnings variables into thousands of dollars;
sum bfyrearn esum18i;
replace bfyrearn = bfyrearn/1000;
replace esum18i = esum18i/1000;
sum bfyrearn esum18i;

* Problem4;
* Looking for nonlinear/linear pattern;
scatter esum18i bfyrearn;
* Generate quadratic and cubic terms;
gen bfyrearn2 = bfyrearn^2;
gen bfyrearn3 = bfyrearn^3;

* linear regression;
reg esum18i bfyrearn;
* Quadratic regression;
reg esum18i bfyrearn bfyrearn2;
* Cubic regression;
reg esum18i bfyrearn bfyrearn2 bfyrearn3;

* Problem5;
* Generate the groups indicator;
gen bin = 0;
replace bin = 1 if bfyrearn > 0 & bfyrearn <= 1;
replace bin = 2 if bfyrearn > 1 & bfyrearn <= 3;
replace bin = 3 if bfyrearn > 3 & bfyrearn <= 5.6;
replace bin = 4 if bfyrearn > 5.6;
* Label the bin variable;
label variable bin "esum18i category";
label define bfyrearnbl 0 "= 0.0" 1 "(0.0,1.0]" 2 "(1.0,3.0]" 3 "(3.0,5.6]" 4 "> 5.6";
label values bin bfyrearnbl;

* Estimate conditional mean using the regressogram smoother;
tab bin, sum(esum18i);

* Problem8;
* Create the estimated step function;
gen esum18i_bin = 0;
replace esum18i_bin =  6.03 if bin == 0;
replace esum18i_bin =  7.52 if bin == 1;
replace esum18i_bin =  9.42 if bin == 2;
replace esum18i_bin =   10.78 if bin == 3;
replace esum18i_bin =  12.12 if bin == 4;
* Plot the scatter and step function;
twoway (scatter esum18i bfyrearn, msymbol(smplus)) (line esum18i_bin bfyrearn, sort);

* Problem 9;
* Current R-squared value;
reg esum18i esum18i_bin;
* Generate a new bin;
replace bin = 5 if bfyrearn > 10;
tab bin, sum(esum18i);
* Update our estimated step function;
replace esum18i_bin =  11.35 if bin == 4;
replace esum18i_bin =  15.20 if bin == 5;
* New R-squared value;
reg esum18i esum18i_bin;

* Problem13;
* The nonparametric regression;
npregress kernel esum18i bfyrearn, reps(100) seed(54321) estimator(constant);

* Problem15;
* Plot the estimated conditional mean function;
npgraph, msymbol(smplus);

* Problem16;
* The nonparametric regression with fixed bandwidth;
npregress kernel esum18i bfyrearn, reps(100) seed(54321) estimator(constant) bwidth(100 100, copy);

* Problem17;
npgraph, msymbol(smplus);

log close
