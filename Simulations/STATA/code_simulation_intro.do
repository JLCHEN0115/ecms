# delimit ;
clear all;


*************************************;
*draw some random numbers;
*************************************;

*10,000 uniform draws;
clear;
set obs 10000;
set seed 1056;
gen udraws = uniform();
sum udraws;

*compute autocorrelation;
gen udraws_lag = udraws[_n-1];
pwcorr udraws udraws_lag, sig;

*transform to standard normal draws;
gen ndraws = invnormal(udraws);
sum ndraws;

*or use built in commands in stata;
set seed 1056;
drawnorm ndraws2;
sum ndraws2;

*************************;
*regression model;
*************************;
clear;
set obs 1000;
set seed 1089;
gen epsilon = uniform();
set seed 13;
drawnorm temp;

*DGP 1 (epsilon and X correlated);
gen X = 2*epsilon + temp;
gen Y = 1 + 0.5*X + epsilon;
correlate epsilon X;
regress Y X;

*DGP 2 (epsilon and X uncorrelated);
drop X Y;
gen X = 0*epsilon + temp;
gen Y = 1 + 0.5*X + epsilon;
correlate epsilon X;
regress Y X;




************************************;
*noise graph;
************************************;

clear;
set obs 10000; *maximum size of simulation;

*loop over different size simulations/datasets;
forvalues R = 10(20)10000 {;
set seed `R'; *new seed for every dataset, where seed = R for convenience;
gen udraws = uniform() in 1/`R';
sum udraws;
gen mean`R' = r(mean);
drop udraws; *drop old draws;
};

*create graph;
keep mean*;
keep in 1; *only need first row given values repeat;
gen id = 1; *need id variable for i() of reshape;
reshape long mean@, i(id) j(R);
twoway scatter mean R;








