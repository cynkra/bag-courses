# This file contains the exercises for the "R environments/packages" course
# feel free to write your code inline to solve the problems as we move through the course

### Setup ######################################################################

slide_viewer <- function(path) {
  tmp <- tempfile(fileext = ".html")
  file.copy(path, tmp)
  rstudioapi::viewer(tmp)
}
slide_viewer("3_r_pkgs/pkg-envs.html")

### R environments/packages ####################################################

# Environment basics -----------------------------------------------------------

e <- new.env()
e$a <- FALSE
e$b <- "a"
e$c <- 2.3
e$d <- 1:3

class(e)
is.environment(e)

parent.env(e)
ls(e)

e$c
e[["c"]]
e[[3]]
e[c("a", "b")]

# environments can contain themselves
e$b <- e
e
ls.str(e)

# multiple names can point to the same object
e$b <- e$d

# multiple names can point to different objects that have the same value
e$b <- 1:3

# if no names are pointing to an object, it gets automatically gc'ed
e$b <- new.env()
reg.finalizer(e$b, function(...) message("deleted!"))
gc()
rm("b", envir = e)
gc()

# Important environments -------------------------------------------------------

globalenv()
baseenv()
emptyenv()

parent.env(emptyenv())

identical(globalenv(), environment())

assign("a", 1, envir = globalenv())
assign("a", 1, envir = emptyenv())

# Exercises --------------------------------------------------------------------

env <- new.env()

# Variable scope ---------------------------------------------------------------

env1 <- new.env()
env2 <- new.env(parent = env1)

env1$a1 <- 1:2
env2$b1 <- 2:3

parent.env(env1)
parent.env(env2)

get("b1", envir = env2)
get("a1", envir = env2)
get("a1", envir = env2, inherits = FALSE)

parent.env(env2) <- .GlobalEnv
get("a1", envir = env2)

attach(list(a2 = 1:3, b2 = "bar"), name = "foo")
search()
a2
b2
ls()
detach("foo")
search()
