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

    ElapsedTimer ElapsedTimer::create_started()
    {
        ElapsedTimer t;
        t.m_start_tick = std::chrono::high_resolution_clock::now();
        return t;
    }

    std::string ElapsedTime::to_string() const { return format_time_userfriendly(as<std::chrono::nanoseconds>()); }

    std::string ElapsedTimer::to_string() const { return elapsed().to_string(); }

    Optional<CTime> CTime::get_current_date_time()
    {
        CTime ret;

#if defined(_WIN32)
        struct _timeb timebuffer;

        _ftime_s(&timebuffer);

        const errno_t err = gmtime_s(&ret.m_tm, &timebuffer.time);

        if (err)
        {
            return nullopt;
        }
#else
        time_t now = {0};
        time(&now);
        auto null_if_failed = gmtime_r(&now, &ret.m_tm);
        if (null_if_failed == nullptr)
        {
            return nullopt;
        }
#endif

        return ret;
    }

    Optional<CTime> CTime::parse(CStringView str)
    {
        CTime ret;
        auto assigned = sscanf_s(str.c_str(),
                                 "%d-%d-%dT%d:%d:%d.",
                                 &ret.m_tm.tm_year,
                                 &ret.m_tm.tm_mon,
                                 &ret.m_tm.tm_mday,
                                 &ret.m_tm.tm_hour,
                                 &ret.m_tm.tm_min,
                                 &ret.m_tm.tm_sec);
        if (assigned != 6) return nullopt;
        if (ret.m_tm.tm_year < 1900) return nullopt;
        ret.m_tm.tm_year -= 1900;
        if (ret.m_tm.tm_mon < 1) return nullopt;
        ret.m_tm.tm_mon -= 1;
        mktime(&ret.m_tm);
        return ret;
    }

    std::string CTime::to_string() const
    {
        std::array<char, 80> date;
        date.fill(0);

        strftime(&date[0], date.size(), "%Y-%m-%dT%H:%M:%S.0Z", &m_tm);
        return &date[0];
    }
    std::chrono::system_clock::time_point CTime::to_time_point() const
    {
        auto t = mktime(&m_tm);
        return std::chrono::system_clock::from_time_t(t);
    }
}
