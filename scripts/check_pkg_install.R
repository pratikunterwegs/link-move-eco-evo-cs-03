
# check where fitness peaks are
library(data.table)
library(ggplot2)

t = 100
ni = 450
na = 300
ht = 5
cb = 0.05
d = CJ(
  b = seq(0.1, 20, 0.5),
  intake = seq(0, t/ht) * na / ni
)
d[, max_in := t / (round(ht / b) + 1)]
d = d[intake <= max_in,]
d[, energy := intake * ((1 - cb)^b)]

ggplot(d)+
  geom_tile(
    aes(b, intake, fill = energy)
  )+
  scale_fill_viridis_c(
    option = "H"
  )



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
  popsize = 20,
  scenario = 1,
  nItems = 1800,
  landsize = 30,
  nClusters = 180,
  clusterSpread = 0.5,
  regen_time = 100,
  genmax = 500,
  handling_time = 5,
  cost_bodysize = 0.0001,
  range_perception = 1.0,
  range_move = 1.0,
  dispersal = 2,
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
    breaks = c(0, 10 ^ seq(4)),
    trans = ggallin::pseudolog10_trans
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
