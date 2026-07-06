#include <flann/flann.hpp>
#ifdef WITH_HDF5
#include <flann/hdf5.hpp>
#endif

#include <array>

int main() {
    flann::Index<flann::L2<float>> index({});
    index.usedMemory();
#ifdef WITH_HDF5
    flann::load_from_file({}, {}, {});
#endif

    return 0;
}
