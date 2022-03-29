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

### Keys, constraints, normalization ###########################################

# Data model object ------

pixar_dm <- dm_pixarfilms()

# Primary keys ----

any(duplicated(pixar_dm$pixar_films$film))
check_key(pixar_dm$pixar_films, film)
any(duplicated(pixar_dm$academy[c("film", "award_type")]))
check_key(pixar_dm$academy, film, award_type)
try(
  check_key(pixar_dm$academy, film)
)

# Foreign keys ----

all(pixar_dm$academy$film %in% pixar_dm$pixar_films$film)
check_subset(pixar_dm$academy, film, pixar_dm$pixar_films, film)
try(
  check_subset(pixar_dm$pixar_films, film, pixar_dm$academy, film)
)

# Constraints ----

pixar_dm %>%
  dm_examine_constraints()

dm_pixarfilms(consistent = TRUE) %>%
  dm_examine_constraints()

dm_nycflights13() %>%
  dm_examine_constraints()

# Joins ----

pixar_dm %>%
  dm_zoom_to(academy)

# With zooming:
pixar_dm %>%
  dm_zoom_to(academy) %>%
  left_join(pixar_films, select = c(film, release_date))

# With flattening:
pixar_dm %>%
  dm_flatten_to_tbl(academy)

dm_nycflights13() %>%
  dm_select(weather, -year, -month, -day, -hour) %>%
  dm_flatten_to_tbl(flights)

# Joining is easy, leave the tables separate for as long as possible!

# Exercises --------------------------------------------------------------------

pixar_dm

# 1. Experiment.
