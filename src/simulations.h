#ifndef SIMULATIONS_H
#define SIMULATIONS_H

#include "data_types.h"
#include "landscape.h"
#include "agents.h"

class simulation {
public:
    simulation(const int popsize, const int scenario,
               const int nItems, const float landsize,
               const int nClusters,
               const float clusterSpread,
               const int handling_time,
               const int regen_time,
               const int tmax,
               const int genmax,
               const float range_perception,
               const float cost_bodysize,
               const float range_move,
               const float dispersal,
               const int nThreads,
               const float mProb,
               const float mSize):
        // population, food, and data structures
        pop (popsize, handling_time, range_perception,
            cost_bodysize, range_move, scenario),
        food(nItems, landsize, nClusters, clusterSpread, regen_time),
        
        // eco-evolutionary parameters
        scenario(scenario),
        tmax(tmax),
        genmax(genmax),
        dispersal(dispersal),

        // parallelisation
        nThreads (nThreads),

        // mutation probability and step size
        mProb(mProb),
        mSize(mSize)
    {}
    ~simulation() {}

    Population pop;
    Resources food;
    const int scenario, tmax, genmax;
    const float dispersal;
    
    int nThreads;
    
    const float mProb, mSize;

    // funs
    Rcpp::List do_simulation();

};

#endif // SIMULATIONS_H
