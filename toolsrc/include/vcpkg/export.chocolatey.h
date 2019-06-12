#pragma once

#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgpaths.h>

#include <vector>

namespace vcpkg::Export::Chocolatey
{
    void do_export(const std::vector<Dependencies::ExportPlanAction>& export_plan,
                   const VcpkgPaths& paths);
}
