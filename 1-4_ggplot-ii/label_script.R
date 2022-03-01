library(tidyverse)

# compute a second dataset to plot on top of mpg
avgs <-
  mpg %>%
  group_by(drv) %>%
  summarize(displ = mean(displ), hwy = mean(hwy))
avgs

# Using 2 data sets foir a single plot
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(data = avgs, size = 6)

# Actually let's use fancy circles, using for aggregated dots the shape 21,
 # that has a color AND a fill
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black")

# Let's add a label too
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black")  +
  geom_label(aes(label = drv), data = avgs)

# The label is in front of the circle! and the legend changed too
# Let's nudge the label first
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black")  +
  geom_label(aes(label = drv), data = avgs, nudge_y = 3, show.legend = FALSE)

# Now let's set show.legend = FALSE in last layer so we keep the legend from the previous layer
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black")  +
  geom_label(aes(label = drv), data = avgs, nudge_y = 3, show.legend = FALSE)

# Can we make these labels more informative ? maybe they could contain the coordinates ?
# we can build a fancy label on the fly
library(glue)
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black") +
  geom_label(aes(label = glue("({round(displ)}, {round(hwy)})")),
             data = avgs, , nudge_y = 3, show.legend = FALSE)

# it's find this way, but I like to keep data manipulation outside of the plot,
# let's add a col to our avgs dataset
avgs <-
  avgs %>%
  mutate(lab = glue("({round(displ)}, {round(hwy)})"))
avgs

# now we can simplify the plot code
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black") +
  geom_label(aes(label = lab), data = avgs, , nudge_y = 3, show.legend = FALSE)


# Ok let's prettify it, these variable names are a bit obscure and this gray default
# color is ugly
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point() +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black") +
  geom_label(aes(label = lab), data = avgs, , nudge_y = 3, show.legend = FALSE) +
  labs(
    title = "Highway miles per galon vs Engine displacement",
    subtitle = "Big circles represent averages for each drive train type",
    caption = "ggplot chart using `mpg` dataset",
    x = "Engine displacement (litres)",
    y = "Highway miles per galon",
    fill = "Drive train type") +
  theme_classic()

# Oh no! if I set the legend manually the legend that comes with the 2nd layer
# doesn't override the first legend, I know have both, but I don't need the other one!
# I'll set show.legend = FALSE to that one too
ggplot(mpg, aes(x = displ, y = hwy, color = drv))  +
  geom_point(show.legend = FALSE) +
  geom_point(aes(fill = drv), data = avgs, size = 6, shape = 21, color = "black") +
  geom_label(aes(label = lab), data = avgs, , nudge_y = 3, show.legend = FALSE) +
  labs(
    title = "Highway miles per galon vs Engine displacement",
    subtitle = "Big circles represent averages for each drive train type",
    caption = "ggplot chart using `mpg` dataset",
    x = "Engine displacement (litres)",
    y = "Highway miles per galon",
    fill = "Drive train type") +
  theme_classic()



