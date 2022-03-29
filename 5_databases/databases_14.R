# attach relevant packages
library(tidyverse)

# display chosen presentation (it might take a few seconds to appear)
slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
# slide_viewer("5_databases/databases.html")

### Caveats ####################################################################

# Connection -------------------------------------------------------------------

con_duckdb <- DBI::dbConnect(duckdb::duckdb())
dm::copy_dm_to(con_duckdb, dm::dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

con_sqlite <- DBI::dbConnect(RSQLite::SQLite(), extended_types = TRUE)
dm::copy_dm_to(con_sqlite, dm::dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

# Lazy tables ------------------------------------------------------------------

pixar_films <- tbl(con_duckdb, "pixar_films")
pixar_films_sqlite <- tbl(con_sqlite, "pixar_films")

# Caveat: lazy tables are not data frames --------------------------------------

# Bad:
pixar_films[c("film", "film_rating")]

# Good:
pixar_films %>%
  select(film, film_rating)

# Bad:
try(
  bind_rows(pixar_films, pixar_films)
)

# Good:
union_all(pixar_films, pixar_films)

union_all(pixar_films, pixar_films) %>%
  arrange(release_date)

# Bad:
try(
  pixar_films[1:3, ]
)

# Still bad:
df_pixar_films <-
  pixar_films %>%
  collect()
df_pixar_films[1:3, ]

# Caveat: order ----------------------------------------------------------------

# Set-oriented, no intrinsic order, no `slice()`!

# Bad:
try(
  pixar_films %>%
    slice(1:3)
)

# Better:
pixar_films %>%
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

# Not all functions supported:
try(
  pixar_films %>%
    filter(grepl("^Toy", film)) %>%
    print()
)

try(
  pixar_films %>%
    filter(str_detect(film, "^Toy")) %>%
    print()
)

# Unknown functions and operators are passed on verbatim:
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

# Aggregation functions don't support na.rm = FALSE:
pixar_films %>%
  summarize(sum(run_time)) %>%
  show_query()

pixar_films %>%
  summarize(SUM(run_time)) %>%
  show_query()

# SQL escaping:
pixar_films %>%
  mutate(number = CAST(number %AS% sql("integer")))

pixar_films %>%
  mutate(number = sql("CAST(number AS integer)"))

pixar_films %>%
  mutate(number = as.integer(number))

# Caveat: lazy tables recompute every time -------------------------------------

films_two_per_year <-
  pixar_films %>%
  add_count(year(release_date)) %>%
  filter(n > 1)

films_two_per_year %>%
  show_query()

films_two_per_year %>%
  arrange(release_date) %>%
  show_query()

# `compute()` materializes result, creates a temporary table on the database
films_two_per_year_mat <-
  films_two_per_year %>%
  compute(unique_indexes = list(c("film")))

films_two_per_year_mat
films_two_per_year_mat %>%
  arrange(release_date) %>%
  show_query()


# Exercises --------------------------------------------------------------------

pixar_films

# 1. Experiment.
