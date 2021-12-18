********************************************************************************
** TITLE: Tell me, "Who is responsible?										  **							  **
** DATA: EconomicMacro_Dataset_15.dta 										  **
** AUTHOR of Data: Ruth Dassonneville 										  **	
** AUTHOR: Brandon Park 									 				  **
** DATE: May 2017	
** Modified: March 2018														  **
********************************************************************************
*cd "C:\Users\Brandon\Dropbox\Clarity of Responsibility and Turnout\Dassonneville and Lewsi Beck data"
*cd "/Users/ruthdassonneville/Documents/WEP_Economic Voting_Electoral Rules/WEP_R&R"


use "COR_QOG_Vdem", clear
xtset country_code election_number



*******************************************************************************
** DATA MANAGEMENT
** The current data is saved using this data management do file. 
*******************************************************************************


** 1. INSTITUTIONAL RULES 

* MAJORITARIAN
tab Rules_PMaMi, gen(esystem)

* UNITARY
replace federal_state=1 if country=="Spain"
generate unitary=1 if federal_state==0
replace unitary=0 if federal_state==1

* NO DUAL EXECUTIVE
generate nodual=1 if semi_presidential==0
replace nodual=0 if semi_presidential==1

* STABLE DEMOCRACY:
replace  years_democracy=year- Demo_since
generate years_democracyXGDP=years_democracy*TCB_GDP_1yearlag
summarize years_democracy , detail				// median = 38
generate stabledemo=1 if years_democracy>38
replace stabledemo=0 if years_democracy<=38
replace stabledemo=. if years_democracy==.

* VOLUNTARY: We decide not to include complusory in our clarity of responsibility.
* This is explained in the manuscript. 
*generate voluntary=1 if Compulsory_voting==0
*replace voluntary=0 if Compulsory_voting==1
*generate voluntaryXGDP=voluntary*TCB_GDP_1yearlag



** 1-1. INSTITUTIONAL RULES INDEX: Aggregate 
generate InstRules=esystem2+unitary+nodual+stabledemo
replace InstRules=. if esystem2==.
replace InstRules=. if unitary==.
replace InstRules=. if nodual==.
replace InstRules=. if stabledemo==.
sum InstRules
*replace InstRules=. if voluntary==.
gen InstRulesXGDP = InstRules*TCB_GDP_1yearlag



** 2. POWER PRules 
* SINGLE PARTY
generate singleparty=1 if Coalition==0
replace singleparty=0 if Coalition==1

* MAJORITY GOVERNMENT
generate majority=1 if Minority_government==0
replace majority=0 if Minority_government==1

* ENEP
generate smallenep=1/ENV

* LONGEVITY CABINET
generate longcabinet=Cabinet_years

* CLOSENESS ECONOMY
generate closedeconomy=1/ExportsImports_EY1




** 2-1. POWER PATTERNS INDEX- Aggregate
summarize ENV, detail								// median = 3.91
summarize ExportsImports_EY1, detail				// median = 65.23
summarize Cabinet_years, detail						// median = 2.53

generate limitedparties=1 if ENV<3.91
replace limitedparties=0 if ENV>=3.91
replace limitedparties=. if ENV==.

generate closedeconomy_01=1 if ExportsImports_EY1<65.23
replace closedeconomy_01=0 if ExportsImports_EY1>=65.23
replace closedeconomy_01=. if ExportsImports_EY1==.

generate stablecabinet=1 if Cabinet_years>2.53
replace stablecabinet=0 if Cabinet_years<=2.53
replace stablecabinet=. if Cabinet_years==.

generate PowerRules=singleparty+majority+limitedparties+closedeconomy_01+stablecabinet
replace PowerRules=. if singleparty==.
replace PowerRules=. if majority==.
replace PowerRules=. if limitedparties==.
replace PowerRules=. if closedeconomy_01==.
replace PowerRules=. if stablecabinet==.
gen PowerRulesXGDP = PowerRules*TCB_GDP_1yearlag



*3. Controls
* election competitiveness
gen opp_share = 100- cpds_govsup 
gen ele_comp = cpds_govsup - opp_share
gen ele_comp1 = abs(ele_comp) 

gen ele_comp2 = dpi_gpvs1 - dpi_vslop1
gen ele_comp3 = abs(ele_comp2)


gen lngdp = ln(mad_gdppc_l1)
gen lnpop = ln(gle_pop_l1)






