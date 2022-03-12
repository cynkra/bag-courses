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

# Data model objects -----

pixar_dm <- dm_pixarfilms()
pixar_dm

pixar_dm %>%
  dm_draw()

pixar_dm$pixar_films
pixar_dm$academy

names(pixar_dm)

pixar_dm %>%
  dm_get_tables()

# Showcase: wrapping all tables in a data model:
pixar_films_wrapped <-
  pixar_dm %>%
  dm_wrap_tbl(pixar_films) %>%
  pull_tbl(pixar_films)

pixar_films_wrapped
pixar_films_wrapped$academy[[1]]

# FIXME: Exercises
