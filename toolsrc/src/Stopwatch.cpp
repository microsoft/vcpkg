#include "pch.h"
#include "Stopwatch.h"
#include "vcpkg_Checks.h"

namespace vcpkg
{
    static std::string format_time_userfriendly(const std::chrono::nanoseconds& nanos)
    {
        using std::chrono::hours;
        using std::chrono::minutes;
        using std::chrono::seconds;
        using std::chrono::milliseconds;
        using std::chrono::microseconds;
        using std::chrono::nanoseconds;
        using std::chrono::duration_cast;

        const double nanos_as_double = static_cast<double>(nanos.count());

        if (duration_cast<hours>(nanos) > hours())
        {
            auto t = nanos_as_double / duration_cast<nanoseconds>(hours(1)).count();
            return Strings::format("%.4g h", t);
        }

        if (duration_cast<minutes>(nanos) > minutes())
        {
            auto t = nanos_as_double / duration_cast<nanoseconds>(minutes(1)).count();
            return Strings::format("%.4g min", t);
        }

        if (duration_cast<seconds>(nanos) > seconds())
        {
            auto t = nanos_as_double / duration_cast<nanoseconds>(seconds(1)).count();
            return Strings::format("%.4g s", t);
        }

        if (duration_cast<milliseconds>(nanos) > milliseconds())
        {
            auto t = nanos_as_double / duration_cast<nanoseconds>(milliseconds(1)).count();
            return Strings::format("%.4g ms", t);
        }

        if (duration_cast<microseconds>(nanos) > microseconds())
        {
            auto t = nanos_as_double / duration_cast<nanoseconds>(microseconds(1)).count();
            return Strings::format("%.4g us", t);
        }

        return Strings::format("%.4g ns", nanos_as_double);
    }

    ElapsedTime ElapsedTime::createStarted()
    {
        ElapsedTime t;
        t.m_startTick = std::chrono::high_resolution_clock::now();
        return t;
    }

    std::string ElapsedTime::toString() const
    {
        return format_time_userfriendly(elapsed<std::chrono::nanoseconds>());
    }

    Stopwatch Stopwatch::createUnstarted()
    {
        return Stopwatch();
    }

    Stopwatch Stopwatch::createStarted()
    {
        return Stopwatch().start();
    }

    bool Stopwatch::isRunning() const
    {
        return this->m_isRunning;
    }

    const Stopwatch& Stopwatch::start()
    {
        Checks::check_exit(!this->m_isRunning, "This stopwatch is already running.");
        this->m_isRunning = true;
        this->m_startTick = std::chrono::high_resolution_clock::now();
        return *this;
    }

    const Stopwatch& Stopwatch::stop()
    {
        auto tick = std::chrono::high_resolution_clock::now();
        Checks::check_exit(this->m_isRunning, "This stopwatch is already stopped.");
        this->m_isRunning = false;
        this->m_elapsedNanos += tick - this->m_startTick;
        return *this;
    }

    Stopwatch& Stopwatch::reset()
    {
        this->m_elapsedNanos = std::chrono::nanoseconds();
        this->m_isRunning = false;
        return *this;
    }

    std::string Stopwatch::toString() const
    {
        return format_time_userfriendly(this->elapsedNanos());
    }

    Stopwatch::Stopwatch() : m_isRunning(false), m_elapsedNanos(0), m_startTick() { }

    std::chrono::nanoseconds Stopwatch::elapsedNanos() const
    {
        if (this->m_isRunning)
        {
            return std::chrono::high_resolution_clock::now() - this->m_startTick + this->m_elapsedNanos;
        }

        return this->m_elapsedNanos;
    }
}