**************************************************************************
** ANALYSIS: Replication for Table and Figures 
**************************************************************************

**************************************************************************
** Table 2: Effect of Clarity of Responsibility on Turnout (OLS) 
**************************************************************************
* Dynamic naive models (Model 1 and 2)
xtreg  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules  , robust
xtreg  turnout_idea L.turnout_idea InstRules PowerRules  , robust

* Dynamic full models (Model 3 and 4) 
xtreg  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
xtreg  turnout_idea L.turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust

* Static full models (Model 5 and 6) 
xtreg  turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust

* Static full models with Fixed Effects (Model 7 abd 8)
xtreg  turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust fe
xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust fe


** Creating TABLE2: Effect of COR on Turnout (Dynamic Models) 
eststo M1: quietly xtreg  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules  , robust
eststo M2: quietly xtreg  turnout_idea L.turnout_idea InstRules PowerRules , robust
eststo M3: quietly xtreg  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M4: quietly xtreg  turnout_idea L.turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
*eststo M5: quietly xtreg  turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
*eststo M6: quietly xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust


esttab M1 M2 M3 M4 M5 M6 using BasicCOR.tex, se r2 star(* 0.10 ** 0.05 *** 0.01) obslast label ///
title(Effect of Clarity of Responsibility on Turnout (OLS)  table\label{tab1})




** Creating TABLE3: Effect of COR on Turnout (Static Models)
eststo M1: quietly xtreg  turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M2: quietly xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust
eststo M3: quietly xtreg  turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust fe
eststo M4: quietly xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust fe


esttab M1 M2 M3 M4  using BasicCOR.tex, se r2 star(* 0.10 ** 0.05 *** 0.01) obslast label ///
title(Effect of Clarity of Responsibility on Turnout (OLS)  table\label{tab1})






*******************************************************************************
** Figure 1: Variation in Power Rules and Institutional Rules across Counrries
*******************************************************************************
sort ccode year
twoway scatter  PowerRules year || line  InstRules year, by(cname)



********************************************************************************
** Figur 2: Predicted Values of Voter Turnout
********************************************************************************

** Power Rules Based on Model 4: we use this one
set more off
reg  turnout_idea L.turnout_idea InstRules PowerRules  Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust
margins,  at(PowerRules = (0 (.1) 5)) vsquish post
marginsplot, recast(line) recastci(rarea)  addplot(hist PowerRules, discrete freq yaxis(2) below width(.5) legend(off))


** Institutional Rules Based on Model 4
set more off
reg  turnout_idea L.turnout_idea InstRules PowerRules  Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust
margins,  at(InstRules = (0 (.1) 5)) vsquish post
marginsplot, recast(line) recastci(rarea)  addplot(hist InstRules, discrete freq yaxis(2) below width(.5) legend(off))




********************************************************************************
** Figure 3: Changes in Expected Values of Turnout 
********************************************************************************
cap drop change_ev
cap drop n
cap drop upci
cap drop loci
cap drop b*
cap drop variablename 

estsimp reg turnout_idea L.turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , cluster(ccode)
setx mean
simqi, ev
gen upci =.
gen loci = .
gen change_ev =.
gen n=_n

simqi, fd(ev genev(pi)) changex(InstRules 0 5) level(90)
_pctile pi, p(5, 95)
replace loci = r(r1) if n ==1 
replace upci = r(r2) if n ==1
replace change_ev = pi if n ==1
drop pi

simqi, fd(ev genev(pi)) changex(PowerRules 0 5) level(90)
_pctile pi, p(5, 95)
replace loci = r(r1) if n ==2
replace upci = r(r2) if n ==2
replace change_ev = pi if n ==2
drop pi

simqi, fd(ev genev(pi)) changex(Compulsory_voting 0 1) level(90)
_pctile pi, p(5, 95)
replace loci = r(r1) if n ==3
replace upci = r(r2) if n ==3
replace change_ev = pi if n ==3
drop pi

simqi, fd(ev genev(pi)) changex(une_pee_l1 p25 p75) level(90)
_pctile pi, p(5, 95)
replace loci = r(r1) if n == 4
replace upci = r(r2) if n == 4
replace change_ev = pi if n == 4
drop pi

simqi, fd(ev genev(pi)) changex(ele_comp1 p25 p75) level(90)
_pctile pi, p(5, 95)
replace loci = r(r1) if n == 5
replace upci = r(r2) if n == 5
replace change_ev = pi if n == 5
drop pi


