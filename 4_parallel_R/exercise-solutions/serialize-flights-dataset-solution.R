library(nycflights13)
library(fst)
library(qs)

data(flights)

# 1. serialize via saveRDS()
system.time(saveRDS(flights, "flights-base-R.rds"))

# 2. serialize via {fst}
system.time(fst::write_fst(flights, "flights-fst.fst"))

# 3. serialize via {qs}
system.time(qs::qsave(flights, "flights-qs.qs"))

# 4. serialize via {qs} using preset  = "fast"
system.time(qs::qsave(flights, "flights-qs.qs", preset = "fast"))

# 5. serialize via {qs} using preset  = "fast" & all cores
cores = parallel::detectCores()
system.time(qs::qsave(flights, "flights-qs.qs", preset = "fast", nthreads = cores))

# 6. Read subset of data from compressed file via {fst}
system.time(read_fst("flights-fst.fst", "dep_time", 101, 200))

# 7. Read subset of data from compressed file via {qs}
system.time(qread("flights-qs.qs")[100:200, "dep_time"])

# 8. Read subset of data from compressed file via {qs}
system.time(readRDS("flights-base-R.rds")[100:200, "dep_time"])
