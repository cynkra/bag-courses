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

# With zooming:
pixar_dm %>%
  dm_zoom_to(academy) %>%
  left_join(pixar_films, select = c(film, release_date))

# With flattening:
pixar_dm %>%
  dm_flatten_to_tbl(academy)

# Composing locally ----

pixar_films_clean <-
  pixarfilms::pixar_films %>%
  filter(!is.na(film)) %>%
  separate(film, into = c("franchise", "sequel"),
    sep = " (?=[0-9]+$)", fill = "right", remove = FALSE
  ) %>%
  mutate(across(c(number, sequel), as.integer)) %>%
  group_by(franchise) %>%
  mutate(sequel = if_else(is.na(sequel) & n() > 1, 1L, sequel)) %>%
  ungroup()

base_dm <- dm(
  pixar_films = pixar_films_clean,
  academy = pixarfilms::academy,
  box_office = pixarfilms::box_office,
)
base_dm

base_dm %>%
  dm_draw()

full_dm <-
  base_dm %>%
  dm_add_pk(pixar_films, film) %>%
  dm_add_pk(box_office, film) %>%
  dm_add_fk(academy, film, pixar_films) %>%
  dm_add_fk(box_office, film, pixar_films)

full_dm %>%
  dm_draw(view_type = "all")

# ETL, revisited ----

db_path <- fs::path_abs("pixar.duckdb")
fs::file_delete(db_path)
con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path))
pixar_dm_duckdb <- copy_dm_to(con, full_dm, temporary = FALSE)

pixar_dm_duckdb
pixar_dm_duckdb %>%
  dm_draw()

# Permanent tables, opt-in:
pixar_dm_duckdb %>%
  dm_get_tables()

# All dm operations work the same way for databases and for local sources:
pixar_dm_duckdb %>%
  dm_flatten_to_tbl(academy)

DBI::dbDisconnect(con)

# Learning from database ----

con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path))
pixar_dm_learned <- dm_from_src(con)

pixar_dm_learned %>%
  dm_draw()

pixar_dm_learned %>%
  dm_add_pk(pixar_films, film) %>%
  dm_add_fk(academy, film, pixar_films) %>%
  dm_draw()

dm_pixarfilms_small <- function() {
  db_path <- fs::path_abs("pixar.duckdb")
  con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path))
  table_names <- c("academy", "box_office", "pixar_films")
  dm_from_src(con, table_names = table_names, learn_keys = FALSE) %>%
    dm_add_pk(pixar_films, film) %>%
    dm_add_pk(box_office, film) %>%
    dm_add_fk(academy, film, pixar_films) %>%
    dm_add_fk(box_office, film, pixar_films)
}

dm_pixarfilms_small() %>%
  dm_draw()


# FIXME: Split, exercises
