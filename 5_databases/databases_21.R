# attach relevant packages
library(tidyverse)

# display chosen presentation (it might take a few seconds to appear)
slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
# slide_viewer("5_databases/databases.html")

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

academy
academy %>%
  count(status)

# Left join ------

academy %>%
  left_join(pixar_films)

academy %>%
  left_join(pixar_films, by = "film")

academy %>%
  left_join(pixar_films, by = "film") %>%
  show_query()

# Join with prior computation ------

academy_won <-
  academy %>%
  filter(status == "Won") %>%
  count(film, name = "n_won")

pixar_films %>%
  left_join(academy_won, by = "film")

pixar_films %>%
  left_join(academy_won, by = "film") %>%
  arrange(release_date)

pixar_films %>%
  left_join(academy_won, by = "film") %>%
  mutate(n_won = coalesce(n_won, 0L)) %>%
  arrange(release_date)

pixar_films %>%
  left_join(academy_won, by = "film") %>%
  mutate(n_won = coalesce(n_won, 0L)) %>%
  arrange(release_date) %>%
  show_query()

# Caveat: tables must be on the same source ------------------------------------

try(
  academy %>%
    left_join(pixar_films_sqlite, by = "film")
)

academy %>%
  left_join(pixar_films_sqlite, by = "film", copy = TRUE)

academy %>%
  left_join(pixar_films_sqlite, by = "film", copy = TRUE) %>%
  show_query()

try(
  pixarfilms::academy %>%
    left_join(pixar_films, by = "film")
)

pixarfilms::academy %>%
  left_join(pixar_films, by = "film", copy = TRUE)

# ETL, revisited ---------------------------------------------------------------

db_path <- fs::path_abs("pixar.duckdb")
con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path))
DBI::dbWriteTable(con, "academy", pixarfilms::academy, overwrite = TRUE)
DBI::dbExecute(con, "CREATE UNIQUE INDEX academy_pk ON academy (film, award_type)")
DBI::dbExecute(con, "CREATE INDEX academy_fk ON academy (film)")
DBI::dbDisconnect(con)


# Exercises --------------------------------------------------------------------

pixar_films %>%
  left_join(academy, by = "film")

# 1. How many rows does the join between `academy` and `pixar_films` contain?
#    Try to find out without loading all the data into memory. Explain.
# 2. Which films are not yet listed in the `academy` table? What does the
#    resulting SQL query look like?
#    - Hint: Use `anti_join()`
# 3. Transform `academy` into a wide table so that there is at most one row
#    per film. Join the resulting table with the `pixar_films` table.
#    - Hint: Use `pivot_wider()`, `spread()`, `dcast()`, ... . You need to
#      compute locally, because these functions don't work on the database.
# 4. Plot a bar chart with the number of awards won and nominated per year.
#    Compute as much as possible on the database.
#    - Hint: "Long form" or "wide form"?
