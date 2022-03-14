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

### ETL with multiple tables ###################################################

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
pixar_films_clean

# Build base dm object
base_dm <- dm(
  pixar_films = pixar_films_clean,
  academy = pixarfilms::academy,
  box_office = pixarfilms::box_office,
)
base_dm

base_dm %>%
  dm_draw()

# Full dm object: base dm object with keys
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
pixar_dm_learned

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

dm_pixarfilms_small()

dm_pixarfilms_small() %>%
  dm_draw()

# Consuming ----

my_dm <- dm_pixarfilms_small()
box_office_vs_awards <-
  my_dm %>%
  dm_zoom_to(academy) %>%
  filter(status == "Won") %>%
  count(film, name = "n_awards_won") %>%
  dm_insert_zoomed("academy_won") %>%
  dm_zoom_to(pixar_films) %>%
  left_join(box_office, select = c(film, box_office_worldwide)) %>%
  left_join(academy_won) %>%
  transmute(
    rating = film_rating,
    box_office_mln = box_office_worldwide / 1e6,
    n_awards_won = coalesce(n_awards_won, 0)
  ) %>%
  pull_tbl() %>%
  collect()

ggplot(box_office_vs_awards, aes(x = box_office_mln, y = n_awards_won)) +
  geom_smooth() +
  geom_point() +
  facet_wrap(vars(rating))


# Exercises --------------------------------------------------------------------

dm_pixarfilms_small()

# 1. Experiment.