generate variablename = _n
*label define independent_variablesl 1 "Institutional Rules" 2 "Power Rules" 3 "Compulsory Voting"  4 "Education Spending" 5 "Competitiveness" 
label value variablename independent_variablesl  
twoway (rcap upci loci variablename if variablename < 6)(scatter change_ev variablename) if variablename < 6, ytitle(Change of Expected Value) ytitle(, size(midum)) yline(0, lpattern(dash)) ylabel(-5(1)7) xtitle(Independent variable) xlabel(, angle(45)  valuelabel) legend(off)







********************************************************************************
** Descriptive Statistics (Appendix Table) 
********************************************************************************
*** Tabl2 1: Summary Statistics
sutex name of the variables, lab nobs key(descstat) replace ///
 file(descstat.tex) title("Summary Statistics") minmax

xtreg  turnout_idea L.turnout_idea InstRules PowerRules , robust
estat sum 

xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust
estat sum 












********************************************************************************
** Table A.3: Disaggregate Level of Analysis (DV: VAP)
********************************************************************************
* Majoritarian 
eststo M1:  xtreg turnout_idea_vap esystem2 Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Unitary 
eststo M2:  xtreg turnout_idea_vap  unitary Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* No Dual Executive 
eststo M3: xtreg turnout_idea_vap  nodual Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Stable Democracy
eststo M4: xtreg turnout_idea_vap  years_democracy Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Single Party 
eststo M5: xtreg turnout_idea_vap  singleparty Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Majority Government
eststo M6: xtreg turnout_idea_vap  majority Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* ENEP
eststo M7: xtreg turnout_idea_vap  smallenep Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Longevity Cabinet 
eststo M8: xtreg turnout_idea_vap  longcabinet Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Closed Economy 
eststo M9: xtreg turnout_idea_vap closedeconomy Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust


esttab M1 M2 M3 M4 M5 M6 M7 M8 M9 using DisaggregateCORI.tex, se r2 star(* 0.10 ** 0.05 *** 0.01) obslast label ///
title(Effect of Clarity of Responsibility on Turnout (VAP) (Disaggregate)  table\label{tab2})



********************************************************************************
** Table A.4: Disaggregate Level of Analysis (DV: REG)
********************************************************************************
* Majoritarian 
eststo M1:  xtreg turnout_idea esystem2 Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Unitary 
eststo M2:  xtreg turnout_idea  unitary Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* No Dual Executive 
eststo M3: xtreg turnout_idea  nodual Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Stable Democracy
eststo M4: xtreg turnout_idea  years_democracy Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Single Party 
eststo M5: xtreg turnout_idea  singleparty Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Majority Government
eststo M6: xtreg turnout_idea  majority Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* ENEP
eststo M7: xtreg turnout_idea smallenep Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Longevity Cabinet 
eststo M8: xtreg turnout_idea  longcabinet Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust

* Closed Economy 
eststo M9: xtreg turnout_idea closedeconomy Compulsory_voting  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop, robust



esttab M1 M2 M3 M4 M5 M6 M7 M8 M9 using DisaggregateCORI.tex, se(3) r2 star(* 0.10 ** 0.05 *** 0.01) obslast label ///
title(Effect of Clarity of Responsibility on Turnout (Disaggregate)  table\label{tab2})






********************************************************************************
*** Roustness check 
********************************************************************************

