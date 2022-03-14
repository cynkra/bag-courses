# attach relevant packages
library(tidyverse)

### Joins ######################################################################

# Connection -------------------------------------------------------------------

con_duckdb <- DBI::dbConnect(duckdb::duckdb())
dm::copy_dm_to(con_duckdb, dm::dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

con_sqlite <- DBI::dbConnect(RSQLite::SQLite(), extended_types = TRUE)
dm::copy_dm_to(con_sqlite, dm::dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

# Lazy tables ------------------------------------------------------------------

pixar_films <- tbl(con_duckdb, "pixar_films")
academy <- tbl(con_duckdb, "academy")

pixar_films_sqlite <- tbl(con_sqlite, "pixar_films")
academy_sqlite <- tbl(con_sqlite, "academy")


# Exercises --------------------------------------------------------------------

pixar_films %>%
  left_join(academy, by = "film")

# 1. How many rows does the join between `academy` and `pixar_films` contain?
#    Try to find out without loading all the data into memory. Explain.

left_join(pixar_films, academy, by = "film") %>%
  count()

count(academy)

# 2. Which films are not yet listed in the `academy` table? What does the
#    resulting SQL query look like?
#    - Hint: Use `anti_join()`

anti_join(pixar_films, academy, by = "film")

# 3. Transform `academy` into a wide table so that there is at most one row
#    per film. Join the resulting table with the `pixar_films` table.
#    - Hint: Use `pivot_wider()`, `spread()`, `dcast()`, ... . You need to
#      compute locally, because these functions don't work on the database.

duckdb::duckdb_register(
  con_duckdb,
  "academy_wide",
  pivot_wider(collect(academy), names_from = award_type, values_from = status)
)

academy_wide <- tbl(con_duckdb, "academy_wide")
left_join(pixar_films, academy_wide, by = "film")

# 4. Plot a bar chart with the number of awards won and nominated per year.
#    Compute as much as possible on the database.
#    - Hint: "Long form" or "wide form"?

academy_won_nominated <-
  academy %>%
  filter(status %in% c("Nominated", "Won")) %>%
  select(film, status)

per_year_won_nominated <-
  pixar_films %>%
  transmute(film, year = year(release_date)) %>%
  inner_join(academy_won_nominated, by = "film") %>%
  count(year, status) %>%
  collect()
per_year_won_nominated

ggplot(per_year_won_nominated, aes(x = year, y = n, fill = status)) +
  geom_col()
