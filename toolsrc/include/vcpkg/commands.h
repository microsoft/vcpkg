#pragma once

#include <vcpkg/build.h>
#include <vcpkg/commands.interface.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/statusparagraphs.h>

#include <array>
#include <map>
#include <vector>

namespace vcpkg::Commands
{
    using CommandTypeA = void (*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    using CommandTypeB = void (*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    using CommandTypeC = const BasicCommand*;

    template<class T>
    struct PackageNameAndFunction
    {
        std::string name;
        T function;
    };

    Span<const PackageNameAndFunction<CommandTypeA>> get_available_commands_type_a();
    Span<const PackageNameAndFunction<CommandTypeB>> get_available_commands_type_b();
    Span<const PackageNameAndFunction<CommandTypeC>> get_available_commands_type_c();

    template<typename T>
    T find(StringView command_name, Span<const PackageNameAndFunction<T>> available_commands)
    {
        for (const PackageNameAndFunction<T>& cmd : available_commands)
        {
            if (cmd.name == command_name)
            {
                return cmd.function;
            }
        }

        // not found
        return nullptr;
    }
}
