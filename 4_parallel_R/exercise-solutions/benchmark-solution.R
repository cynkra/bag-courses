library(nycflights13)
library(bench)
library(dplyr)
library(data.table)
library(tibble)
library(ggplot2)

data("flights")
flights_dt <- as.data.table(flights)

bm <- bench::mark(
  {
    flights %>%
      mutate(dep_time = as.character(dep_time))
  },
  {
    flights$dep_time <- as.character(flights$dep_time)
    flights
  },
  {
    flights_dt[, dep_time := as.character(dep_time)]
    flights_dt
  },
  check = FALSE
)

autoplot(bm)
