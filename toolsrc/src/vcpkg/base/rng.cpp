#include <base/rng.h>

namespace vcpkg::Rng {
    namespace {
        std::random_device system_entropy{};
    }

    splitmix::splitmix() {
        std::uint64_t top_half = system_entropy();
        std::uint64_t bottom_half = system_entropy();

        state = (top_half << 32) | bottom_half;
    }
}
