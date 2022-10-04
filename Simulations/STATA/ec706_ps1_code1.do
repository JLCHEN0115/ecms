# delimit ;
capture log close;
log using "~/Documents/StudyNotes/Econometrics-notes/simu-MC-methods/STATA/log_ps1.log", replace;
clear all;

*model
U0, U1, UV N(mu,Sigma)
;

**********************************************;
*Step 0: set model parameters;
**********************************************;

local sigma_u0 = 1; *Standard deviations;
local sigma_u1 = 1;
local sigma_uv = 1;
local corr_u01 = 0.4; *correlations;
local corr_u0v = 0.4;
local corr_u1v = -0.5;
local alpha = 1;
local beta1 = 2;
local muV = 1;


**********************************************;
*Step 1: generate u0, u1, uv random variables;
**********************************************;

set seed 115;
matrix C = (1, `corr_u01', `corr_u0v' \ `corr_u01', 1, `corr_u1v' \ `corr_u0v', `corr_u1v', 1);
matrix sd = (`sigma_u0',`sigma_u1',`sigma_uv');
drawnorm U0 U1 UV, n(10000) corr(C) sds(sd);

*check descriptive stats--does this match our parameters?;
sum U0 U1 UV;
correlate U0 U1 UV;


**********************************************;
*Step 2: generate V, Y0, Y1, Delta variables;
**********************************************;

gen V = `muV' + UV;
gen Y0 = `beta1' + U0;
gen Y1 = `beta1' + `alpha' + U1;
gen Delta = Y1 - Y0;

sum Y0 Y1;

*distribution of treatment effects;

sum Delta, detail;
kdensity Delta;

**********************************************;
*Step 3: treatment assignment;
**********************************************;

*Model 1: Treatment non-randomly assigned;
gen D = 1 if V >= 0;
replace D = 0 if V < 0;
gen Y = D*Y1 + (1-D)*Y0; *observed Y;

* Compute ATE, ATET and ATEU using simulation draws;
sum Delta;   
bysort D: sum Delta;

*ols;
regress Y D;
eststo nanrandom;

*Model 2: Treatment randomly assigned;
set seed 115;
gen coin = runiform();
gen D_rand = 1 if coin > 0.5;
replace D_rand = 0 if coin <= 0.5;
gen Y_rand = D_rand*Y1 + (1-D_rand)*Y0; *observed Y; 

*ols;
regress Y_rand D_rand;
eststo random;

* esttab nonrandom random using ps-1-q1.tex;

log close