** 1.  Electoral Competitiveness using the difference between the first two parties (Reviewer 1's Comment 8) 
** Creating Table for Robustness  Using new "Electoral Competition" variable (the vote share between the largest two parties) 
** Not included in the manuscript or appendix. The relevant information is in Note 6. 
eststo M1: quietly xtreg  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp3  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M2: quietly xtreg  turnout_idea L.turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp3  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M3: quietly xtreg  turnout_idea_vap InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp3  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M4: quietly xtreg  turnout_idea InstRules PowerRules Compulsory_voting  p_polity_l1  ele_comp3  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust


esttab M1 M2 M3 M4 using BasicCOR.tex, se r2 star(* 0.10 ** 0.05 *** 0.01) obslast label ///
title(Robustness Check: Effect of Clarity of Responsibility on Turnout using New Electoral Competitiveness variable  table\label{tab1})



** 2. Compulsory Voting (using the continuous variable: v2elcomvot)
* Value of 1: compulsory, but no penalties
* Value of 2: light penalties
* Value of 3: heavy penalties

eststo M1: quietly xtreg  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules v2elcomvot  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M2: quietly xtreg  turnout_idea L.turnout_idea InstRules PowerRules v2elcomvot p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M3: quietly xtreg  turnout_idea_vap InstRules PowerRules v2elcomvot  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop , robust
eststo M4: quietly xtreg  turnout_idea InstRules PowerRules v2elcomvot  p_polity_l1  ele_comp1  TCB_GDP_1yearlag lngdp une_pee_l1  lnpop  , robust


esttab M1 M2 M3 M4 using BasicCOR.tex, se r2 star(* 0.10 ** 0.05 *** 0.01) obslast label ///
title(Effect of Clarity of Responsibility on Turnout (OLS)  table\label{tab1})







********************************************************************************
** Additional Robustness : Political Efficacy and COR: Response to Reviewer'1 comment
********************************************************************************
use "Efficacy Dataset 2014.dta", replace

*qpp9_2: The national parliamentary takes the concerns of citizens into consideration. (Government efficacy uuniga et al. (2017: 585)
*qpp9_3: Sometimes politics and government seem so complicate that a person like you can't really understand what's going on (Internal Efficacy).


*Data management 
tab qpp9_1
sum qpp9_1-qpp9_3
recode qpp9_1-qpp9_3 (-9=.) 
recode qpp9_1-qpp9_3 (1=4) (2=3) (3=2) (4=1)
label define efficacy1 1"No, not at all"  2"No, not really" 3"Yes, somewhat" 4"Yes, totally" 
label value qpp9_1-qpp9_3 efficacy1 
tab qpp9_1, label


* Analysis
corr qpp9_2 PowerRules
corr qpp9_2 InstRules

egen qpp9_2_mean = mean(qpp9_2), by(PowerRules)
egen tag2 = tag(PowerRules) 
twoway line qpp9_2_mean PowerRules  if tag2, ylabel(1 (.3) 4) xlabel(1 (1) 4) 
ttest qpp9_2mean, by(tag2)

egen qpp9_4_mean = mean(qpp9_2), by(InstRules)
egen tag4 = tag(InstRules) 
twoway line qpp9_4_mean InstRules if tag4, ylabel(1 (.3) 4) xlabel(1 (1) 3) 
ttest qpp9_2mean, by(tag4)





use "Efficacy Dataset.dta", replace
* using 2013 dataset!
*q44: The national parliament takes into consdieration the concerns of citizens.

**Data Management 
sum q40-q45
recode q40-q45 (8=.)
recode q40-q45 (7=.)
recode q40-q45 (1=5) (2=4) (4=2) (5=1)
sum q40-q45


*Analysis 
corr q44 PowerRules
corr q45 InstRules 


egen q44_mean = mean(q44), by(PowerRules)
egen tag5 = tag(PowerRules) 
twoway line q44_mean PowerRules  if tag5, ylabel(1 (.3) 4) xlabel(1 (1) 4) 
ttest q44_mean, by(tag5)


egen q44_mean1 = mean(q44), by(InstRules)
egen tag7 = tag(InstRules) 
twoway line q44_mean1 InstRules  if tag7, ylabel(1 (.3) 4) xlabel(1 (1) 3)
ttest q44_mean, by(tag7)





*** Using Blais (2014)
use "Efficacy MEDW.dta", replace

*Q32A: Government cares about people think (national)
*Q32B: Government cares about people think (regional) 

*Q34ABCD: Election is importatn (national, regional, european, municipal)
*Q35_2: Politics is complicated 
*Q35_5: there is no point of voting


sum Q32A Q32B
tab Q32A Q32B
recode Q32A-Q32B (9=.) (99=.)

sum Q34A Q34B Q34C Q34D
tab Q34A Q34B, nola
tab Q34C Q34D
recode Q34A Q34B Q34C Q34D (99=.)

sum Q35_2 Q35_4
tab Q35_2 Q35_4, nola
recode Q35_2 Q35_4 (9=.) 


sum Q49 
tab Q49 
recode Q49 Q49_1 (99=.) 


corr PowerRules Q32A 
corr PowerRules Q32B
corr PowerRules Q35_2
corr PowerRules Q35_4
corr PowerRules Q49


corr PowerRules Q32A if ccode !=756
corr PowerRules Q32B if ccode !=756
corr PowerRules Q35_2 if ccode !=756
corr PowerRules Q35_4 if ccode !=756
corr PowerRules Q49 if ccode !=756









********************************************************************************
** DO NOT USE the Followings (Not part of the paper) 
********************************************************************************




** Robustness check using Panel corrected standard error model (PCSE) 
** Two types of DV (see Settrey and Schwindt-Bayer 2009, page 1325. We have to use two types of DV for a robustness) 

*1. DV: trunout_idea_vap: The total number of votes cast (valid or invalid) divided by the Voting Age Population figure, expressed as a percentage.
*inst: deterministic
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules TCB_GDP_1yearlag Compulsory_voting 
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules TCB_GDP_1yearlag Compulsory_voting, pairwise
*power: more dynamic 
xtpcse  turnout_idea_vap L.turnout_idea_vap PowerRules TCB_GDP_1yearlag Compulsory_voting 
xtpcse  turnout_idea_vap L.turnout_idea_vap PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise


*1-1. Applications of AR(1) and Contemprenaous correlation 
*inst
* use AR1 autocorrelation structure
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules TCB_GDP_1yearlag Compulsory_voting , co(ar1)
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules TCB_GDP_1yearlag Compulsory_voting 
*power
xtpcse  turnout_idea_vap L.turnout_idea_vap PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise
xtpcse  turnout_idea_vap L.turnout_idea_vap PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise co(ar1)

*1-2. Two types of COR into a same model: to avoid omitted variable bias *inst + powerI: only power is significant!
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , co(ar1)
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise
xtpcse  turnout_idea_vap L.turnout_idea_vap InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise co(ar1)


*1-3. Conditional effect (GDP)-> weak theoreical reasoning for this 
xtpcse turnout_idea_vap L.turnout_idea_vap  InstRules PowerRules TCB_GDP_1yearlag InstRulesXGDP  PowerRulesXGDP Compulsory_voting , pairwise
xtpcse turnout_idea_vap L.turnout_idea_vap  InstRules PowerRules TCB_GDP_1yearlag InstRulesXGDP  PowerRulesXGDP Compulsory_voting , pairwise co(ar1)





*2. DV: turnout_idea: The total number of votes cast (valid or invalid) divided by the number of names on the voters' register, expressed as a percentage.
*inst
xtpcse  turnout_idea L.turnout_idea InstRules TCB_GDP_1yearlag Compulsory_voting 
xtpcse  turnout_idea L.turnout_idea InstRules TCB_GDP_1yearlag Compulsory_voting , pairwise 
*power
xtpcse  turnout_idea L.turnout_idea PowerRules TCB_GDP_1yearlag Compulsory_voting 
xtpcse  turnout_idea L.turnout_idea PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise


*2-1. Applications of AR(1) and Contemprenaous correlation  
*inst
xtpcse  turnout_idea L.turnout_idea InstRules TCB_GDP_1yearlag Compulsory_voting , co(ar1)
xtpcse  turnout_idea L.turnout_idea InstRules TCB_GDP_1yearlag Compulsory_voting 
*power
xtpcse  turnout_idea L.turnout_idea PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise
xtpcse  turnout_idea L.turnout_idea PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise co(ar1)



*2-2. Two types of COR into a same model: to avoid omitted variable bias
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , co(ar1)
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , 


*inst + powerI: only power is significant!
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting , pairwise co(ar1)



*Using various controls:
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting une_pee_l1 p_polity_l1 mad_gdppc_l1 ele_comp2, pairwise co(ar1)
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting  p_polity_l1 mad_gdppc_l1 ele_comp2, pairwise co(ar1)
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting une_pee_l1  mad_gdppc_l1 ele_comp2, pairwise co(ar1)
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting une_pee_l1 p_polity_l1  ele_comp2, pairwise co(ar1)
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag Compulsory_voting une_pee_l1 p_polity_l1 mad_gdppc_l1 , pairwise co(ar1)














*2-3. Conditional Effect (GDP)
*inst + powerI: only power is significant!
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag InstRulesXGDP  PowerRulesXGDP Compulsory_voting , pairwise
xtpcse  turnout_idea L.turnout_idea InstRules PowerRules TCB_GDP_1yearlag InstRulesXGDP  PowerRulesXGDP Compulsory_voting , pairwise co(ar1)






