# attach relevant packages
library(tidyverse)

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
dm::copy_dm_to(con_duckdb, dm::dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

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

df_films_two_per_year <-
  pixar_films %>%
  add_count(year(release_date)) %>%
  filter(n > 1) %>%
  arrange(release_date) %>%
  collect()
df_films_two_per_year


# Exercises --------------------------------------------------------------------

pixar_films

# 1. Add new columns `release_year` and `release_month`.

tmp <- mutate(pixar_films,
  release_year = year(release_date),
  release_month = month(release_date)
)

# 2. Use the new columns to compute the number of months since January 1970
#    for each film

transmute(tmp, offset = (release_year - 1970) * 12 + release_month)

# 3. Compute the overall median run time, and the median run time per film rating

mutate(pixar_films, overall_median = median(run_time)) %>%
  group_by(film_rating) %>%
  summarize(group_median = median(run_time)) %>%
  ungroup()

# FIXME: Parser Error; switch to mean?

# 4. For each film except the last, compute how many days have passed until the next film.
#     - Hint: Use `lag(..., order_by = ...)`

mutate(pixar_films,
  time_diff = release_date - lag(release_date, order_by = release_date)
)

# FIXME: except the first? or suggest lead() instead?

# 4. Find the maximum number of days between releases of two G and two PG films.

filter(pixar_films, film_rating %in% c("G", "PG")) %>%
  group_by(film_rating) %>%
  mutate(
    time_diff = release_date - lag(release_date, order_by = release_date)
  ) %>%
  summarize(max_diff = max(time_diff, na.rm = TRUE)) %>%
  ungroup()

