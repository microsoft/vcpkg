#pragma once

#include <vcpkg/build.h>
#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands
{
    template<class T>
    struct PackageNameAndFunction
    {
        std::string name;
        T function;
    };

    Span<const PackageNameAndFunction<const BasicCommand*>> get_available_basic_commands();
    Span<const PackageNameAndFunction<const PathsCommand*>> get_available_paths_commands();
    Span<const PackageNameAndFunction<const TripletCommand*>> get_available_triplet_commands();

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
