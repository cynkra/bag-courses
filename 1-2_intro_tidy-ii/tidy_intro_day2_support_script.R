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

### Introduction to {dplyr} ####################################################

# `select()` -------------------------------------------------------------------

public_response

# *  Find several ways to select the 3 first columns
# *  What happens if you include the name of a variable multiple times in a `select()` call?
# *  Select all columns that contain underscores (use `contains()`)
# *  Use `all_of()` to select 2 columns of your choice
# *  Does the result of running the following code surprise you?
#    `select(public_response, contains("R"))`
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
