#include <vcpkg/base/checks.h>
#include <vcpkg/base/chrono.h>

namespace vcpkg::Chrono
{
    static std::time_t get_current_time_as_time_since_epoch()
    {
        using std::chrono::system_clock;
        return system_clock::to_time_t(system_clock::now());
    }

    static std::time_t utc_mktime(tm* time_ptr)
    {
#if defined(_WIN32)
        return _mkgmtime(time_ptr);
#else
        return timegm(time_ptr);
#endif
    }

    static tm to_local_time(const std::time_t& t)
    {
        tm parts{};
#if defined(_WIN32)
        localtime_s(&parts, &t);
#else
        parts = *localtime(&t);
#endif
        return parts;
    }

    static Optional<tm> to_utc_time(const std::time_t& t)
    {
        tm parts{};
#if defined(_WIN32)
        const errno_t err = gmtime_s(&parts, &t);
        if (err)
        {
            return nullopt;
        }
#else
        auto null_if_failed = gmtime_r(&t, &parts);
        if (null_if_failed == nullptr)
        {
            return nullopt;
        }
#endif
        return parts;
    }

    static tm date_plus_hours(tm* date, const int hours)
    {
        using namespace std::chrono_literals;
        static constexpr std::chrono::seconds SECONDS_IN_ONE_HOUR =
            std::chrono::duration_cast<std::chrono::seconds>(1h);

        const std::time_t date_in_seconds = utc_mktime(date) + (hours * SECONDS_IN_ONE_HOUR.count());
        return to_utc_time(date_in_seconds).value_or_exit(VCPKG_LINE_INFO);
    }

    static std::string format_time_userfriendly(const std::chrono::nanoseconds& nanos)
    {
        using std::chrono::duration_cast;
        using std::chrono::hours;
        using std::chrono::microseconds;
        using std::chrono::milliseconds;
        using std::chrono::minutes;
        using std::chrono::nanoseconds;
        using std::chrono::seconds;

        const auto nanos_as_double = static_cast<double>(nanos.count());

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
    void ElapsedTime::to_string(std::string& into) const
    {
        into += format_time_userfriendly(as<std::chrono::nanoseconds>());
    }

    std::string ElapsedTimer::to_string() const { return elapsed().to_string(); }
    void ElapsedTimer::to_string(std::string& into) const { return elapsed().to_string(into); }

    Optional<CTime> CTime::get_current_date_time()
    {
        const std::time_t ct = get_current_time_as_time_since_epoch();
        const Optional<tm> opt = to_utc_time(ct);
        if (auto p_tm = opt.get())
        {
            return CTime{*p_tm};
        }

        return nullopt;
    }

    Optional<CTime> CTime::parse(CStringView str)
    {
        CTime ret;
        const auto assigned =
#if defined(_WIN32)
            sscanf_s
#else
            sscanf
#endif
            (str.c_str(),
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
        utc_mktime(&ret.m_tm);

        return ret;
    }

    CTime CTime::add_hours(const int hours) const { return CTime{date_plus_hours(&this->m_tm, hours)}; }

    std::string CTime::to_string() const
    {
        std::array<char, 80> date{};
        strftime(&date[0], date.size(), "%Y-%m-%dT%H:%M:%S.0Z", &m_tm);
        return &date[0];
    }
    std::chrono::system_clock::time_point CTime::to_time_point() const
    {
        const time_t t = utc_mktime(&m_tm);
        return std::chrono::system_clock::from_time_t(t);
    }

    tm get_current_date_time_local()
    {
        const std::time_t now_time = get_current_time_as_time_since_epoch();
        return Chrono::to_local_time(now_time);
    }
}
