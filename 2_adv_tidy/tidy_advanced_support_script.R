
# This file contains the exercises for the "Introduction to the tidyverse" course
# feel free to write your code inline to solve the problems as we move through the course

### Setup ######################################################################

# first install all these packages
install.packages("tidyverse")
# install.packages("pixarfilms")
# install.packages("skimr")
# install.packages("readxl")
# install.packages("writexl")
# install.packages("lubridate")

# attach relevant packages
library(tidyverse)
library(pixarfilms)
library(readxl)
library(writexl)
library(lubridate)

# display chosen presentation (it might take a few seconds to appear)
slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
slide_viewer("2_adv_tidy/tidy_advanced_1_Programming_with_dplyr.html")
slide_viewer("2_adv_tidy/tidy_advanced_2_Higher_order_functions.html")
slide_viewer("2_adv_tidy/tidy_advanced_3_Style_and_design.html")

### Programming_with_dplyr #####################################################

# {dplyr} refresher ------------------------------------------------------------

# using distinct variable names
sw_selected <- select(starwars, name, height, homeworld, species)
sw_filtered <- filter(sw_selected, homeworld %in% c("Alderaan", "Coruscant"))
sw_mutated <- mutate(sw_filtered, height_m = height / 100)
sw_grouped <- group_by(sw_mutated, species)
sw_summarized <- summarize(sw_grouped, avg_height_m = mean(height_m), .groups = "drop")
sw_summarized

# using a single temp variable
. <- starwars
. <- select(., name, height, homeworld, species)
. <- filter(., homeworld %in% c("Alderaan", "Coruscant"))
. <- mutate(., height_m = height / 100)
. <- group_by(., species)
. <- summarize(., avg_height_m = mean(height_m), .groups = "drop")
sw_summarized <- .
sw_summarized

# using the pipe with explicit dots
sw_summarized <-
  starwars %>%
  select(., name, height, homeworld, species) %>%
  filter(., homeworld %in% c("Alderaan", "Coruscant")) %>%
  mutate(., height_m = height / 100) %>%
  group_by(., species) %>%
  summarize(., avg_height_m = mean(height_m), .groups = "drop")
sw_summarized

# using the pipe with implicit dots
sw_summarized <-
  starwars %>%
  select(name, height, homeworld, species) %>%
  filter(homeworld %in% c("Alderaan", "Coruscant")) %>%
  mutate(height_m = height / 100) %>%
  group_by(species) %>%
  summarize(avg_height_m = mean(height_m), .groups = "drop")
sw_summarized


# tidy selection ---------------------------------------------------------------

select(starwars[1:2,], name:eye_color)
select(starwars[1:2,], !name:eye_color)
select(starwars[1:2,], -name)
select(starwars[1:2,], !name)
select(starwars[1:2,], -name, -height)
select(starwars[1:2,], !name, !height)
select(starwars[1:2,], c(name, eye_color))
select(starwars[1:2,], c(name:eye_color, gender:species))
select(starwars[1:2,], homeworld, everything())
select(starwars[1:2,], homeworld, last_col())
select(starwars[1:2,], homeworld, last_col(c(1, 3)))

select(starwars[1:2,], starts_with("s"))
select(starwars[1:2,], ends_with("color"))
select(starwars[1:2,], contains("_"))
select(starwars[1:2,], matches("^.a"))

# How could you recreate these outputs without using `matches()` ?
select(starwars[1:2,], matches("^s"))
select(starwars[1:2,], matches("color$"))

billboard_short <- billboard[1:2, 1:15]
select(billboard_short, artist, num_range("wk", 3:8))
select(starwars[1:2,], starts_with("s") | ends_with("color"))
select(starwars[1:2,], starts_with("s") & ends_with("color"))

cols <- c("name", "mass", "potatoe")
select(starwars[1:2,], all_of(cols))
select(starwars[1:2,], any_of(cols))

cols <- c("name", "mass")
select(starwars[1:2,], all_of(cols))

select(starwars[1:2,], where(is.numeric))
select(starwars, where(~n_distinct(.x) < 10))

# Putting it all together ------------------------------------------------------

starwars

