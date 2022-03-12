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

### Data models ################################################################

# Data model objects

pixar_dm <- dm_pixarfilms()
pixar_dm

pixar_dm %>%
  dm_draw()

pixar_dm$pixar_films
pixar_dm$academy

names(pixar_dm)

pixar_dm %>%
  dm_get_tables()

# Primary keys ----

any(duplicated(pixar_dm$pixar_films$film))
any(duplicated(pixar_dm$genres[c("film", "genre")]))

# Foreign keys ----

all(pixar_dm$academy$film %in% pixar_dm$pixar_films$film)

# Constraints ----

pixar_dm %>%
  dm_examine_constraints()

dm_pixarfilms(consistent = TRUE) %>%
  dm_examine_constraints()

# Joins ----

# Bad:
pixar_dm$academy %>%
  left_join(pixar_dm$pixar_films %>% select(film, release_date))

# Good:
pixar_films_join <-
  pixar_dm$pixar_films %>%
  select(film, release_date)
pixar_dm$academy %>%
  left_join(pixar_films_join, by = "film")

# With dm and zooming:
pixar_dm %>%
  dm_zoom_to(academy) %>%
  left_join(pixar_films, select = c(film, release_date))

# With dm and flattening:
pixar_dm %>%
  dm_flatten_to_tbl(academy)

# Copy to database ----

con_sqlite <- DBI::dbConnect(RSQLite::SQLite(), extended_types = TRUE)
pixar_dm_sqlite <- copy_dm_to(con_sqlite, dm_pixarfilms(consistent = TRUE), temporary = FALSE)

pixar_dm_sqlite
pixar_dm_sqlite %>%
  dm_draw()

# Permanent tables, opt-in:
pixar_dm_sqlite %>%
  dm_get_tables()

# All dm operations work the same way for databases and for local sources:
pixar_dm_sqlite %>%
  dm_flatten_to_tbl(academy)

# Learning from database ----

pixar_dm_learned <- dm_from_src(con_sqlite)

pixar_dm_learned %>%
  dm_draw()

pixar_dm_learned %>%
  dm_add_pk(pixar_films, film) %>%
  dm_add_pk(public_response, film) %>%
  dm_add_pk(box_office, film) %>%
  dm_draw()

pixar_dm_learned %>%
  dm_add_pk(pixar_films, film) %>%
  dm_add_pk(public_response, film) %>%
  dm_add_pk(box_office, film) %>%
  dm_add_fk(academy, film, pixar_films) %>%
  dm_add_fk(box_office, film, pixar_films) %>%
  dm_add_fk(genres, film, pixar_films) %>%
  dm_add_fk(pixar_people, film, pixar_films) %>%
  dm_add_fk(public_response, film, pixar_films) %>%
  dm_draw()

dm_pixarfilms_small <- function() {
  table_names <- c("academy", "box_office", "pixar_films")
  dm_from_src(con_sqlite, table_names = table_names, learn_keys = FALSE) %>%
    dm_add_pk(pixar_films, film) %>%
    dm_add_pk(box_office, film) %>%
    dm_add_fk(academy, film, pixar_films) %>%
    dm_add_fk(box_office, film, pixar_films)
}

dm_pixarfilms_small() %>%
  dm_draw()
