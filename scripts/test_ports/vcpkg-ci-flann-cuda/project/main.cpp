#include <flann/flann.hpp>

#include <flann/algorithms/kdtree_cuda_3d_index.h>

#include <array>

int main() {
    flann::Matrix<float> dataset;

    flann::Index<flann::L2<float>> index(dataset, flann::KDTreeIndexParams());
    index.usedMemory();

    flann::KDTreeCuda3dIndexParams params;

    return 0;
}
