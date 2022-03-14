
# attach relevant packages
library(tidyverse)
library(DBI)

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

# Reading tables: Exercises ----------------------------------------------------

# 1. List all columns from the `box_office` table.

dbListFields(con_duckdb, "box_office")

# 2. Read the `academy` table.

dbReadTable(con_duckdb, "academy")

# 3. Read all records from the `academy` table that correspond to awards won
#     - Hint: Use the query "SELECT * FROM academy WHERE status = 'Won'"

dbGetQuery(con_duckdb, "SELECT * FROM academy WHERE status = 'Won'")

# 4. Use quoting and/or query parameters to stabilize the previous query.

dbGetQuery(con_duckdb,
  paste(
    "SELECT * FROM", dbQuoteIdentifier(con_duckdb, "academy"),
    "WHERE status = ?"
  ),
  params = list("Won")
)
