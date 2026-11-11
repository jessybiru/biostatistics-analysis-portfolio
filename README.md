# Structural equation modelling in Stata

A commented adaptation of a published SEM tutorial, prepared for Jesca Birungi Nalugya's biostatistics analysis portfolio. It provides code examples for students and prospective employers. It is a tutorial adaptation, not an original research study or evidence of independently developed methods.

## What the script covers

- Data inspection and missingness summaries.
- Confirmatory factor analysis and latent-factor scaling.
- A structural model of SES and mathematics performance.
- Model fit, Satorra-Bentler adjustment and modification indices.
- Mediation and a bootstrap confidence interval for an indirect path.
- School-type group analysis and invariance diagnostics.
- Latent growth modelling and a random-slope `gsem` example.
- Ordinal indicators in a generalised structural equation model.

## Contents and data requirements

`sem_analysis.do` is the only analysis file. No datasets, fitted results, saved diagrams or downloaded webpages are included.

| Local dataset | Required variables | Structure |
| --- | --- | --- |
| `data/math.dta` | `schtype`, `ratio`, `math`, `ses1`–`ses4` | One row per tutorial student; `schtype` coded 0/1; SES indicators ordered 0–4 in the source example |
| `data/crime.dta` | `lncrime0`–`lncrime3` | One row per unit, with four equally spaced repeated measurements in wide format |

Variable names alone are not enough to transfer the models to another study. Review coding, measurement assumptions, missingness, sampling design and model identification before adapting them.

## Obtain the tutorial data

Use the source linked in Cain's article: [Stata tutorial materials](https://www.stata.com/users/mcain/JBDS_SEM). The article gives `net from http://www.stata.com/users/mcain/JBDS_SEM` as the Stata entry point and directs readers to the `SEMtutorial` link. Follow the publisher's current download instructions and applicable terms. Place `math.dta` and `crime.dta` in a local `data` folder. This portfolio does not redistribute them.

## Run

1. Save any work open in Stata; the script starts with `clear all`.
2. Extract the project and put the two datasets in `sem-stata/data/`.
3. In licensed Stata 17 or later, change the working directory to `sem-stata` using **File > Change working directory** or `cd`.
4. Run `do sem_analysis.do`.
5. Review `outputs/sem_analysis.log`, especially sample sizes, convergence, warnings and failed bootstrap replications. Re-running replaces this log.

The full script requires both datasets. It runs 1,000 bootstrap replications with a fixed seed. No external Stata packages or SEM Builder files are required.

## Attribution and portfolio contribution

The uploaded `semtutorial.do` follows the commands in Meghan K. Cain's **Structural Equation Modeling using Stata**, *Journal of Behavioral Data Science*, 1(2), 159–180. [Article and worked output](https://jbds.isdsa.org/public/journals/1/html/v1n2/p7/); [DOI](https://doi.org/10.35566/jbds/v1n2/p7).

The model sequence, specifications and coefficient tests come from that tutorial. This portfolio edition adds organisation, explanatory comments, data and variable checks, relative paths, logging and a reproducible bootstrap seed, and removes GUI diagram dependencies. It also uses `clear` when switching datasets. The source tutorial's methods and datasets are not presented as Jesca's original research. This edition was prepared with AI assistance; Jesca should review and run it before presenting it as a completed portfolio example.

No blanket software licence is applied to this adaptation because the supplied materials did not establish their code redistribution licence. Cite the source and check its applicable terms before further redistribution or relicensing.

## Validation and interpretation

The script has been checked against the supplied variable names and published tutorial commands, but **has not been executed in Stata** in this preparation environment. No estimates or successful execution are claimed. Target version is Stata 17+; compatibility has not been runtime-verified.

Review each model on the intended data. Do not interpret a mediation path decomposition as a causal effect without additional justification. Do not add residual correlations solely to improve fit. The hard-coded group coefficient names assume the source's 0/1 school coding; consult `coeflegend` if adapting the model. The growth model's equal spacing and equal residual-variance constraint also need review in other studies.

## Reference

Cain, M. K. *Structural Equation Modeling using Stata*. Journal of Behavioral Data Science, 1(2), 159–180. https://doi.org/10.35566/jbds/v1n2/p7
