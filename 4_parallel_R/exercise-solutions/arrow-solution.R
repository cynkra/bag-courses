library(arrow, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)

# 1. download data for year 2010
arrow::copy_files("s3://ursa-labs-taxi-data/2010", "nyc-taxi/2010")


# 2. list and sum file sizes
files <- list.files("nyc-taxi", full.names = TRUE, recursive = TRUE)
vect_size <- sapply(files, function(x) utils:::format.object_size(file.info(x)$size, "auto"))
size_files <- sum(vect_size_mb)

# 3. Read dataset
ds <- open_dataset("nyc-taxi", partitioning = "month")

# 4. Print passenger count for March
ds %>%
  filter(month == 3) %>%
  select(passenger_count) %>%
  collect() %>%
  summarise(sum = sum(passenger_count))

