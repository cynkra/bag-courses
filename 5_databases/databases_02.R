# install.packages(c("tidyverse", "dm", "DiagrammeR", "RSQLite", "duckdb", "progress", "pixarfilms", "nycflights13"), type = "binary")
# pak::pak(c("tidyverse", "dm", "DiagrammeR", "RSQLite", "duckdb", "progress", "pixarfilms", "nycflights13"))

# attach relevant packages
library(tidyverse)
library(dm)

# display chosen presentation (it might take a few seconds to appear)
slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
# slide_viewer("5_databases/databases.html")

### Computing on the database ##################################################

# Connection -------------------------------------------------------------------

con_duckdb <- DBI::dbConnect(duckdb::duckdb())

# Lazy tables ------------------------------------------------------------------

pixar_films <- tbl(con_duckdb, "pixar_films")

# Computing on the database ----------------------------------------------------

# Transformation
pixar_films %>%
  mutate(release_year = year(release_date))

# Computations happens on the database!
pixar_films %>%
  mutate(release_year = year(release_date)) %>%
  show_query()

# Immutable data: original data unchanged
pixar_films %>%
  collect()

# Summaries
pixar_films %>%
  group_by(film_rating) %>%
  summarize(mean_run_time = mean(run_time)) %>%
  ungroup()

# Aggregation with transformation
pixar_films %>%
  mutate(release_year = year(release_date)) %>%
  count(release_year)

pixar_films %>%
  count(release_year = year(release_date))

# Complex aggregation with transformation
pixar_films %>%
  add_count(release_year = year(release_date)) %>%
  filter(n > 1) %>%
  arrange(release_date)

# Computation happens on the database (and you don't want to write that SQL!)
pixar_films %>%
  add_count(year(release_date)) %>%
  filter(n > 1) %>%
  arrange(release_date) %>%
  show_query()

films_two_per_year <-
  pixar_films %>%
  add_count(year(release_date)) %>%
  filter(n > 1) %>%
  arrange(release_date) %>%
  collect()
films_two_per_year

# Caveat: order ----------------------------------------------------------------

# Set-oriented, no intrinsic order, no `slice()`!

# Bad:
try(
  pixar_films %>%
    slice(1:3)
)

# Better:
pixar_films_sqlite %>%
  filter(between(row_number(), 1, 3))

# Best, use `order_by` argument or `dbplyr::window_order()`
pixar_films %>%
  filter(between(row_number(release_date), 1, 3))

pixar_films %>%
  dbplyr::window_order(release_date) %>%
  filter(between(row_number(), 1, 3))

# Same for window functions:
try(
  pixar_films %>%
    group_by(film_rating) %>%
    mutate(total_run_time = cumsum(run_time)) %>%
    ungroup()
)

pixar_films %>%
  group_by(film_rating) %>%
  dbplyr::window_order(release_date) %>%
  mutate(total_run_time = cumsum(run_time)) %>%
  ungroup()

# Use `arrange()` to fix order, but only at the end of a query!

# Bad:
pixar_films %>%
  arrange(film) %>%
  mutate(run_time_hr = run_time / 60) %>%
  filter(run_time_hr < 2)

# Good:
pixar_films %>%
  mutate(run_time_hr = run_time / 60) %>%
  filter(run_time_hr < 2) %>%
  arrange(film)

# NA sort first on databases!

pixar_films %>%
  arrange(run_time)

pixar_films %>%
  arrange(is.na(run_time), run_time)

# Caveat: logical data type ----------------------------------------------------

# Some databases have a logical data type...
pixar_films %>%
  count(film_rating == "PG")

con_sqlite <- DBI::dbConnect(RSQLite::SQLite(), extended_types = TRUE)
copy_dm_to(con_sqlite, dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)
pixar_films_sqlite <- tbl(con_sqlite, "pixar_films")

# Some don't (but coerce logical expressions to integers)...
pixar_films_sqlite %>%
  count(film_rating == "PG")

# In SQL Server you have to work around:
pixar_films %>%
  count(if_else(film_rating == "PG", 1L, 0L))

# Caveat: translations are not perfect -----------------------------------------

# Integers versus numerics:
pixar_films %>%
  filter(run_time < 120) %>%
  show_query()

pixar_films %>%
  filter(run_time < 120L) %>%
  show_query()

# Aggregation functions:
pixar_films %>%
  summarize(sum(run_time)) %>%
  show_query()

# Not all functions supported:
try(
  pixar_films %>%
    filter(grepl("^Toy", film))
)

try(
  pixar_films %>%
    filter(str_detect(film, "^Toy"))
)

# Unknown functions are escaped:
pixar_films %>%
  filter(film %LIKE% "Toy%")

try(
  pixar_films %>%
    collect() %>%
    filter(film %LIKE% "Toy%")
)

pixar_films %>%
  summarize(MAX(run_time))

try(
  pixar_films %>%
    collect() %>%
    summarize(MAX(run_time))
)

# SQL escaping:
pixar_films %>%
  mutate(number = CAST(number %AS% sql("integer")))

pixar_films %>%
  mutate(number = sql("CAST(number AS integer)"))

pixar_films %>%
  mutate(number = as.integer(number))

# Exercises --------------------------------------------------------------------

pixar_films

# 1. Add new columns `release_year` and `release_month`.
# 2. Use the new columns to compute the number of months since January 1970
#    for each film
# 3. Compute the overall median run time, and the median run time per film rating
# 4. For each film except the last, compute how many days have passed until the next film.
#     - Hint: Use `lag(..., order_by = ...)`
# 4. Find the maximum number of days between releases of two G and two PG films.
# 5. Experiment.
