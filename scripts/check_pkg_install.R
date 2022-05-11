# check function
Rcpp::compileAttributes()
devtools::build()
devtools::load_all()
devtools::install(build = T, upgrade = "never")
devtools::document()

library(ggplot2)

# test case 0
a <- ecoevomove3::run_model(
  popsize = 500,
  scenario = 0,
  nItems = 1800,
  landsize = 60,
  nClusters = 100,
  clusterSpread = 1.0,
  handling_time = 5,
  regen_time = 50,
  tmax = 100,
  genmax = 1000,
  cost_perception = 0.1,
  cost_bodysize = 1.0,
  cost_move = 0.0,
  size_scale = 10.0,
  dispersal = 3,
  mProb = 0.01,
  mSize = 0.01,
  nThreads = 2 # does not work with 1
)

ggplot(a@trait_data)+
  geom_point(
    aes(
      bodysize, percept
    )
  )

b <- ecoevomove3::make_network(a, 1)

ecoevomove3::plot_network(b, bodysize) +
  scale_fill_viridis_c()
