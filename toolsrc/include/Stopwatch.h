#pragma once

#include <chrono>
#include <string>

namespace vcpkg
{
    class Stopwatch
    {
    public:
        static Stopwatch createUnstarted();

        static Stopwatch createStarted();

        bool isRunning() const;

        const Stopwatch& start();

        const Stopwatch& stop();

        Stopwatch& reset();

        template <class TimeUnit>
        TimeUnit elapsed() const
        {
            return std::chrono::duration_cast<TimeUnit>(elapsedNanos());
        }

        std::string toString() const;

    private:
        Stopwatch();

        std::chrono::nanoseconds elapsedNanos() const;

        bool m_isRunning;
        std::chrono::nanoseconds m_elapsedNanos;
        std::chrono::steady_clock::time_point m_startTick;
    };
}
