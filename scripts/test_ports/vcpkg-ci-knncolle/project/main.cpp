#include "knncolle_annoy/knncolle_annoy.hpp"
#include "knncolle_hnsw/knncolle_hnsw.hpp"
#include "knncolle_kmknn/knncolle_kmknn.hpp"

// See examples in READMEs from
// https://github.com/knncolle/knncolle_annoy
// https://github.com/knncolle/knncolle_hnsw
// https://github.com/knncolle/knncolle_kmknn
int main() {

    int ndim = 10;
    int nobs = 10000;
    std::vector<double> matrix(ndim * nobs); // column-major ndim * nobs matrix.

    // Wrap our data in a light SimpleMatrix.
    knncolle::SimpleMatrix<int, double> mat(ndim, nobs, matrix.data());

    // Build an Annoy index with Euclidean distances.
    knncolle_annoy::AnnoyBuilder<int, double, double, Annoy::Euclidean> an_builder;
    auto an_index = an_builder.build_unique(mat);

    // Find 10 (approximate) nearest neighbors of every element.
    auto an_results = knncolle::find_nearest_neighbors(*an_index, 10);

    // Build a HNSW index, defaulting to Euclidean distances.
    auto euclid_config = knncolle_hnsw::configure_euclidean_distance<double>();
    knncolle_hnsw::HnswBuilder<int, double, double> h_builder(euclid_config);
    auto h_index = h_builder.build_unique(mat);

    // Find 10 (approximate) nearest neighbors of every element.
    auto h_results = knncolle::find_nearest_neighbors(*h_index, 10);

    // Build an KMKNN index.
    auto dist = std::make_shared<knncolle::EuclideanDistance<double, double> >();
    knncolle_kmknn::KmknnBuilder<int, double, double> kbuilder(dist, dist);
    auto k_index = kbuilder.build_unique(mat);

    // Find 10 nearest neighbors of every element.
    auto k_results = knncolle::find_nearest_neighbors(*k_index, 10);

    return 0;
}
