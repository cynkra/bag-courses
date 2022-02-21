library(tidyverse)

# Possible solutions

# Exercise 1 - geom_point
# Using the `iris` dataset available in R by default,
# create a scatter plot using 2 numeric columns, and use
# `Species` as a color. You can use the pattern we used above.

ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
  geom_point()

# Exercise 2 - geom_line

ggplot(economics, aes(x = date, y = unemploy)) +
  geom_line(color = "blue", linetype = "dashed")

# Exercise 3 - geom_bar()

ggplot(diamonds, aes(x = cut, fill = color)) +
  geom_bar()

ggplot(diamonds, aes(x = cut, fill = color)) +
  geom_bar(position = "dodge")

ggplot(diamonds, aes(x = cut, fill = color)) +
  geom_bar(position = "fill")

# Exercise - geom_boxplot(), title and legends

ggplot(iris, aes(x = Species, y = Sepal.Length)) +
  geom_boxplot() +
  labs(
    x = "Different Species",
    y = "Sepal length",
    title = "Distribution of sepal length",
    subtitle = "By species"
  )
