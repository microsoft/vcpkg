#pragma once

#include <chrono>
#include <string>

namespace vcpkg
{
    class ElapsedTime
    {
    public:
        static ElapsedTime createStarted();

        constexpr ElapsedTime() :m_startTick() {}

        template <class TimeUnit>
        TimeUnit elapsed() const
        {
            return std::chrono::duration_cast<TimeUnit>(std::chrono::high_resolution_clock::now() - this->m_startTick);
        }

        std::string toString() const;

    private:
        std::chrono::steady_clock::time_point m_startTick;
    };

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
