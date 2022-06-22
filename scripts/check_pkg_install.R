# check function
Rcpp::compileAttributes()

{
  sink(file = "output.log")
  devtools::install(build = T, upgrade = "never")
  sink()
}
devtools::document()

library(ggplot2)

l = ecoevomove3::get_test_landscape(
  nItems = 5000,
  landsize = 60,
  nClusters = 100,
  clusterSpread = 0.5,
  regen_time = 100
)

ggplot(l)+
  geom_point(
    aes(x, y)
  )

# test case 0
a <- ecoevomove3::run_model(
  popsize = 200,
  scenario = 1,
  nItems = 450,
  landsize = 30,
  nClusters = 90,
  clusterSpread = 0.5,
  regen_time = 100,
  genmax = 500,
  tmax = 100,
  handling_time = 5,
  cost_bodysize = 0.015,
  range_perception = 1.0,
  range_move = 1.0,
  dispersal = 10,
  mProb = 0.01,
  mSize = 0.01,
  nThreads = 2 # does not work with 1
)

data = ecoevomove3::get_trait_data(a)

data[gen == max(gen)] |>
  ggplot(aes(bodysize, intake))+
  geom_jitter()

ggplot(data)+
  geom_bin2d(
    aes(
      gen, bodysize

    ),
    binwidth = c(1, 0.001)
  )+
  scale_y_continuous(
    # breaks = c(0, 10 ^ seq(4)),
    # trans = ggallin::pseudolog10_trans
  )

ggplot(data)+
  geom_bin2d(
    aes(
      gen, moved
    ),
    binwidth = c(1, 1)
  )
  scale_y_continuous(
    breaks = c(0, 10 ^ seq(4)),
    trans = ggallin::pseudolog10_trans
  )

ggplot(data[gen == max(gen)])+
  geom_jitter(
    aes(bodysize, moved)
  )

ggplot(data[gen == max(gen)])+
  geom_histogram(
    aes(bodysize)
  )

ggplot(data[gen %in% c(min(gen),max(gen))])+
  geom_jitter(
    aes(bodysize, sH)
  )+
  facet_grid(~gen)
