#pragma once

#include "vcpkg_Checks.h"
#include <unordered_set>

namespace vcpkg::Sets
{
    template <typename T, typename Container>
    void remove_all(std::unordered_set<T>* input_set, Container remove_these)
    {
        Checks::check_throw(input_set != nullptr, "Input set cannot be null");
        for (const T& r : remove_these)
        {
            input_set->erase(r);
        }
    }
}
