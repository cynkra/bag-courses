# attach relevant packages
library(tidyverse)
library(DBI)

# display chosen presentation (it might take a few seconds to appear)
slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
# slide_viewer("5_databases/databases.html")

### Extract, Transform, Load ###################################################

# Extract: Raw data ------------------------------------------------------------

pixar_films_raw <- pixarfilms::pixar_films
pixar_films_raw

# Transform: Fix column type, extract sequel column ----------------------------

pixar_films_clean <-
  pixar_films_raw %>%
  separate(film, into = c("franchise", "sequel"),
    sep = " (?=[0-9]+$)", fill = "right", remove = FALSE
  ) %>%
  mutate(across(c(number, sequel), as.integer)) %>%
  group_by(franchise) %>%
  mutate(sequel = if_else(is.na(sequel) & n() > 1, 1L, sequel)) %>%
  ungroup()
pixar_films_clean

# Create target database -------------------------------------------------------

db_path <- fs::path_abs("pixar.duckdb")
db_path
fs::file_delete(db_path)
con <- dbConnect(duckdb::duckdb(dbdir = db_path))
con

# Load: Write table to the database --------------------------------------------

dbWriteTable(con, "pixar_films", pixar_films_clean)
dbExecute(con, "CREATE UNIQUE INDEX pixarfilms_pk ON pixar_films (film)")
dbDisconnect(con)

# Consume: share the file, open it ---------------------------------------------

fs::dir_info() %>%
  arrange(desc(birth_time)) %>%
  head(1)

con <- dbConnect(duckdb::duckdb(dbdir = db_path, read_only = TRUE))
my_pixar_films <- tbl(con, "pixar_films")
my_pixar_films

# Exercises --------------------------------------------------------------------

pixar_films_raw

# 1. Adapt the ETL workflow to convert the `run_time` column to a duration.
#    - Hint: Use `mutate()` with `hms::hms(minutes = ...)` .
# 2. Re-run the workflow.
