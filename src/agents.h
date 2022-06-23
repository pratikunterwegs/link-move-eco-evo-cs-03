#ifndef AGENTS_H
#define AGENTS_H

#define _USE_MATH_DEFINES
/// code to make agents
#include <vector>
#include <cassert>
#include <algorithm>
#include <iostream>
#include <boost/foreach.hpp>
#include "landscape.h"
#include "network.h"


// Agent class
struct Population {
public:
    Population(const int popsize, const int handling_time, 
    const float range_perception,
    const float range_move, const int scenario) :
        // agents, positions, energy and traits
        nAgents (popsize),
        coordX (popsize, 0.0f),
        coordY (popsize, 0.0f),
        initX (popsize, 0.0f),
        initY (popsize, 0.0f),
        intake (popsize, 0.001f),
        energy (popsize, 0.001f),
        
        sA (popsize, 0.f),
        sB (popsize, 0.f),
        sH (popsize, 0.f),
        sN (popsize, 0.f),
        
        wA (popsize, 0.f),
        wB (popsize, 0.f),
        wH (popsize, 0.f),
        wN (popsize, 0.f),

        // counters for handling and social metrics
        counter (popsize, 0),
        currentFoodChoice (popsize, 1),
        associations(popsize, 0),

        // agent sensory parameters
        n_samples (8.f),
        range_perception(range_perception),
        range_move(range_move),
        handling_time(handling_time),

        // vectors for agent order
        order(popsize, 1),
        forageItem(popsize, -1),
        
        // distance moved and movement parameters
        moved(popsize, 0.f),

        // a network object
        pbsn(popsize)
    {}
    ~Population() {}

    // agent count, coords, and energy
    const int nAgents;
    std::vector<float> coordX;
    std::vector<float> coordY;
    std::vector<float> initX;
    std::vector<float> initY;
    std::vector<float> intake;
    std::vector<float> energy;
    // weights
    std::vector<float> sA;
    std::vector<float> sB;
    std::vector<float> sH;
    std::vector<float> sN;

    // weights
    std::vector<float> wA;
    std::vector<float> wB;
    std::vector<float> wH;
    std::vector<float> wN;

    // counter and metrics
    std::vector<int> counter;
    std::vector<int> currentFoodChoice;
    std::vector<int> associations; // number of total interactions

    // sensory range and foraging
    const float n_samples;
    const float range_perception;
    const float range_move;
    const int handling_time;

    // shuffle vector and transmission
    std::vector<int> order;
    std::vector<int> forageItem;

    // movement distances, costs, and size scaling
    std::vector<float> moved;

    // position rtree
    bgi::rtree< value, bgi::quadratic<16> > agentRtree;

    // network object
    Network pbsn;

    /// functions for the population ///
    // population order, trait and position randomiser
    void shufflePop();
    void setTrait (const float mSize);
    void initPos(Resources food);

    // make rtree and get nearest agents and food
    void updateRtree();

    std::pair<int, int> countFood (const Resources &food, const float xloc, const float yloc);
    
    std::vector<int> getFoodId (
        const Resources &food,
        const int foodChoice,
        const float xloc, const float yloc
    );
    
    std::pair<int, int > countAgents (
        const float xloc, const float yloc);
    
    std::vector<int> getNeighbourId (
        const float xloc, const float yloc
    );

    // functions to move and forage on a landscape
    void move_mechanistic(const Resources &food, const int nThreads);
    void do_prey_choice(const Resources &food, const int nThreads);
    void pickForageItem(const Resources &food, const int nThreads);
    void doForage(Resources &food);
    
    // funs to handle fitness and reproduce
    std::vector<float> handleFitness(const float time);
    void Reproduce(const Resources food, 
        const float dispersal,
        const float mProb,
        const float mSize,
        const float time
    );
    
    // counting proximity based interactions
    void countAssoc(const int nThreads);

    // return population data
    Rcpp::DataFrame returnPopData();
};

// a dinky function for distance and passed to catch test
float get_distance(float x1, float x2, float y1, float y2);

#endif // AGENTS_H
