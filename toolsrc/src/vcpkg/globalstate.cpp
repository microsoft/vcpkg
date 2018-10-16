#include "pch.h"

#include <vcpkg/globalstate.h>

namespace vcpkg
{
    Util::LockGuarded<Chrono::ElapsedTimer> GlobalState::timer;
    Util::LockGuarded<std::string> GlobalState::g_surveydate;

    std::atomic<bool> GlobalState::debugging(false);
    std::atomic<bool> GlobalState::feature_packages(true);
    std::atomic<bool> GlobalState::g_binary_caching(false);

    std::atomic<int> GlobalState::g_init_console_cp(0);
    std::atomic<int> GlobalState::g_init_console_output_cp(0);
    std::atomic<bool> GlobalState::g_init_console_initialized(false);

    GlobalState::CtrlCStateMachine GlobalState::g_ctrl_c_state;

    GlobalState::CtrlCStateMachine::CtrlCStateMachine() : m_state(CtrlCState::normal) {}

    void GlobalState::CtrlCStateMachine::transition_to_spawn_process() noexcept
    {
        auto expected = CtrlCState::normal;
        auto transitioned = m_state.compare_exchange_strong(expected, CtrlCState::blocked_on_child);
        if (!transitioned)
        {
            // Ctrl-C was hit and is asynchronously executing on another thread
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }
    void GlobalState::CtrlCStateMachine::transition_from_spawn_process() noexcept
    {
        auto expected = CtrlCState::blocked_on_child;
        auto transitioned = m_state.compare_exchange_strong(expected, CtrlCState::normal);
        if (!transitioned)
        {
            // Ctrl-C was hit while blocked on the child process
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }
    void GlobalState::CtrlCStateMachine::transition_handle_ctrl_c() noexcept
    {
        auto prev_state = m_state.exchange(CtrlCState::exit_requested);

        if (prev_state == CtrlCState::normal)
        {
            // Not currently blocked on a child process and Ctrl-C has not been hit.
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        else if (prev_state == CtrlCState::exit_requested)
        {
            // Ctrl-C was hit previously
        }
        else
        {
            // This is the case where we are currently blocked on a child process
        }
    }
}
