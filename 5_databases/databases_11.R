# install.packages(c("tidyverse", "dm", "DiagrammeR", "RSQLite", "duckdb", "progress", "pixarfilms", "nycflights13"), type = "binary")
# pak::pak(c("tidyverse", "dm", "DiagrammeR", "RSQLite", "duckdb", "progress", "pixarfilms", "nycflights13"))

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

### Reading whole tables from the database #####################################

# Connection -------------------------------------------------------------------

con_duckdb <- dbConnect(duckdb::duckdb())
con_duckdb

# Magic: import tables into the database
dm::copy_dm_to(
  con_duckdb,
  dm::dm_pixarfilms(),
  set_key_constraints = FALSE,
  temporary = FALSE
)

# Discover tables --------------------------------------------------------------

dbListTables(con_duckdb)
dbListFields(con_duckdb, "pixar_films")

# Read table -------------------------------------------------------------------

df_pixar_films <- dbReadTable(con_duckdb, "pixar_films")
df_pixar_films
as_tibble(df_pixar_films)

# Execute queries --------------------------------------------------------------

dbGetQuery(con_duckdb, "SELECT * FROM pixar_films")

sql <- "SELECT * FROM pixar_films WHERE release_date >= '2020-01-01'"
# sql <- r"(SELECT * FROM "pixar_films" WHERE "release_date" >= '2020-01-01')"
dbGetQuery(con_duckdb, sql)

# Further pointers -------------------------------------------------------------

# Quoting identifiers
dbQuoteIdentifier(con_duckdb, "academy")

# Quoting literals
dbQuoteLiteral(con_duckdb, "Toy Story")
dbQuoteLiteral(con_duckdb, as.Date("2020-01-01"))

# Paste queries with glue_sql()

# Parameterized queries
sql <- "SELECT count(*) FROM pixar_films WHERE release_date >= ?"
dbGetQuery(con_duckdb, sql, params = list(as.Date("2020-01-01")))

# Reading tables: Exercises ----------------------------------------------------

con_duckdb

# 1. List all columns from the `box_office` table.
# 2. Read the `academy` table.
# 3. Read all records from the `academy` table that correspond to awards won
#     - Hint: Use the query "SELECT * FROM academy WHERE status = 'Won'"
# 4. Use quoting and/or query parameters to stabilize the previous query.
