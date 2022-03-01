vec <- c(2, 2, 2)
# sequential
system.time({
  for (i in vec) {
    Sys.sleep(i)
  }
})

# 2. foreach and doParallel
system.time({
  library(foreach)
  library(doParallel)
  registerDoParallel(3)
  foreach(i = vec) %dopar% {
    Sys.sleep(i)
  }
})

# 3. foreach and doParallel
system.time({
  library(foreach)
  library(doFuture)
  plan(multisession)
  foreach(i = vec) %dopar% {
    Sys.sleep(i)
  }
})

# 4. parLapply and PSOCK cluster
system.time({
  library(parallel)
  cl <- makePSOCKcluster(getOption("cl.cores", 3))
  parLapply(cl, vec, Sys.sleep)
  stopCluster(cl)
})

# 5. furrr
system.time({
  library(furrr)
  plan(multisession)
  future_walk(vec, Sys.sleep)
})

# 6. future.apply
system.time({
  library(future.apply)
  plan(multisession)
  future_lapply(vec, Sys.sleep)
})

# 7. future()
system.time({
  library(future)
  plan(multisession)
  res <- lapply(vec, function(x) future(Sys.sleep(x), lazy = TRUE))
  value(res)
})

# 8. future.callr
system.time({
  library(future.apply)
  library(future.callr)
  plan(callr)
  future_lapply(vec, Sys.sleep)
})
