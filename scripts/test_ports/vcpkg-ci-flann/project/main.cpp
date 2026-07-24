#include <flann/flann.hpp>
#ifdef WITH_HDF5
#include <flann/io/hdf5.h>
#endif

#include <array>

int main() {
    flann::Matrix<float> dataset;

    flann::Index<flann::L2<float>> index(dataset, flann::KDTreeIndexParams());
    index.usedMemory();
#ifdef WITH_HDF5
    flann::load_from_file(dataset, {}, {});
#endif

    return 0;
}
