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
# 2. Use the new columns to compute the number of months since January 1970
#    for each film
# 3. Compute the overall median run time, and the median run time per film rating
# 4. For each film except the last, compute how many days have passed until the next film.
#     - Hint: Use `lag(..., order_by = ...)`
# 4. Find the maximum number of days between releases of two G and two PG films.
