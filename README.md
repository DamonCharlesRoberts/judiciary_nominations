<h4 align="center">Judiciary Hearing Interruptions.</h4>
<p align="center">
    <a href="https://github.com/DamonCharlesRoberts/judiciary_hearing_interruptions/commits/master">
    <img src="https://img.shields.io/github/last-commit/DamonCharlesRoberts/judiciary_hearing_interruptions.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub last commit"></a>
    <a href="https://github.com/DamonCharlesRoberts/seniority-project/issues">
    <img src="https://img.shields.io/github/issues-raw/DamonCharlesRoberts/judiciary_hearing_interruptions.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub issues"></a>
    <a href="https://github.com/DamonCharlesRoberts/seniority-project/pulls">
    <img src="https://img.shields.io/github/issues-pr-raw/DamonCharlesRoberts/judiciary_hearing_interruptions.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub pull requests"></a>
</p>

--- 
Analysis of interruptions of nominees for federal judiciary positions.

## Co-authored academic project with Tyler Garrett

# Code

* `code/pre_processing_fxns.R`: Takes raw .pdf transcripts and uses a function, that when executed, makes a row per speaker with a column for that speaker's name and a column of what they said.

* `code/pre_processing_script.R`: Executes transcriptsRead function sourced from `code/pre_processing_fxns.R`. Converts .pdf files (using the transcriptsRead() function) to .csv files. Then merges csv files from individual nominee to one .csv per nominee Race and Gender combination (for example a csv with all hearings from all non-white females). 

* `code/counts.R`: Demographic data and further transcript cleaning (i.e. creating variable for count of em-dashes)

* `code/primary_analysis_script.R`: File with the primary analyses, figures, and tables included in  the paper. 