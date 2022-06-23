
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
  regen_time = 100,
  p_type = 0.5
)

ggplot(l)+
  geom_point(
    aes(x, y, col = factor(type))
  )

# test case 0
a <- ecoevomove3::run_model(
  popsize = 500,
  scenario = 1,
  nItems = 450,
  p_type = 0.2,
  landsize = 30,
  nClusters = 30,
  clusterSpread = 0.5,
  regen_time = 50,
  genmax = 500,
  tmax = 100,
  handling_time = 5,
  range_perception = 1.0,
  range_move = 1.0,
  dispersal = 10,
  mProb = 0.01,
  mSize = 0.01,
  nThreads = 2 # does not work with 1
)

data = get_trait_data(a)

data |>
  ggplot(
    aes(gen, intake)
  )+
  stat_summary()

get_functional_variation(data)

ggplot(data[gen %% 100 == 0])+
  geom_hline(
    yintercept = 0
  )+
  geom_vline(
    xintercept = 0
  )+
  geom_point(
    aes(
      sA, sB, col = sH
    ),
    size = 3
  )+
  colorspace::scale_color_continuous_diverging(
    palette = "Blue-Red 2", rev = T
  )+
  facet_grid(
    ~gen
  )
