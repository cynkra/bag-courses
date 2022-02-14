install.packages("pixarfilms")
install.packages("skimr")
install.packages("readxl")
install.packages("writexl")
install.packages("lubridate")
install.packages("waldo")

# attach relevant packages
library(tidyverse)
library(pixarfilms)
library(skimr)
library(readxl)
library(writexl)
library(lubridate)

# display chosen presentation (it might take a few seconds to appear)
slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
slide_viewer("1-3_intro_tidy-iii_ggplot-i/tidy_intro_day3_1_transform_pipe_and_aggregate_with_dplyr.html")

# `mutate()` -------------------------------------------------------------------

box_office

# 1.  Check that in `box_office`, `box_office_worldwide` is indeed the sum of the 2 other columns.
# 2.  Flag movies in `box_office` that did better in the US and Canada than in the rest of the world
# 3.  Use `if_else()` and `median()` to create a column `budget_type` with values
#     `"low budget"` and `"high budget"`
# 4.  Use `lag()` to create a column `days_since_previous_movie` in `pixar_films`
#     (The films are already sorted)

# the pipe ---------------------------------------------------------------------

x <- "magritte"
public_response

# 1. Replace "e" by "r" in the string "magritte" using first `str_replace()` then `sub()`,
# without and with the pipe. What do you notice ?
# 2. With a single piped call, remove `cinema_score` from `public_response` and
# `filter` to keep only movies that did 90 or better on all other review websites

# summarize + group_by() -------------------------------------------------------

academy

# 1. Count the nominations for every movie (Hint:you'll need `filter()`)
# 2. A nomination is 1 point, winning an award is 2 points, compute every movie's
# score and show the top 3 (Hint: create a `points` column using `mutate()` and `case_when()`)
