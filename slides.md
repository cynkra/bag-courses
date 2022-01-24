#



This report was automatically generated with the R package **knitr**
(version 1.36).


```r
#' ---
#' title: "Tidyverse Intro I"
#' author: ["Antoine & Nicolas", "cynkra GmbH"]
#' date: "January 25, 2022"
#' output:
#'   cynkradown::cynkra_slides:
#'     nature:
#'       highlightStyle: github
#'       highlightLines: true
#'       countIncrementalSlides: false
#'     seal: true
#' fontsize: 10pt
#' lang: english
#' font: frutiger
#' wide: false
#' colorlinks: false
#' logo: true
#' header-includes:
#'   - \usepackage{parskip}
#' ---
#'
#+ setup, include = FALSE
#  This is a normal R comment.
library(tidyverse)
set.seed(2022)
#'
#' class: middle, inverse
#' # Transformation 1
#'
#' ---
#'
#' # Assignment
#'
#' `x <- y` pronounced as "`x` _becomes_ `y`"

x <- 3
x
```

```
## [1] 3
```

```r
x <- x + 1

#'
#' ---
#'
#' # The pipe
#'
#' `x %>% f() %>% g()` pronounced as "`x` _then_ `f` _then_ `g`"

f <- function(x) x + 1
g <- function(x) x * 2

#' .pull-left[
5 %>% f() %>% g()
```

```
## [1] 12
```

```r
#' ]
#'
#' .pull-right[
g(f(5)) #<<
```

```
## [1] 12
```

```r
## Not:
f(g(5))
```

```
## [1] 11
```

```r
#' ]
#'
#' ---
#'
#' # {dplyr}: Basic pattern
#'
#' ```r
#' data %>%
#'   verb(...) %>%
#'   verb(...) %>%
#'   ...
#' ```
#'
#' Each `verb` is a **pure function** (doesn't change its input)!
#'
#' Use assignment to persist the result:
#'
#' ```r
#' result <-
#'   data %>%
#'   verb(...) ...
#' ```
#'
#' ---
#'
#' # Verbs
#'
#' - `filter()`: Removes rows
#' - `select()`: Removes and renames columns
#' - `arrange()`: Reorders
#' - `mutate()`: Creates variables
#' - `summarize()`: Computes summaries
#'
#' ## Grouped operations
#'
#' - `group_by()`: Defines grouping for the next operation
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 4.1.1 (2021-08-10)
## Platform: aarch64-apple-darwin20 (64-bit)
## Running under: macOS Monterey 12.0.1
## 
## Matrix products: default
## LAPACK: /Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] pixarfilms_0.2.1 forcats_0.5.1    stringr_1.4.0    dplyr_1.0.7.9000 purrr_0.3.4     
##  [6] readr_2.1.0      tidyr_1.1.4      tibble_3.1.6     ggplot2_3.3.5    tidyverse_1.3.1 
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.7        cellranger_1.1.0  pillar_1.6.4      compiler_4.1.1   
##  [5] dbplyr_2.1.1      highr_0.9         tools_4.1.1       lubridate_1.8.0  
##  [9] jsonlite_1.7.2    evaluate_0.14     lifecycle_1.0.1   gtable_0.3.0     
## [13] pkgconfig_2.0.3   rlang_0.99.0.9003 reprex_2.0.1      rstudioapi_0.13  
## [17] cli_3.1.0         DBI_1.1.1         haven_2.4.3       xfun_0.28        
## [21] xml2_1.3.3        withr_2.4.3       httr_1.4.2        knitr_1.36       
## [25] fs_1.5.1          hms_1.1.1         generics_0.1.1    vctrs_0.3.8.9001 
## [29] grid_4.1.1        tidyselect_1.1.1  glue_1.6.0.9000   R6_2.5.1         
## [33] poof_0.0.0.9000   fansi_0.5.0       readxl_1.3.1      tzdb_0.2.0       
## [37] modelr_0.1.8      magrittr_2.0.1    backports_1.4.0   scales_1.1.1     
## [41] ellipsis_0.3.2    rvest_1.0.2       assertthat_0.2.1  colorspace_2.0-2 
## [45] tinytex_0.35      utf8_1.2.2        stringi_1.7.6     munsell_0.5.0    
## [49] broom_0.7.10      markdown_1.1      crayon_1.4.2
```

```r
Sys.time()
```

```
## [1] "2022-01-14 19:42:57 CET"
```

