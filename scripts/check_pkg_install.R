# check function
Rcpp::compileAttributes()
devtools::install(build = T, upgrade = "never")
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
  popsize = 500,
  scenario = 1,
  nItems = 5000,
  landsize = 60,
  nClusters = 120,
  clusterSpread = 0.5,
  handling_time = 5,
  regen_time = 100,
  tmax = 100,
  genmax = 500,
  cost_perception = 0.01,
  cost_bodysize = 0.01,
  cost_move = 0.0,
  size_scale = 1.0,
  dispersal = 10,
  mProb = 0.01,
  mSize = 0.01,
  nThreads = 2 # does not work with 1
)

data = ecoevomove3::get_trait_data(a)

ggplot(data)+
  geom_bin2d(
    aes(
      gen, sF
    ),
    binwidth = c(1, 0.01)
  )+
  scale_y_continuous(
    breaks = c(0, 10 ^ seq(4)),
    trans = ggallin::pseudolog10_trans
  )

b <- ecoevomove3::make_network(a, 1)

ecoevomove3::plot_network(b, bodysize) +
  scale_fill_viridis_c()
