#include <base/rng.h>

namespace vcpkg {
    namespace {
        std::random_device system_entropy{};
    }

    splitmix64_engine::splitmix64_engine() {
        std::uint64_t top_half = system_entropy();
        std::uint64_t bottom_half = system_entropy();

        state = (top_half << 32) | bottom_half;
    }
}
