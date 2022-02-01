
# This file contains the exercises for the "Introduction to the tidyverse" course
# feel free to write your code inline to solve the problems as we move through the course

### Setup ######################################################################

# first install all these packages
install.packages("tidyverse")
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
slide_viewer("1_intro_tidy-i/tidy_intro_day1_0_Introduction.html")
slide_viewer("1_intro_tidy-i/tidy_intro_day1_1_Explore_read_write_create.html")

### Explore, read, write, create data ##########################################

# Explore data -----------------------------------------------------------------

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

