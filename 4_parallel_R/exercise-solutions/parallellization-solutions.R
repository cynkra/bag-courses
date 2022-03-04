vec <- c(2, 2, 2)

# sequential -------------------------------------------------------------------
system.time({
  for (i in vec) {
    Sys.sleep(i)
  }
})

# foreach and doParallel -------------------------------------------------------
library(foreach)
library(doParallel)
registerDoParallel(3)
system.time({
  foreach(i = vec) %dopar% {
    Sys.sleep(i)
  }
})

# foreach and doFuture ---------------------------------------------------------
library(foreach)
library(doFuture)
plan(multisession, workers = 3)
system.time({
  foreach(i = vec) %dopar% {
    Sys.sleep(i)
  }
})
# clean parallel cluster
plan(sequential)

# furrr ------------------------------------------------------------------------
plan(multisession)
system.time({
  furrr::future_walk(vec, Sys.sleep)
})
# clean parallel cluster
plan(sequential)

# future.apply -----------------------------------------------------------------
plan(multisession)
system.time({
  future.apply::future_lapply(vec, Sys.sleep)
})
# clean parallel cluster
plan(sequential)

# future() ---------------------------------------------------------------------
library(future)
plan(multisession)
system.time({
  res <- lapply(vec, function(x) future(Sys.sleep(x), lazy = TRUE))
})

system.time({
  value(res)
})
# clean parallel cluster
plan(sequential)

# parLapply and PSOCK cluster --------------------------------------------------
library(parallel)
cl <- makePSOCKcluster(3)
system.time({
  parLapply(cl, vec, Sys.sleep)
})
stopCluster(cl)

# future.callr -----------------------------------------------------------------
plan(future.callr::callr)
system.time({
  future.apply::future_lapply(vec, Sys.sleep)
})
# clean parallel cluster
plan(sequential)
