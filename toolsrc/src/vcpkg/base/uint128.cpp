#include <vcpkg/base/uint128.h>

#include <limits>

namespace vcpkg
{
    UInt128& UInt128::operator<<=(int by) noexcept
    {
        if (by == 0)
        {
            return *this;
        }

        if (by < 64)
        {
            top <<= by;
            const auto shift_up = bottom >> (64 - by);
            top |= shift_up;
            bottom <<= by;
        }
        else
        {
            top = bottom;
            top <<= (by - 64);
            bottom = 0;
        }

        return *this;
    }

    UInt128& UInt128::operator>>=(int by) noexcept
    {
        if (by == 0)
        {
            return *this;
        }

        if (by < 64)
        {
            bottom >>= by;
            const auto shift_down = top << (64 - by);
            bottom |= shift_down;
            top >>= by;
        }
        else
        {
            bottom = top;
            bottom >>= (by - 64);
            top = 0;
        }

        return *this;
    }

    UInt128& UInt128::operator+=(uint64_t rhs) noexcept
    {
        // bottom + lhs > uint64::max
        if (bottom > std::numeric_limits<uint64_t>::max() - rhs)
        {
            top += 1;
        }
        bottom += rhs;
        return *this;
    }

}
