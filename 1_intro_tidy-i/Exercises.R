
# This file contains the exercises for the "Introduction to the tidyverse" course
# feel free to write your code inline to solve the problems as we move through the course

# first install all these packages
# install.packages("tidyverse")
# install.packages("pixarfilms")
# install.packages("skimr")
# install.packages("readxl")
# install.packages("writexl")
# install.packages("lubridate")

library(tidyverse)

### Explore, read, write, create data ##########################################

# Explore data -----------------------------------------------------------------
library(pixarfilms)

# Look at the `pixar_films` dataset using `print()`, glimpse()`, `skim()` and `View()`
# What is the advantage of each of those ?

# Save data --------------------------------------------------------------------

# * Save pixar_films to a csv file
# * Save the whole set of 5 tables to an xlsx file
# * Open these files and look at the result
# * Where are the data types ?

# Open a file from R -----------------------------------------------------------

file.edit("file.csv")
browseURL("file.xlsx")

# Read data --------------------------------------------------------------------

# * Read back csv and xlsx datasets we saved
# * `pixar_films_from_csv`
# * `pixar_films_from_xlsx`
# * Look at the output displayed by `readr::read_csv()`
# * Look at the data types
# * Did we reproduce the original ?

pixar_films_from_csv <- ...
pixar_films_from_xlsx <- ...

spec(pixar_films_from_csv)

# Compare data -----------------------------------------------------------------

waldo::compare(
  pixar_films,
  pixar_films_from_csv
)

waldo::compare(
  pixar_films,
  pixar_films_from_xlsx
)

# Advanced read_excel ----------------------------------------------------------

# What are the following arguments for and what could be a situation to use them?
#
# * `col_names`
# * `range`
# * `skip`
# * `na`

?read_excel

# Create data ------------------------------------------------------------------

# recreate the following data using `tibble()`, then using `tribble()`

# # A tibble: 2 × 5
#   number film         release_date run_time film_rating
#   <chr>  <chr>        <date>          <dbl> <chr>
# 1 1      Toy Story    1995-11-22         81 G
# 2 2      A Bug's Life 1998-11-25         95 G

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
# 3.  Return the row of the shortest movie using `slice_min()`
# 4.  Return the rows of the 15%  longest movie using `slice_max()` and the `prop` argument

# `arrange()` ------------------------------------------------------------------

pixar_films

# 1.  Arrange `pixar_films` by name but starting with missing values (Hint: use `is.na()`).
# 2.  Arrange `pixar_films` to find the shortest film with a "PG" rating
# 3.  Arrange `pixar_films` to find longest film with a "PG" rating
# 4.  Redo 2 and 3 and make sure to have the result on top (Hint: use `film_rating != "PG"`)

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




