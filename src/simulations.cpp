#include <vector>
#include <random>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <Rcpp.h>
#include "simulations.h"

using namespace Rcpp;

Rcpp::List simulation::do_simulation() {

    unsigned seed = static_cast<unsigned> (std::chrono::system_clock::now().time_since_epoch().count());
    rng.seed(seed);
    
    // prepare landscape and pop
    food.initResources();
    food.countAvailable();
    Rcpp::Rcout << "landscape with " << food.nClusters << " clusters\n";

    pop.setTrait(mSize);
    Rcpp::Rcout << "pop with " << pop.nAgents << " agents for " << genmax << " gens " << tmax << " timesteps\n";

    // prepare scenario
    Rcpp::Rcout << "this is scenario " << (scenario == 1 ? "mechanistic movement" : "optimal movement") << "\n";

    // agent random position in first gen
    pop.initPos(food);
    // Rcpp::Rcout << "initialised population positions\n";
    
    Rcpp::DataFrame edgeList;
    Rcpp::DataFrame pop_trait_data;
    // Rcpp::Rcout << "created edge list object\n";

    // go over gens
    for(int gen = 0; gen < genmax; gen++) {

        food.countAvailable();
        // Rcpp::Rcout << "food available = " << food.nAvailable << "\n";

        // reset counter and positions
        pop.counter = std::vector<int> (pop.nAgents, 0);
        
        // Rcpp::Rcout << "entering ecological timescale\n";

        // timesteps start here
        for (size_t t = 0; t < static_cast<size_t>(tmax); t++)
        {
            // resources regrow
            food.regenerate();
            // Rcpp::Rcout << "food regenerated\n";
            pop.updateRtree();
            // Rcpp::Rcout << "updated r tree\n";
            
            // movement section
            if(scenario == 0) {
                pop.move_optimal(food, nThreads);
            } else {
                pop.move_mechanistic(food, nThreads);
            }
            // Rcpp::Rcout << "moved\n";

            // if(gen == (genmax - 1)) {
            //     mdPost.updateMoveData(pop, t);
            // }
            // Rcpp::Rcout << "logged movement data\n";

            // foraging -- split into parallelised picking
            // and non-parallel exploitation
            pop.pickForageItem(food, nThreads);
            pop.doForage(food);

            // count associations --- only in last gen
            if(gen == (genmax - 1)) {
                pop.countAssoc(nThreads);
            }
            // timestep ends here
        }

        // log data in the last generation
        if (gen == (genmax - 1)) {
            pop_trait_data = pop.returnPopData();
            edgeList = pop.pbsn.getNtwkDf();
        }

        // reproduce
        pop.Reproduce(food, dispersal, mProb, mSize, tmax);

        // generation ends here
    }
    // all gens end here

    Rcpp::Rcout << "gen: " << genmax << " --- logged edgelist\n";
    Rcpp::Rcout << "data prepared\n";

    return Rcpp::List::create(
        Named("gen_data") = pop_trait_data,
        Named("edge_list") = edgeList
        // Named("move_post") = mdPost.getMoveData()
    );
}

//' Runs an exploitation competition simulation returning structured output.
//'
//' @description Run the simulation using parameters passed as
//' arguments to the corresponding R function.
//'
//' @param scenario The scenario: 0 for random movement, 1 for optimal movement,
//' 2 for evolved mechanistic movement.
//' @param popsize The population size.
//' @param nItems How many food items on the landscape.
//' @param landsize The size of the landscape as a numeric (double).
//' @param nClusters Number of clusters around which food is generated.
//' @param clusterSpread How dispersed food is around the cluster centre.
//' @param tmax The number of timesteps per generation.
//' @param genmax The maximum number of generations per simulation.
//' @param range_perception The movement range for agents.
//' @param handling_time The handling time.
//' @param regen_time The item regeneration time.
//' @param nThreads How many threads to parallelise over. Set to 1 to run on
//' the HPC Peregrine cluster.
//' @param dispersal A float value; the standard deviation of a normal
//' distribution centred on zero, which determines how far away from its parent
//' each individual is initialised. The standard value is 5 percent of the
//' landscape size (\code{landsize}), and represents local dispersal.
//' Setting this to 10 percent is already almost equivalent to global dispersal.
//' @param mProb The probability of mutation. The suggested value is 0.01.
//' While high, this may be more appropriate for a small population; change this
//' value and \code{popsize} to test the simulation's sensitivity to these values.
//' @param mSize Controls the mutational step size, and represents the scale
//' parameter of a Cauchy distribution. 
//' @return An S4 class, `pathomove_output`, with simulation outcomes.
// [[Rcpp::export]]
S4 run_model(const int popsize, const int scenario,
               const int nItems, const float landsize,
               const int nClusters,
               const float clusterSpread,
               const int handling_time,
               const int regen_time,
               const int tmax,
               const int genmax,
               const float cost_perception,
               const float cost_bodysize,
               const float cost_move,
               const float size_scale,
               const float dispersal,
               const int nThreads,
               const float mProb,
               const float mSize) {

    // make simulation class with input parameters                            
    simulation this_sim(popsize, scenario, nItems, landsize,
        nClusters, clusterSpread, handling_time, regen_time,
        tmax, genmax, cost_perception, cost_bodysize,
        cost_move, size_scale, dispersal, nThreads,
        mProb, mSize
    );

    // return scenario as string
    std::string scenario_str = (scenario == 1 ? "evolved movement" : "optimal movement");
    
    Rcpp::List simOutput;
    simOutput = this_sim.do_simulation();

    // parameter list
    Rcpp::List param_list = Rcpp::List::create(
            Named("scenario") = scenario_str,
            Named("generations") = genmax,
            Named("timesteps") = tmax,
            Named("pop_size") = popsize,
            Named("pop_density") = static_cast<float>(popsize) / landsize,
            Named("item_density") = static_cast<float>(nItems) / landsize,
            Named("dispersal") = dispersal
        );

    // create S4 class pathomove output and fill slots
    S4 x("simulation_output");
    x.slot("parameters") = Rcpp::wrap(param_list);
    x.slot("trait_data") = Rcpp::wrap(simOutput["gen_data"]);
    x.slot("edge_list") = Rcpp::wrap(simOutput["edge_list"]);

    return(x);
}
