/*
STRUCTURAL EQUATION MODELLING IN STATA
Portfolio owner: Jesca Birungi Nalugya

Adapted tutorial, not an original empirical study.
Original tutorial: Meghan K. Cain, Structural Equation Modeling using Stata.
https://doi.org/10.35566/jbds/v1n2/p7
Source materials: https://www.stata.com/users/mcain/JBDS_SEM

This edition reorganises the supplied tutorial, adds explanatory comments,
data checks, relative paths, logging and a fixed bootstrap seed. Model
specifications follow Cain's tutorial. No new results are claimed here.

Requirements: licensed Stata 17 or later (target; not runtime-tested).
Run from this folder with math.dta and crime.dta in a local data/ folder.
Data and saved SEM Builder diagrams are deliberately not distributed.
The script clears data in memory; save current work before running.
*/

version 17.0
clear all
set more off
set seed 20261111

* 0. Project paths: set Stata's working directory to this script's folder.
local data_dir "data"
local output_dir "outputs"
local bootstrap_reps 1000

foreach dataset in math crime {
    capture confirm file "`data_dir'/`dataset'.dta"
    if _rc {
        display as error "Missing `data_dir'/`dataset'.dta. See README.md."
        exit 601
    }
}
capture mkdir "`output_dir'"
capture log close sem_portfolio
log using "`output_dir'/sem_analysis.log", text replace name(sem_portfolio)

* 1. Inspect the mathematics data before modelling.
use "`data_dir'/math.dta", clear
foreach variable in schtype ratio math ses1 ses2 ses3 ses4 {
    confirm numeric variable `variable'
}
codebook, compact
summarize math ratio ses1-ses4
misstable summarize schtype ratio math ses1-ses4
tabulate schtype, missing
assert inlist(schtype, 0, 1) if !missing(schtype)
* Default SEM estimation uses complete cases for variables in each model.
* Check the reported sample size; samples can differ when variables change.

* 2. Confirmatory factor analysis (CFA).
* SES is latent; ses1-ses4 are observed indicators. Stata fixes the first
* loading to one by default to identify the latent factor's scale.
sem (SES -> ses1-ses4)
estimates store cfa_marker
sem, standardized
estat gof, stats(all)

* Alternative scaling: fix the latent variance to one.
sem (SES -> ses1-ses4), var(SES@1)
estimates store cfa_unit_variance

* 3. Structural association between latent SES and mathematics score.
sem (SES -> ses1-ses4 math)
estimates store path_ml
sem, standardized
estat gof, stats(all)

* Satorra-Bentler adjustment, retaining the source model specification.
sem (SES -> ses1-ses4 math), vce(sbentler)
estimates store path_sb
estat gof, stats(all)

* 4. Model diagnostics and an illustrative residual covariance.
estimates restore path_ml
estat mindices
* The following covariance is a tutorial example, not an automatic response
* to modification indices. Any applied use needs substantive justification.
sem (SES -> ses1-ses4 math), cov(e.ses1*e.ses2)
estimates store path_residual_covariance
estat gof, stats(all)

* 5. Mediation: SES -> student-teacher ratio -> mathematics score.
* This is a statistical path decomposition; causal interpretation needs
* additional design and identification assumptions.
sem (SES -> ses1-ses4 ratio math) (ratio -> math)
estimates store mediation_ml
estat teffects
sem, coeflegend

* Fixed seed supports repeatability; inspect failed replications in output.
bootstrap indirect=(_b[ratio:SES]*_b[math:ratio]), ///
    reps(`bootstrap_reps') seed(20261111) nodots: ///
    sem (SES -> ses1-ses4 ratio math) (ratio -> math)
estat bootstrap, percentile

* 6. Group analysis by school type.
* Retain Stata's default group constraints from the source example.
* Consult help sem_group_options before changing equality constraints.
sem (SES -> ses1-ses4) (SES -> math ratio) (ratio -> math), ///
    group(schtype) byparm
estimates store group_model
estat teffects, nodirect nototal compact
sem, coeflegend byparm

* Coefficient references below require school groups coded 0 and 1.
quietly count if schtype == 0
local n0 = r(N)
quietly count if schtype == 1
local n1 = r(N)
if `n0' > 0 & `n1' > 0 {
    testnl _b[ratio:0bn.schtype#c.SES]*_b[math:0bn.schtype#c.ratio] = ///
        _b[ratio:1.schtype#c.SES]*_b[math:1.schtype#c.ratio]
}
estat ginvariant

* 7. Linear latent growth model: four measurement occasions.
use "`data_dir'/crime.dta", clear
foreach variable in lncrime0 lncrime1 lncrime2 lncrime3 {
    confirm numeric variable `variable'
}
describe
summarize lncrime0-lncrime3
misstable summarize lncrime0-lncrime3
* Loadings 0,1,2,3 encode equally spaced measurement occasions.
* The eps constraint specifies equal residual variances over time.
sem (Intercept@1 -> lncrime0-lncrime3) ///
    (Slope -> lncrime0@0 lncrime1@1 lncrime2@2 lncrime3@3), ///
    nocons means(Intercept Slope) var(e.lncrime0-lncrime3@eps)
estimates store growth_sem

* 8. Random-intercept/random-slope representation with gsem.
* Generate row IDs for this wide tutorial dataset only. For real data,
* use the actual persistent subject or unit identifier.
generate long id = _n
isid id
reshape long lncrime, i(id) j(time)
isid id time
summarize lncrime time
gsem (Intercept[id] time c.time#Slope[id] -> lncrime)
estimates store growth_gsem

* 9. Ordinal measurement model with a continuous mathematics outcome.
use "`data_dir'/math.dta", clear
* ses1-ses4 are treated as ordered categories here, unlike the linear CFA.
gsem (SES -> ses1-ses4, ologit) (SES i.schtype -> math)
estimates store ordinal_gsem
* Exponentiate only the ordinal response equations, not the math equation.
estat eform ses1 ses2 ses3 ses4

display as text "Analysis finished. Review convergence, warnings and sample sizes in the log."
log close sem_portfolio
