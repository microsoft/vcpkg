#include <flann/flann.hpp>

#include <array>

int main() {
    flann::Matrix<float> dataset;

    flann::Index<flann::L2<float>> index(dataset, flann::KDTreeIndexParams());
    index.usedMemory();

    return 0;
}
