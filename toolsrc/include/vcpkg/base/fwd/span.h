#pragma once

namespace vcpkg
{
    template<class T>
    struct Span;

    template<class T>
    using View = Span<const T>;
}
