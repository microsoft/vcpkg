#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/chrono.h>

namespace vcpkg::Chrono
{
    static std::string format_time_userfriendly(const std::chrono::nanoseconds& nanos)
    {
        using std::chrono::duration_cast;
        using std::chrono::hours;
        using std::chrono::microseconds;
        using std::chrono::milliseconds;
        using std::chrono::minutes;
        using std::chrono::nanoseconds;
        using std::chrono::seconds;

        const double nanos_as_double = static_cast<double>(nanos.count());

        if (duration_cast<hours>(nanos) > hours())
        {
            const auto t = nanos_as_double / duration_cast<nanoseconds>(hours(1)).count();
            return Strings::format("%.4g h", t);
        }

        if (duration_cast<minutes>(nanos) > minutes())
        {
            const auto t = nanos_as_double / duration_cast<nanoseconds>(minutes(1)).count();
            return Strings::format("%.4g min", t);
        }

        if (duration_cast<seconds>(nanos) > seconds())
        {
            const auto t = nanos_as_double / duration_cast<nanoseconds>(seconds(1)).count();
            return Strings::format("%.4g s", t);
        }

        if (duration_cast<milliseconds>(nanos) > milliseconds())
        {
            const auto t = nanos_as_double / duration_cast<nanoseconds>(milliseconds(1)).count();
            return Strings::format("%.4g ms", t);
        }

        if (duration_cast<microseconds>(nanos) > microseconds())
        {
            const auto t = nanos_as_double / duration_cast<nanoseconds>(microseconds(1)).count();
            return Strings::format("%.4g us", t);
        }

        return Strings::format("%.4g ns", nanos_as_double);
    }

    ElapsedTime ElapsedTime::create_started()
    {
        ElapsedTime t;
        t.m_start_tick = std::chrono::high_resolution_clock::now();
        return t;
    }

    std::string ElapsedTime::to_string() const { return format_time_userfriendly(elapsed<std::chrono::nanoseconds>()); }
}
