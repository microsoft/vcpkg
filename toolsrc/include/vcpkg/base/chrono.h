#pragma once

#include <chrono>
#include <string>

namespace vcpkg::Chrono
{
    class ElapsedTime
    {
    public:
        static ElapsedTime create_started();

        constexpr ElapsedTime() : m_start_tick() {}

        template<class TimeUnit>
        TimeUnit elapsed() const
        {
            return std::chrono::duration_cast<TimeUnit>(std::chrono::high_resolution_clock::now() - this->m_start_tick);
        }

        double microseconds() const { return elapsed<std::chrono::duration<double, std::micro>>().count(); }

        std::string to_string() const;

    private:
        std::chrono::high_resolution_clock::time_point m_start_tick;
    };
}
