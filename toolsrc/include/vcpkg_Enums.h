#pragma once
#include <string>

namespace vcpkg::Enums
{
    std::string nullvalue_toString(const std::string& enum_name);

    __declspec(noreturn) void nullvalue_used(const std::string& enum_name);

    __declspec(noreturn) void unreachable(const std::string& enum_name);
}
