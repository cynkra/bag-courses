---
title: "Tidyverse Intro I"
author: ["Antoine & Nicolas", "cynkra GmbH"]
date: "January 25, 2022"
output:
  cynkradown::cynkra_slides:
    nature:
      highlightStyle: github
      highlightLines: true
      countIncrementalSlides: false
    seal: true
fontsize: 10pt
lang: english
font: frutiger
wide: false
colorlinks: false
logo: true
header-includes:
  - \usepackage{parskip}
---





class: middle, inverse
# Transformation 1

---

# Assignment

`x <- y` pronounced as "`x` _becomes_ `y`"


```r
x <- 3
x
```

```
## [1] 3
```

```r
x <- x + 1
```


---

# The pipe

`x %>% f() %>% g()` pronounced as "`x` _then_ `f` _then_ `g`"


```r
f <- function(x) x + 1
g <- function(x) x * 2
```

.pull-left[


```r
5 %>% f() %>% g()
```

```
## Error in 5 %>% f() %>% g(): could not find function "%>%"
```

]

.pull-right[


```r
g(f(5)) #<<
```

```
## [1] 12
```

```r
## Not:
f(g(5))
```

```
## [1] 11
```

]

---

# {dplyr}: Basic pattern

```r
data %>%
  verb(...) %>%
  verb(...) %>%
  ...
```

Each `verb` is a **pure function** (doesn't change its input)!

Use assignment to persist the result:

```r
result <-
  data %>%
  verb(...) ...
```

---

# Verbs

- `filter()`: Removes rows
- `select()`: Removes and renames columns
- `arrange()`: Reorders
- `mutate()`: Creates variables
- `summarize()`: Computes summaries

## Grouped operations

- `group_by()`: Defines grouping for the next operation
