# ESS data cleaning and harmonisation in R

**Author: Jesca Birungi**

A cleaning-only edition of my supplied ESS R Markdown workflow for the files labelled 2014 and 2023. It demonstrates importing, checking, combining and recoding survey data. No datasets, rendered reports, statistical models or multiple imputation are included.

## Workflow

1. Import two local CSV files and check required fields and numeric parsing.
2. Check respondent keys when `idno` is available and retain supplied design fields.
3. Restrict to countries observed in both files.
4. Record raw household-income missingness reasons before recoding.
5. Check raw response-code domains and convert specified special codes to `NA`.
6. Harmonise smoking indicators and create socioeconomic and demographic groups.
7. Apply the original age and country restrictions and record sample counts.
8. Summarise missingness and save cleaned data locally.

The missingness tables and plots are descriptive, unweighted data-quality checks. They do not establish MCAR or MAR. No prevalence estimation, significance testing, regression or imputation is performed.

## Files and requirements

- `ess_data_cleaning.Rmd`: documented cleaning workflow.
- `README.md`: these instructions.
- `.gitignore`: excludes local data and generated files from normal Git tracking.

Use R with `tidyverse`, `knitr` and `rmarkdown`, plus Pandoc for HTML rendering. RStudio can provide the rendering environment. Package versions have not been pinned; `sessionInfo()` records the versions used when the workflow runs.

Download the appropriate ESS Round 7 and Round 11 files from the [ESS data portal](https://www.europeansocialsurvey.org/data-portal), following its access and citation requirements. Record the exact dataset editions, download dates and data citations for your inputs. These were not supplied with this script, and no data files are redistributed here.

Prepare local numeric-code CSV exports named `data/ess2014.csv` and `data/ess2023.csv`. The filenames and `survey_year` values are study labels, not proof of the interview year. If present, `essround` must identify 7 and 11 respectively.

| Fields | Requirement |
| --- | --- |
| Both files | `cntry`, `eisced`, `eduyrs`, `hinctnta`, `hincfel`, `mnactic`, `isco08`, `agea`, `gndr`, `maritalb` |
| 2014 file | `cgtsmke`, `cgtsday` |
| 2023 file | `cgtsmok` |
| Optional identity/design fields | `idno`, `essround`, `anweight`, `dweight`, `pspwght`, `pweight`, `psu`, `stratum` |

Source fields must contain numeric codes, rather than response-label strings. `cntry` and identifiers are read as text. The pipeline stops if required columns, numeric parsing or expected code ranges fail. If `idno` is absent, it warns that respondent-key duplicates cannot be checked; `source_row` is only a local row identifier. Absent round-specific smoking fields and `anweight` are filled with missing values, without constructing weights.

## Run locally

1. Keep this folder named `ess-data-cleaning` and create its local `data` folder.
2. Place the two CSV exports in `data`.
3. Open `ess_data_cleaning.Rmd` in RStudio. Install dependencies once if needed:

```r
install.packages(c("tidyverse", "knitr", "rmarkdown"))
```

4. Click **Knit**. Alternatively, from this folder run:

```r
rmarkdown::render("ess_data_cleaning.Rmd")
```

5. Review warnings, unexpected-code failures, sample counts and missingness tables. Local exports are `outputs/ess_clean.rds`, `outputs/ess_clean.csv`, `outputs/sample_flow.csv` and `outputs/missingness.csv`. Re-running replaces those files.

## Decisions to review

- **Original study restrictions:** age 25+ and exclusion of EE/IL are retained in configuration. The supplied file did not justify the country exclusions. They are not general ESS rules. The age bands remain defined for ages 25+.
- **Custom groupings:** the education, income, employment and occupation groups reproduce study-specific choices, with the occupation changes below. They are not asserted to be official ESS harmonisation standards. Education code 55 is excluded from the grouped education measure; `eisced_original` retains its source code.
- **Missingness scope:** income-reason tables are produced before the age/country exclusions. The final missingness table describes the restricted sample. Unknown country labels fall back to their codes instead of collapsing into one missing-name group.
- **Weights/design:** available fields are retained, not validated or used. Do not use these unweighted checks as population estimates. Additional design fields not listed in the script need adding before a design-based analysis.
- **Source documentation:** check all recodes and skip patterns against the exact editions in use. In addition to the data portal, consult the [ESS Round 11 source questionnaire](https://www.europeansocialsurvey.org/sites/default/files/2024-01/ESS%20Round%2011%20Source%20Questionnaire_FINAL_Alert%2004.pdf) and the documentation for your Round 7 file.

## Changes from the supplied R Markdown

- Removed missingness association tests, logistic regression, multiple imputation and imputed-data exports.
- Replaced the personal drive path with relative `data` and `outputs` paths.
- Corrected the 2014 daily-10-plus indicator so daily smokers with missing cigarette counts remain missing on that indicator.
- Removed the heuristic that inferred occupation major groups by dividing arbitrary two/three-digit codes. Only recognised armed-forces codes and four-digit-range codes are grouped; other formats remain unclassified and require review. Armed forces are now a separate category, rather than being labelled manual work. This range-based step does not validate every ISCO code.
- Added required-column, code-domain and identifier checks, sample-flow counts, and preservation of available design fields.

Prepared from Jesca's uploaded cleaning workflow with AI-assisted editing. No external authorship of that original workflow is inferred. Cite ESS and any additional code sources that apply to your work.

## Validation status

The source and output were statically reviewed. **This edition has not been run or knitted in R**, and no actual dataset was supplied for validation. No sample sizes or empirical results are claimed. Code-domain assumptions, field availability and edition-specific harmonisation need review when running the real inputs.

## Add to the portfolio

Upload this whole `ess-data-cleaning` folder to the root of `biostatistics-analysis-portfolio`, alongside the current SEM files. Keep `README.md` inside this folder so it does not replace the repository's existing README. Include only these source files, with no datasets or generated HTML. Ignore rules do not protect files selected for manual browser upload.
