#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

namespace vcpkg::System
{
    namespace details
    {
        void print(StringView message) { fwrite(message.data(), 1, message.size(), stdout); }

        void print(const Color c, StringView message)
        {
#if defined(_WIN32)
            const HANDLE console_handle = GetStdHandle(STD_OUTPUT_HANDLE);

            CONSOLE_SCREEN_BUFFER_INFO console_screen_buffer_info{};
            GetConsoleScreenBufferInfo(console_handle, &console_screen_buffer_info);
            const auto original_color = console_screen_buffer_info.wAttributes;

            SetConsoleTextAttribute(console_handle, static_cast<WORD>(c) | (original_color & 0xF0));
            System::print2(message);
            SetConsoleTextAttribute(console_handle, original_color);
#else
            // TODO: add color handling code
            // it should probably use VT-220 codes
            Util::unused(c);
            System::print2(message);
#endif
        }
    }
}
