
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
slide_viewer("1-1_intro_tidy-i/tidy_intro_day1_0_Introduction.html")
slide_viewer("1-1_intro_tidy-i/tidy_intro_day1_1_Explore_read_write_create.html")

### Explore, read, write, create data ##########################################

# Explore data -----------------------------------------------------------------

# Look at the `pixar_films` dataset using `print()`, glimpse()`, `skim()` and `View()`
# What is the advantage of each of those ?
print(pixar_films)   # natural view in the console
glimpse(pixar_films) # useful if we have many columns or wide columns
skim(pixar_films)    # displays agregates to give an intuition of distributions, missingness...
View(pixar_films)    # isolate view from the console to dedicated tab where it's easy to scroll horizontally and vertically

# Save data --------------------------------------------------------------------

# * Save pixar_films to a csv file
write_csv(pixar_films, "pixar_films.csv")

# * Save the whole set of 6 tables to an xlsx file
datasets = list(
  academy = academy,
  box_office = box_office,
  genres = genres,
  pixar_films = pixar_films,
  pixar_people = pixar_people,
  public_response = public_response
)
write_xlsx(datasets, "pixar_films.xlsx")

# * Open these files and look at the result
file.edit("pixar_films.csv")
browseURL("pixar_films.xlsx")

# * Where are the data types ?
# We see that csvs are just text, data types are not saved there
# excel has a sense of data types, missing values are turned into blank empty cells

# Read data --------------------------------------------------------------------

# * Read back pixar_films from the csv and xlsx datasets we saved
pixar_films_from_csv <- read_csv("pixar_films.csv")
pixar_films_from_xlsx <- read_excel("pixar_films.xlsx", sheet = "pixar_films")

# * Look at the output displayed by `readr::read_csv()`
# it displays what data types were guessed from the csv (since original data types were lost)
# it also proposes us to use `spec()` to retrieve column specifications to retrieve the original

spec(pixar_films_from_csv)

# * Look at the data types
# * Did we reproduce the original ?

# The first column is "dbl" (double), it was initially "chr" (character)
# When reading the csv `read_csv()` saw only numbers in the columns and so decided
# to import them as numbers

# Compare data -----------------------------------------------------------------

# waldo::compare is great to compare datasets
# here we see that the `num` column is different
waldo::compare(
  pixar_films,
  pixar_films_from_csv
)

# here we see that the `release_date` column is stored differently
# Initially it was a "Date" column, but it has been reimported as a datetime column
# (class "POSIXct" "POSIXt")
waldo::compare(
  pixar_films,
  pixar_films_from_xlsx
)

# Advanced read_excel ----------------------------------------------------------

# What are the following arguments for and what could be a situation to use them?
#
# * `col_names` : whether to use first row for names, can also be used to give custom names,
# it is very important to use it if the names of your columns are not in the data, or the format will
# be all messed up
# * `range` : if your excel sheet contains several tables you can import them specifying the excel range
# * `skip` : if you have a few rows containing paraneters or notesat the top you can skip them before loading
# the data located below
# * `na` : if your excel file uses non standard values to mean NA, such as "missing", "unknown" etc,
# they can be interpreted as NA directly when reading the data

?read_excel

# Create data ------------------------------------------------------------------

# recreate the following data using `tibble()`, then using `tribble()`

# # A tibble: 2 × 5
#   number film         release_date run_time film_rating
#   <chr>  <chr>        <date>          <dbl> <chr>
# 1 1      Toy Story    1995-11-22         81 G
# 2 2      A Bug's Life 1998-11-25         95 G

tibble(
  number = c("1", "2"),
  film = c("Toy Story", "A Bug's Life"),
  release_date = as_date(c("1995-11-22", "1998-11-25")),
  run_time = c(81, 95),
  film_rating = c("G", "G")
)

tribble(
  ~number, ~film,         ~release_date,          ~run_time, ~film_rating,
  "1",      "Toy Story",    as_date("1995-11-22"),         81, "G",
  "2",      "A Bug's Life", as_date("1998-11-25"),         95, "G"
)
