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

### Reading tables from the database ###########################################

# Connection -------------------------------------------------------------------

con_duckdb <- DBI::dbConnect(duckdb::duckdb())
copy_dm_to(con_duckdb, dm_pixarfilms(), set_key_constraints = FALSE, temporary = FALSE)

# Read table -------------------------------------------------------------------

DBI::dbListTables(con_duckdb)
DBI::dbListFields(con_duckdb, "pixar_films")
df_pixar_films <- DBI::dbReadTable(con_duckdb, "pixar_films")
df_pixar_films
as_tibble(df_pixar_films)

# Execute queries --------------------------------------------------------------

DBI::dbGetQuery(con_duckdb, "SELECT * FROM pixar_films")
DBI::dbGetQuery(con_duckdb, "SELECT * FROM pixar_films WHERE release_date >= '2010-01-01'")
DBI::dbGetQuery(con_duckdb, r"(SELECT * FROM "pixar_films" WHERE "release_date" >= '2020-01-01')")

# Lazy tables ------------------------------------------------------------------

pixar_films <- tbl(con_duckdb, "pixar_films")
pixar_films
pixar_films %>%
  collect()

# View the first 1000 rows:
pixar_films %>%
  view()

# Downsizing on the database ---------------------------------------------------

# Projection (column selection)
pixar_films %>%
  select(1:3)

# Computations happens on the database!
pixar_films %>%
  select(1:3) %>%
  show_query()

# Bring the data into the R session
df_pixar_films_3 <-
  pixar_films %>%
  select(1:3) %>%
  collect()
df_pixar_films_3

# Immutable data: original data unchanged
pixar_films %>%
  collect()

# Subsetting
pixar_films %>%
  filter(release_date >= "2020-01-01")

# Computations happens on the database!
pixar_films %>%
  filter(release_date >= "2020-01-01") %>%
  show_query()

# Bring the data into the R session
df_pixar_films_202x <-
  pixar_films %>%
  filter(release_date >= "2020-01-01") %>%
  collect()
df_pixar_films_202x

# Immutable data: original data unchanged
pixar_films %>%
  collect()

# Aggregation
pixar_films %>%
  group_by(film_rating) %>%
  summarize(n = n()) %>%
  ungroup()

# Aggregation (shortcut)
pixar_films %>%
  count(film_rating)

# Computations happens on the database!
pixar_films %>%
  count(film_rating) %>%
  show_query()

# Bring the data into the R session
df_pixar_films_by_rating <-
  pixar_films %>%
  count(film_rating) %>%
  collect()
df_pixar_films_by_rating

# Immutable data: original data unchanged
pixar_films %>%
  collect()

# Downsizing on the database: Exercises ----------------------------------------

# `select()` -------------------------------------------------------------------

pixar_films

# *  Find several ways to select the 3 first columns
# *  What happens if you include the name of a variable multiple times in a `select()` call?
# *  Select all columns that contain underscores (use `contains()`)
# *  Use `all_of()` to select 2 columns of your choice

# `filter()` -------------------------------------------------------------------

pixar_films

# Find all films that
# 1. Are rated "PG"
# 2. Had a run time below 95
# 3. Had a rating of "N/A" or "Not Rated"
# 4. Were released after and including year 2020
# 5. Have a missing name (`film` column) or `run_time`
# 6. Were released after and including year 2020 with name not missing
# 7. Are a first sequel (the name ends with "2")
#     - Hint: Bring the data into the R session before filtering

# `count()`, `summarize()`, `group_by()`, `ungroup()` --------------------------

pixar_films

# 1. How many films are stored in the table?
# 2. How many films released after 2005 are stored in the table?
# 3. What is the total run time of all films?
#     - Hint: Use `summarize(sum(...))`, watch out for the warning
# 4. What is the total run time of all films, per rating?
#     - Hint: Use `group_by()`
