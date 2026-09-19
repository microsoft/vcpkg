#include <flann/flann.hpp>

#include <flann/io/hdf5.h>

#include <array>

int main() {
    flann::Matrix<float> dataset;

    flann::Index<flann::L2<float>> index(dataset, flann::KDTreeIndexParams());
    index.usedMemory();

    flann::load_from_file(dataset, {}, {});

    return 0;
}
