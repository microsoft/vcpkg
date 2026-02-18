#include "umappp/umappp.hpp"

// See example in README from https://github.com/libscran/umappp
int main() {
    
    // Define the test data
    int ndim = 2;
    int nobs = 2;
    std::vector<double> data(ndim * nobs, 0.f);

    // Configuring the neighbor search algorithm
    knncolle::VptreeBuilder<int, double, double> vp_builder(
        std::make_shared<knncolle::EuclideanDistance<double, double> >()
    );

    // Set number of dimensions in the output embedding
    size_t out_dim = 1;
    std::vector<double> embedding(nobs * out_dim);

    // Initialize the UMAP state
    umappp::Options opt;
    auto status = umappp::initialize(
        ndim,
        nobs,
        data.data(),
        vp_builder, 
        out_dim,
        embedding.data(),
        opt
    );

    return 0;
}
