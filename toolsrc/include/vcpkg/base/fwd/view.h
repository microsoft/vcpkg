#pragma once

#include <vcpkg/base/fwd/span.h>

namespace vcpkg
{
    template<class T>
    using View = Span<const T>;
}
