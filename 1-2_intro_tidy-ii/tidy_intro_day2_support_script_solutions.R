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
select(public_response, film, rotten_tomatoes, metacritic)
select(public_response, film:metacritic)
select(public_response, 1:3)
select(public_response, !ends_with("e"))
select(public_response, all_of(c("film", "rotten_tomatoes", "metacritic")))

# *  What happens if you include the name of a variable multiple times in a `select()` call?
# They are not repeated!
select(public_response, metacritic, metacritic)
select(public_response, metacritic, everything())

# *  Select all columns that contain underscores (use `contains()`)
select(public_response, contains("_"))

# *  Use `all_of()` to select 2 columns of your choice
select(public_response, all_of(c("rotten_tomatoes", "metacritic")))

# *  Does the result of running the following code surprise you?
#    `select(public_response, contains("R"))`
#    How do the select helpers deal with case by default? How can you change that default?

# contains is NOT case sensitive by default!
select(public_response, contains("R"))
select(public_response, contains("R", ignore.case = FALSE))

# `filter()` -------------------------------------------------------------------

pixar_films

# Find all films that
# 1. Are rated "PG"

filter(pixar_films, film_rating == "PG")

# 2. Had a run time below 95

filter(pixar_films, run_time < 95)

# 3. Had a rating of "N/A" or "Not Rated"

filter(pixar_films, film_rating %in% c("N/A", "Not Rated"))
filter(pixar_films, film_rating == "N/A" | film_rating == "Not Rated")

# 4. Were released after and including year 2020

filter(pixar_films, release_date >= "2020-01-01")
filter(pixar_films, year(release_date) >= 2020)

# 5. Have a missing name (`film` column) or `run_time`

filter(pixar_films, is.na(film) | is.na(run_time))

# 6. Were released after and including year 2020 with name not missing

filter(pixar_films, release_date >= "2020-01-01", !is.na(film))
filter(pixar_films, year(release_date) >= 2020, !is.na(film))

# 7. Are a first sequel (the name ends with "2")
filter(pixar_films, str_ends(film, "2"))

# 8. Were released between "2018-06-12" and  "2020-04-27" using `>=` and `<=`
filter(pixar_films, release_date >= "2018-06-12", release_date <= "2020-04-27")

# 9. The same, using `between()` and `lubridate::as_date()`
filter(pixar_films, between(release_date, as_date("2018-06-12"), as_date("2020-04-27")))

# `slice()` --------------------------------------------------------------------

pixar_films

# 1.  Return the 2 first rows using `slice()` then using `slice_head()`
slice(pixar_films, 1:2)
slice_head(pixar_films, n = 2)

# 2.  Return the 2 last rows using `slice()` then using `slice_tail()`
slice(pixar_films, (n() - 1):n())
slice_tail(pixar_films, n = 2)

# 3.  Return the rows of the 2 shortest movies using `slice_min()`
slice_min(pixar_films, order_by = run_time, n = 2)
slice_min(pixar_films, order_by = run_time, n = 2, with_ties = FALSE)

# 4.  Return the rows of the 15%  longest movies using `slice_max()` and the `prop` argument
slice_max(pixar_films, order_by = run_time, prop = .15)

# `arrange()` ------------------------------------------------------------------

pixar_films

# 1.  Arrange `pixar_films` by name but starting with missing values (Hint: sort using `!is.na()` and break the ties with `film`)
arrange(pixar_films, !is.na(film), film)

# 2.  Arrange `pixar_films` to have the shortest film with a "PG" rating on top (Hint: use `film_rating != "PG"`)
arrange(pixar_films, film_rating != "PG", run_time)
