#pragma once

#include <chrono>
#include <string>

namespace vcpkg::Chrono
{
    class ElapsedTime
    {
        using duration = std::chrono::high_resolution_clock::time_point::duration;

    public:
        constexpr ElapsedTime() : m_duration() {}
        constexpr ElapsedTime(duration d) : m_duration(d) {}

        template<class TimeUnit>
        TimeUnit as() const
        {
            return std::chrono::duration_cast<TimeUnit>(m_duration);
        }

        std::string to_string() const;

    private:
        std::chrono::high_resolution_clock::time_point::duration m_duration;
    };

    class ElapsedTimer
    {
    public:
        static ElapsedTimer create_started();

        constexpr ElapsedTimer() : m_start_tick() {}

        ElapsedTime elapsed() const
        {
            return ElapsedTime(std::chrono::high_resolution_clock::now() - this->m_start_tick);
        }

        double microseconds() const { return elapsed().as<std::chrono::duration<double, std::micro>>().count(); }

        std::string to_string() const;

    private:
        std::chrono::high_resolution_clock::time_point m_start_tick;
    };
}
