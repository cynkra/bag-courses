
# This file contains the exercises for the "Introduction to the tidyverse" course
# feel free to write your code inline to solve the problems as we move through the course

### Setup ######################################################################

# first install all these packages
install.packages("tidyverse")
install.packages("repurrrsive")
install.packages("styler")

# attach relevant packages
library(tidyverse)
library(repurrrsive)

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
    summarise(avg = mean(var, na.rm = TRUE), .groups = "drop")
}
mean_by(starwars, gender, height)

# works with strings
mean_by <- function(data, by, var) {
  data %>%
    group_by(across(all_of(by))) %>%
    summarise(across(all_of(var), mean, na.rm = TRUE, .names = "avg"), .groups = "drop")
}
mean_by(starwars, "gender", "height")

# works with naked variables
mean_by <- function(data, by, var) {
data %>%
  group_by({{ by }}) %>%
  summarise(avg = mean({{ var }}), .groups = "drop")
}
mean_by(starwars, gender, height)

# using a custom name
mean_by <- function(data, by, var, prefix = "avg") {
  data %>%
    group_by({{ by }}) %>%
    summarise("{prefix}_{{ var }}" := mean({{ var }}, na.rm = TRUE), .groups = "drop")
}
mean_by(starwars, gender, height)


## Higher order functions ######################################################

# The `map()` family - vectorization -------------------------------------------

# fails
starwars %>%
  select(where(is.numeric)) %>%
  median(na.rm = TRUE)

summarize(starwars, across(where(is.numeric), median, na.rm = TRUE))

# fails
median(list(3, 2:4, 1:5))

map(list(3, 2:4, 1:5), median)

# The `map()` family - type stability ------------------------------------------

?map

sapply(list(3, 2:4, 1:5), median)
sapply(list(3, 2:4, 1:5), range)

map_dbl(list(3, 2:4, 1:5), median)

# The `map()` family - extract by index ----------------------------------------

x <- list(list(name = "John", surname = "Smith"), list(name = "Sarah", kid_ages = list(8, 10, 12)))
map_chr(x, "name")
map_chr(x, "surname", .default = "Unknown")
map_dbl(x, list("kid_ages", 1), .default = NA)

# The `map()` family - map_if(), map_at()  -------------------------------------

?map_if

map_if(list(3, 2:4, 1:5), ~length(.x) <= 3, median)
map_at(list(3, 2:4, 1:5), 3, median)

# The `map()` family - parallel iterations -------------------------------------

x <- list(1, 1:2, 1:3)
y <- c(10, 20, 30)
map2(x, y, ~ .x + .y)

x <- list(1, 1:2, 1:3)
y <- c(10, 20, 30)
z <- 1:3
pmap(list(x, y, z), function(x, y, z) z * (x + y))

x <- list(a = 1, b = 1:2, c = 1:3)
imap_chr(x, ~paste0(.y, .x, collapse = "-"))

# The `map()` family - walk() --------------------------------------------------

objects_to_write <- list(iris = iris, cars = cars)
iwalk(objects_to_write, ~ writeRDS(.x, paste0(.y, ".rds")))

# The `map()` family - practice ------------------------------------------------

sw_people_short <- sw_people[1:14]
names(sw_people_short[[1]])

View(sw_people_short)

character_names <- map_chr(sw_people_short, "name")
sw_people_named <- set_names(sw_people_short, character_names)

map_dbl(sw_people_named, ~ length(.x[["starships"]]))
map_chr(sw_people_named, "hair_color")
map_lgl(sw_people_named, ~ .x[["gender"]] == "male")

# `keep()` and `discard()` -----------------------------------------------------

?keep

x <- list(23, NA, 14, 7, NA, NA, 24, 98)
discard(x, is.na)

map_dbl(sw_people_named, ~ length(.x[["starships"]]))

sw_starship_people <- keep(sw_people_named, ~ length(.x[["starships"]]) > 1)
names(sw_starship_people)

# `reduce()` and `accumulate()` ------------------------------------------------

?reduce

accumulate(letters[1:4], paste, sep = ".")
reduce(letters[1:4], paste, sep = ".")

paste4 <- function(out, input, sep = ".") {
  # as soon as we have a more than 4 characters we're done
  if (nchar(out) > 4) {
    return(done(out))
  }
  paste(out, input, sep = sep)
}
accumulate(letters, paste4)
reduce(letters, paste4)

# function operators -----------------------------------------------------------

?safely
?insistently

safe_log <- safely(log10)
safe_log(100)
safe_log("a")

safe_log2 <- safely(log10, otherwise = NA)
safe_log2("a")

res <- map(list(100, 1000, "a"), safe_log2)
map_dbl(res, "result")

possible_log <- possibly(log10, NA)
possible_log(100)
possible_log("a")

quiet_log <- quietly(log10)
quiet_log(100)
quiet_log(-10)

slow_log <- slowly(log10)
system.time(map_dbl(c(10, 100), slow_log))

# function operators - insistently ---------------------------------------------

# no need to understand this function, just know that it fails 2 times then returns "success!
fake_connect <- local({
  i <- 0
  function(x) if ((i <<- i + 1) <= 2) stop("failing (", i, ")") else "success!"
})

# fail 2 times
fake_connect()
fake_connect()

# return "success!"
fake_connect()

# redefine
fake_connect <- local({
  i <- 0
  function(x) if ((i <<- i + 1) <= 2) stop("failing (", i, ")") else "success!"
})

insistent_connect <- insistently(fake_connect, rate_backoff(
  # wait twice more each time
  pause_base = 2,
  # wait maximum 30 sec
  pause_cap = 30,
  # max number of tries
  max_times = 10))
insistent_connect()


## Style and design ############################################################

# Type stability ---------------------------------------------------------------

typeof(median(1:3))
typeof(median(1:4))
median("foo")
median(c("foo", "bar"))
