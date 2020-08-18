#pragma once

#include <vcpkg/base/span.h>

namespace vcpkg
{
    template<class T>
    using View = Span<const T>;
}
