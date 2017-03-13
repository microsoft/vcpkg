#pragma once

#include <chrono>
#include <string>

namespace vcpkg
{
    class ElapsedTime
    {
    public:
        static ElapsedTime createStarted();

        constexpr ElapsedTime() : m_startTick() {}

        template <class TimeUnit>
        TimeUnit elapsed() const
        {
            return std::chrono::duration_cast<TimeUnit>(std::chrono::high_resolution_clock::now() - this->m_startTick);
        }

        double microseconds() const
        {
            return elapsed<std::chrono::duration<double, std::micro>>().count();
        }

        std::string toString() const;

    private:
        std::chrono::high_resolution_clock::time_point m_startTick;
    };
}
