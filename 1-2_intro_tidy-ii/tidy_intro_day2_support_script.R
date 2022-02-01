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
slide_viewer("1-2_intro_tidy-ii/tidy_intro_day2_1_rename_subset_and_sort_with_dplyr.html")
slide_viewer("1-2_intro_tidy-ii/tidy_intro_day2_2_transform_pipe_and_aggregate_with_dplyr.html")

### Introduction to {dplyr} ####################################################

# `select()` -------------------------------------------------------------------

public_response

# *  Find several ways to select the 3 first columns
# *  What happens if you include the name of a variable multiple times in a `select()` call?
# *  Select all columns that contain underscores (use `contains()`)
# *  Use `all_of()` to select 2 columns of your choice
# *  Does the result of running the following code surprise you?
#    `select(public_response, contains("R")`
#    How do the select helpers deal with case by default? How can you change that default?

# `filter()` -------------------------------------------------------------------

pixar_films

# Find all films that
# 1. Are rated "PG"
# 2. Had a run time below 95
# 3. Had a rating of "N/A" or "Not Rated"
# 4. Were released after and including year 2020
# 5. Have a missing name (`film` column) or `run_time`
# 6. Were released after and including year 2020 with name not missing
# 7. Are a first sequel (the name ends with "2")
# 8. Were released between "2018-06-12" and  "2020-04-27" using `>=` and `<=`
# 9. The same, using `between()` and `lubridate::as_date()`

# `slice()` --------------------------------------------------------------------

pixar_films

# 1.  Return the 2 first rows using `slice()` then using `slice_head()`
# 2.  Return the 2 last rows using `slice()` then using `slice_tail()`
# 3.  Return the rows of the 2 shortest movies using `slice_min()`
# 4.  Return the rows of the 15%  longest movies using `slice_max()` and the `prop` argument

# `arrange()` ------------------------------------------------------------------

pixar_films

# 1.  Arrange `pixar_films` by name but starting with missing values (Hint: sort using `!is.na()` and break the ties with `film`)
# 2.  Arrange `pixar_films` to have the shortest film with a "PG" rating on top (Hint: use `film_rating != "PG"`)
# 3.  Arrange `pixar_films` by name but starting with missing values (Hint: sort using `!is.na()` and break the ties with `film`)

# `mutate()` -------------------------------------------------------------------

box_office

# 1.  Check that in `box_office`, `box_office_worldwide` is indeed the sum of the 2 other columns.
# 2.  Flag movies in `box_office` that did better in the US and Canada than in the rest of the world
# 3.  Use `if_else()` and `median()` to create a column `budget_type()` with values
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
