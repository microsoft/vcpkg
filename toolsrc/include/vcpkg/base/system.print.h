#pragma once

#include <vcpkg/base/strings.h>
#include <vcpkg/base/view.h>

namespace vcpkg::System
{
    enum class Color
    {
        success = 10,
        error = 12,
        warning = 14,
    };

    namespace details
    {
        void print(StringView message);
        void print(const Color c, StringView message);
    }

    template<class Arg1, class... Args>
    void printf(const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return ::vcpkg::System::details::print(Strings::format(message_template, message_arg1, message_args...));
    }

    template<class Arg1, class... Args>
    void printf(const Color c, const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return ::vcpkg::System::details::print(c, Strings::format(message_template, message_arg1, message_args...));
    }

    template<class... Args>
    void print2(const Color c, const Args&... args)
    {
        ::vcpkg::System::details::print(c, Strings::concat_or_view(args...));
    }

    template<class... Args>
    void print2(const Args&... args)
    {
        ::vcpkg::System::details::print(Strings::concat_or_view(args...));
    }
}
