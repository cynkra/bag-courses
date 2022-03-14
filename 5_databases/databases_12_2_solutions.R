# attach relevant packages
library(tidyverse)

# Connection -------------------------------------------------------------------

con_duckdb <- DBI::dbConnect(duckdb::duckdb())
dm::copy_dm_to(con_duckdb, dm::dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

# Lazy tables ------------------------------------------------------------------

pixar_films <- tbl(con_duckdb, "pixar_films")


# Exercises --------------------------------------------------------------------

# 1. Add new columns `release_year` and `release_month`.

tmp <- mutate(pixar_films,
  release_year = year(release_date),
  release_month = month(release_date)
)
tmp

# 2. Use the new columns to compute the number of months since January 1970
#    for each film

transmute(tmp, offset = (release_year - 1970) * 12 + release_month)

# 3. Compute the overall median run time, and the median run time per film rating

pixar_films %>%
  summarize(overall_median = median(run_time))

pixar_films %>%
  group_by(film_rating) %>%
  summarize(group_median = median(run_time)) %>%
  ungroup()

# 4. For each film except the last, compute how many days have passed until the next film.
#     - Hint: Use `lead(..., order_by = ...)`

mutate(pixar_films,
  time_diff = lead(release_date, order_by = release_date) - release_date
)

# 4. Find the maximum number of days between releases of two G and two PG films.

filter(pixar_films, film_rating %in% c("G", "PG")) %>%
  group_by(film_rating) %>%
  mutate(
    time_diff = release_date - lag(release_date, order_by = release_date)
  ) %>%
  summarize(max_diff = max(time_diff, na.rm = TRUE)) %>%
  ungroup()

