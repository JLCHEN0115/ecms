# delimit ;
capture log close;
log using "ChenJialiangPS1.log", replace;

clear all;
use Economics-705-Fall-2022-NJS-Data;

*****************************************;
* exploratory analysis;
*****************************************;

label list; * list the underlying values of labeled variables;

*****************************************;
* Problems;
*****************************************;

preserve; * restore data after termination;

* Problem1;
keep if sex == 0 & age >= 22; * Keep only adult women;
sum age sex; * safety check;

* Problem2;
gen treat = 1 if ra_stat == 1;
replace treat = 0 if ra_stat == 2;
corr treat ra_stat; * safety check;

* Problem3;
* Requires: ssc inst missings;
missings report esum18i; * Report number of N/As;
keep if !missing(esum18i); * Drop missing observations with N/As;

* Probelm4;
* Show summary statistics by groups;
bysort treat: sum age bfeduca bfyrearn;

* Problem5;
* Balance tests for age, education and last year earning;
foreach var in age bfeduca bfyrearn{;
	ttest `var' , by(treat);
};

* Problem6;
* Compute sample mean and variance by groups and save for later use;
tabstat bfeduca, by(treat) stat(mean variance) save;
return list;
* Compute the Standardized difference;
display 100 * (abs(r(Stat1)[1,1] - r(Stat2)[1,1])) / sqrt((r(Stat1)[2,1] + r(Stat2)[2,1])/2);

* Problem7;
ttest esum18i , by(treat);

* Problem8;
* Regression without conditional variables;
reg esum18i treat;

* Problem9;
* Regression with conditional variables;
reg esum18i treat i.sex i.race age totch18 bfeduca bfyrearn i.site_num child_miss ed_miss earn_miss;

* Problem10;
* Display marginal distribution;
tabulate treat enroll ,row;

* Problem11;
* Two Stage Least Square Regression with endo-variables enroll and iv treat;
ivregress 2sls esum18i i.sex i.race age totch18 bfeduca bfyrearn i.site_num child_miss ed_miss earn_miss (enroll = treat);

* Problem12;
* Compute conditional expectations;
bysort treat enroll: sum bfeduca;
sum bfeduca;
* Compute complier characteristics mean;
di (11.40838 -  (49/5725)*11.28571 - (1324/5725)*11.39653)/(1 - (49/5725) - (1324/5725)); * a bit hardcode;

* Problem13;
* Create a binary indicator for "age less than or equal to 31";
gen agele31 = 1 if age <= 31;
replace agele31 = 0 if age > 31;

* Problem14;
* Experimental impact for younger individuals, estimaing separately;
reg esum18i treat i.sex i.race age totch18 bfeduca bfyrearn i.site_num child_miss ed_miss earn_miss if agele31 == 1;
* Experimental impact for older individuals, estimaing separately;
reg esum18i treat i.sex i.race age totch18 bfeduca bfyrearn i.site_num child_miss ed_miss earn_miss if agele31 == 0;
* Experimental impacts for two groups, estimaing collectively by interaction;
reg esum18i treat#agele31 agele31 i.sex i.race age totch18 bfeduca bfyrearn i.site_num child_miss ed_miss earn_miss;

* Problem15;
* Compare the standard deviation of earnings;
tabstat esum18i, by(treat) stat(sd);
sdtest esum18i, by(treat); * test the null of equal variances;

* Problem16;
* Estimate 75th quantile effect;
bysort treat: centile esum18i, centile(75);
di 13197 -  12227.5; * more hardcode;

* Problem17;
* generate binary employ = 1 if esum18i > 0;
gen employ = 1 if esum18i > 0;
replace employ = 0 if esum18i <= 0;

* Problem18;
* Display marginal distribution;
tabulate treat employ,row col;

log close



