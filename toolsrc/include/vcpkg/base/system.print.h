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

    class BufferedPrint
    {
        ::std::string stdout_buffer;
        static constexpr ::std::size_t buffer_size_target = 2048;
        static constexpr ::std::size_t expected_maximum_print = 256;
        static constexpr ::std::size_t alloc_size = buffer_size_target + expected_maximum_print;

    public:
        BufferedPrint() { stdout_buffer.reserve(alloc_size); }
        BufferedPrint(const BufferedPrint&) = delete;
        BufferedPrint& operator=(const BufferedPrint&) = delete;
        void append(::vcpkg::StringView nextView)
        {
            stdout_buffer.append(nextView.data(), nextView.size());
            if (stdout_buffer.size() > buffer_size_target)
            {
                ::vcpkg::System::details::print(stdout_buffer);
                stdout_buffer.clear();
            }
        }
        ~BufferedPrint() { ::vcpkg::System::details::print(stdout_buffer); }
    };
}
