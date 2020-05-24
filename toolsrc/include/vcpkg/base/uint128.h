#pragma once

#include <stdint.h>

namespace vcpkg {

struct UInt128 {
    UInt128() = default;
    UInt128(uint64_t value) : bottom(value), top(0) {}

    UInt128& operator<<=(int by) noexcept;
    UInt128& operator>>=(int by) noexcept;
    UInt128& operator+=(uint64_t lhs) noexcept;

    uint64_t bottom_64_bits() const noexcept {
        return bottom;
    }
    uint64_t top_64_bits() const noexcept {
        return top;
    }
private:
    uint64_t bottom;
    uint64_t top;
};

}
