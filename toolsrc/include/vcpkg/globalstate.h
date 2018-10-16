#pragma once

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/util.h>

#include <atomic>

namespace vcpkg
{
    struct GlobalState
    {
        static Util::LockGuarded<Chrono::ElapsedTimer> timer;
        static Util::LockGuarded<std::string> g_surveydate;

        static std::atomic<bool> debugging;
        static std::atomic<bool> feature_packages;
        static std::atomic<bool> g_binary_caching;

        static std::atomic<int> g_init_console_cp;
        static std::atomic<int> g_init_console_output_cp;
        static std::atomic<bool> g_init_console_initialized;

        struct CtrlCStateMachine
        {
            CtrlCStateMachine();

            void transition_to_spawn_process() noexcept;
            void transition_from_spawn_process() noexcept;
            void transition_handle_ctrl_c() noexcept;

        private:
            enum class CtrlCState
            {
                normal,
                blocked_on_child,
                exit_requested,
            };

            std::atomic<CtrlCState> m_state;
        };

        static CtrlCStateMachine g_ctrl_c_state;
    };
}
