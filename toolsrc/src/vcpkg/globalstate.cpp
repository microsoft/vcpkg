#include <vcpkg/globalstate.h>

namespace vcpkg
{
    Util::LockGuarded<Chrono::ElapsedTimer> GlobalState::timer;
    Util::LockGuarded<std::string> GlobalState::g_surveydate;

    std::atomic<int> GlobalState::g_init_console_cp(0);
    std::atomic<int> GlobalState::g_init_console_output_cp(0);
    std::atomic<bool> GlobalState::g_init_console_initialized(false);
}
