#pragma once
#include "package_spec.h"
#include "vcpkg_paths.h"

namespace vcpkg
{
    void perform_all_checks(const package_spec& spec, const vcpkg_paths& paths);
}
