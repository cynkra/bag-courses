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
#' ]
#'
#' .pull-right[
g(f(5)) #<<

## Not:
f(g(5))
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