# Review all our tidy selection helpers and find 3 ways to select the columns
# 4 to 7 of the `starwars` dataset

# `relocate()` -----------------------------------------------------------------

relocate(starwars[1:2, 1:8], name, .after = height)
relocate(starwars[1:2, 1:8], c(name, height), .after = ends_with("color"))

# `mutate()` with `.keep` ------------------------------------------------------

# keep all, the default
mutate(starwars[1:2,], bmi = mass / height^2, .keep = "all")

# keep only computed columns and their sources
mutate(starwars[1:2, 1:8], bmi = mass / height^2, .keep = "used")

# `mutate()` with `across()` ---------------------------------------------------

starwars[1:2, 1:5] %>%
  mutate(
    across(ends_with("color"), toupper),
    height_m = height / 100
  )

mutate(starwars[1:2, 1:5], across(ends_with("color"), list(up = toupper)))

mutate(starwars[1:2, 1:5], across(
  ends_with("color"), list(up = toupper), .names = "{.fn}{.fn}_{.col}"))

mutate(starwars[1:2, 1:5], across(where(is.numeric), ~ .x * 10))

# `mutate()` with `c_across()` -------------------------------------------------

# using `c()`
starwars[1:2, 1:5] %>%
  rowwise() %>%
  mutate(color_missing_rate =
           c(hair_color, skin_color) %>%
           is.na() %>%
           mean()) %>%
  ungroup()

# using `c_across()`
starwars[1:2, 1:5] %>%
  rowwise() %>%
  mutate(color_missing_rate =
           c_across(ends_with("color")) %>%
           is.na() %>%
           mean()) %>%
  ungroup()

# `group_by()` and `summarize()` with `across()` -------------------------------

starwars %>%
  group_by(sex) %>%
  summarize(across(where(is.numeric), lst(min, max) , na.rm = TRUE))

# fails
starwars %>%
  group_by(starts_with("se")) %>%
  summarize(across(where(is.numeric), lst(min, max) , na.rm = TRUE))

starwars %>%
  group_by(across(starts_with("se"))) %>%
  summarize(across(where(is.numeric), lst(min, max) , na.rm = TRUE))

# `count()` with `across()` ----------------------------------------------------

count(starwars, ends_with("color"))

# fails
count(starwars, across(ends_with("color")))

# Advanced filtering -----------------------------------------------------------

filter(starwars[1:8], if_any(ends_with("color"), ~ .x == "unknown"))
filter(starwars[1:8], if_all(ends_with("color"), ~ .x == "unknown"))

# * Find all rows of `starwars` that have `NA`s in either `height`, `mass`, or `birth_year`
# * Find all rows of `starwars` that have `NA`s in all `height`, `mass`, or `birth_year`
#
# Hint :
#   * This can be done using `if_any()` or `if_all()` or by testing columns separately
# for missingness and using `|` or `&`.
# * Which is more compact ?
#   * Which is more readable ?

# <data-masking> vs <tidy-select> ----------------------------------------------

# arguments are described as "<tidy-select>", meaning variables refer to column positions
# we can use tidy selection directly
?select
?relocate
?across
?if_any

# arguments are described as "<data-masking>", meaning variables refer to values
# we can use `across()`
?mutate
?summarize
?group_by
?count
?filter

# Tunneling --------------------------------------------------------------------

# fails
mean_by <- function(data, by, var) {
  data %>%
    group_by(by) %>%
    summarise(avg = mean(var, na.rm = TRUE))
}
mean_by(starwars, gender, height)

# works with strings
mean_by <- function(data, by, var) {
  data %>%
    group_by(across(all_of(by))) %>%
    summarise(across(all_of(var), mean, na.rm = TRUE, .names = "avg"))
}
mean_by(starwars, "gender", "height")

# works with naked variables
mean_by <- function(data, by, var) {
data %>%
  group_by({{ by }}) %>%
  summarise(avg = mean({{ var }}))
}
mean_by(starwars, gender, height)

# using a custom name
mean_by <- function(data, by, var, prefix = "avg") {
  data %>%
    group_by({{ by }}) %>%
    summarise("{prefix}_{{ var }}" := mean({{ var }}, na.rm = TRUE))
}
mean_by(starwars, gender, height)
