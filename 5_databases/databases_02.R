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

# Complex aggregation with transformation
pixar_films %>%
  count(year(release_date))

pixar_films %>%
  add_count(year(release_date)) %>%
  filter(n > 1) %>%
  arrange(release_date)

# Computations happens on the database (and you don't want to write that SQL!)
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

# `slice()` --------------------------------------------------------------------

pixar_films

# 1.  Return the 2 first rows using `slice()` then using `slice_head()`
# 2.  Return the 2 last rows using `slice()` then using `slice_tail()`
# 3.  Return the rows of the 2 shortest movies using `slice_min()`
# 4.  Return the rows of the 15%  longest movies using `slice_max()` and the `prop` argument

# `arrange()` ------------------------------------------------------------------

pixar_films

# 1.  Arrange `pixar_films` by name but starting with missing values (Hint: sort using `!is.na()` and break the ties with `film`)
# 2.  Arrange `pixar_films` to have the shortest film with a "PG" rating on top (Hint: use `film_rating != "PG"`)
