#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/

#include <vcpkg/fwd/registries.h>

#include <memory>
#include <string>
#include <system_error>
#include <vector>

namespace vcpkg
{
    struct RegistryImpl
    {
        virtual void update(std::error_code&) = 0;
        virtual Optional<fs::path> find_port(StringView name) const = 0;

        virtual ~RegistryImpl() = default;
    };

    struct Registry
    {
        std::string name;
        std::vector<std::string> packages;

        std::unique_ptr<RegistryImpl> underlying;
    };

}
