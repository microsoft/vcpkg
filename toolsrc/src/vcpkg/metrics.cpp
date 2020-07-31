#include "pch.h"

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/commands.h>
#include <vcpkg/commands.version.h>
#include <vcpkg/metrics.h>

#if defined(_WIN32)
#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")
#endif

namespace vcpkg::Metrics
{
    Util::LockGuarded<Metrics> g_metrics;

    static std::string get_current_date_time()
    {
        auto maybe_time = Chrono::CTime::get_current_date_time();
        if (auto ptime = maybe_time.get())
        {
            return ptime->to_string();
        }

        return "";
    }

    struct append_hexits
    {
        constexpr static char hex[17] = "0123456789abcdef";
        void operator()(std::string& res, std::uint8_t bits) const
        {
            res.push_back(hex[(bits >> 4) & 0x0F]);
            res.push_back(hex[(bits >> 0) & 0x0F]);
        }
    };

    // note: this ignores the bits of these numbers that would be where format and variant go
    static std::string uuid_of_integers(uint64_t top, uint64_t bottom)
    {
        // uuid_field_size in bytes, not hex characters
        constexpr size_t uuid_top_field_size[] = {4, 2, 2};
        constexpr size_t uuid_bottom_field_size[] = {2, 6};

        // uuid_field_size in hex characters, not bytes
        constexpr size_t uuid_size = 8 + 1 + 4 + 1 + 4 + 1 + 4 + 1 + 12;

        constexpr static append_hexits write_byte;

        // set the version bits to 4
        top &= 0xFFFF'FFFF'FFFF'0FFFULL;
        top |= 0x0000'0000'0000'4000ULL;

        // set the variant bits to 2 (variant one)
        bottom &= 0x3FFF'FFFF'FFFF'FFFFULL;
        bottom |= 0x8000'0000'0000'0000ULL;

        std::string res;
        res.reserve(uuid_size);

        bool first = true;
        size_t start_byte = 0;
        for (auto field_size : uuid_top_field_size)
        {
            if (!first)
            {
                res.push_back('-');
            }
            first = false;
            for (size_t i = start_byte; i < start_byte + field_size; ++i)
            {
                auto shift = 64 - (i + 1) * 8;
                write_byte(res, (top >> shift) & 0xFF);
            }
            start_byte += field_size;
        }

        start_byte = 0;
        for (auto field_size : uuid_bottom_field_size)
        {
            res.push_back('-');
            for (size_t i = start_byte; i < start_byte + field_size; ++i)
            {
                auto shift = 64 - (i + 1) * 8;
                write_byte(res, (bottom >> shift) & 0xFF);
            }
            start_byte += field_size;
        }

        return res;
    }

    // UUID format version 4, variant 1
    // http://en.wikipedia.org/wiki/Universally_unique_identifier
    // [0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}
    static std::string generate_random_UUID()
    {
        std::random_device rnd{};
        std::uniform_int_distribution<std::uint64_t> uid{};
        return uuid_of_integers(uid(rnd), uid(rnd));
    }

    static const std::string& get_session_id()
    {
        static const std::string ID = generate_random_UUID();
        return ID;
    }

    static std::string get_os_version_string()
    {
#if defined(_WIN32)
        std::wstring path;
        path.resize(MAX_PATH);
        const auto n = GetSystemDirectoryW(&path[0], static_cast<UINT>(path.size()));
        path.resize(n);
        path += L"\\kernel32.dll";

        const auto versz = GetFileVersionInfoSizeW(path.c_str(), nullptr);
        if (versz == 0) return "";

        std::vector<char> verbuf;
        verbuf.resize(versz);

        if (!GetFileVersionInfoW(path.c_str(), 0, static_cast<DWORD>(verbuf.size()), &verbuf[0])) return "";

        void* rootblock;
        UINT rootblocksize;
        if (!VerQueryValueW(&verbuf[0], L"\\", &rootblock, &rootblocksize)) return "";

        auto rootblock_ffi = static_cast<VS_FIXEDFILEINFO*>(rootblock);

        return Strings::format("%d.%d.%d",
                               static_cast<int>(HIWORD(rootblock_ffi->dwProductVersionMS)),
                               static_cast<int>(LOWORD(rootblock_ffi->dwProductVersionMS)),
                               static_cast<int>(HIWORD(rootblock_ffi->dwProductVersionLS)));
#else
        return "unknown";
#endif
    }

    struct MetricMessage
    {
        std::string user_id = generate_random_UUID();
        std::string user_timestamp;
        std::string timestamp = get_current_date_time();

        Json::Object properties;
        Json::Object measurements;

        Json::Array buildtime_names;
        Json::Array buildtime_times;

        Json::Object feature_flags;

        void track_property(const std::string& name, const std::string& value)
        {
            properties.insert_or_replace(name, Json::Value::string(value));
        }

        void track_metric(const std::string& name, double value)
        {
            measurements.insert_or_replace(name, Json::Value::number(value));
        }

        void track_buildtime(const std::string& name, double value)
        {
            buildtime_names.push_back(Json::Value::string(name));
            buildtime_times.push_back(Json::Value::number(value));
        }
        void track_feature(const std::string& name, bool value)
        {
            feature_flags.insert(name, Json::Value::boolean(value));
        }

        std::string format_event_data_template() const
        {
            auto props_plus_buildtimes = properties;
            if (buildtime_names.size() > 0)
            {
                props_plus_buildtimes.insert("buildnames_1", buildtime_names);
                props_plus_buildtimes.insert("buildtimes", buildtime_times);
            }

            Json::Array arr = Json::Array();
            Json::Object& obj = arr.push_back(Json::Object());

            obj.insert("ver", Json::Value::integer(1));
            obj.insert("name", Json::Value::string("Microsoft.ApplicationInsights.Event"));
            obj.insert("time", Json::Value::string(timestamp));
            obj.insert("sampleRate", Json::Value::number(100.0));
            obj.insert("seq", Json::Value::string("0:0"));
            obj.insert("iKey", Json::Value::string("b4e88960-4393-4dd9-ab8e-97e8fe6d7603"));
            obj.insert("flags", Json::Value::integer(0));

            {
                Json::Object& tags = obj.insert("tags", Json::Object());

                tags.insert("ai.device.os", Json::Value::string("Other"));

                const char* os_name =
#if defined(_WIN32)
                    "Windows";
#elif defined(__APPLE__)
                    "OSX";
#elif defined(__linux__)
                    "Linux";
#elif defined(__FreeBSD__)
                    "FreeBSD";
#elif defined(__unix__)
                    "Unix";
#else
                    "Other";
#endif

                tags.insert("ai.device.osVersion",
                            Json::Value::string(Strings::format("%s-%s", os_name, get_os_version_string())));
                tags.insert("ai.session.id", Json::Value::string(get_session_id()));
                tags.insert("ai.user.id", Json::Value::string(user_id));
                tags.insert("ai.user.accountAcquisitionDate", Json::Value::string(user_timestamp));
            }

            {
                Json::Object& data = obj.insert("data", Json::Object());

                data.insert("baseType", Json::Value::string("EventData"));
                Json::Object& base_data = data.insert("baseData", Json::Object());

                base_data.insert("ver", Json::Value::integer(2));
                base_data.insert("name", Json::Value::string("commandline_test7"));
                base_data.insert("properties", std::move(props_plus_buildtimes));
                base_data.insert("measurements", measurements);
                base_data.insert("feature-flags", feature_flags);
            }

            return Json::stringify(arr, vcpkg::Json::JsonStyle());
        }
    };

    static MetricMessage g_metricmessage;
    static bool g_should_send_metrics =
#if defined(NDEBUG) && (VCPKG_DISABLE_METRICS == 0)
        true
#else
        false
#endif
        ;
    static bool g_should_print_metrics = false;
    static bool g_metrics_disabled =
#if VCPKG_DISABLE_METRICS
        true
#else
        false
#endif
        ;

    // for child vcpkg processes, we also want to disable metrics
    static void set_vcpkg_disable_metrics_environment_variable(bool disabled)
    {
#if defined(_WIN32)
        SetEnvironmentVariableW(L"VCPKG_DISABLE_METRICS", disabled ? L"1" : nullptr);
#else
        if (disabled)
        {
            setenv("VCPKG_DISABLE_METRICS", "1", true);
        }
        else
        {
            unsetenv("VCPKG_DISABLE_METRICS");
        }
#endif
    }

    std::string get_MAC_user()
    {
#if defined(_WIN32)
        if (!g_metrics.lock()->metrics_enabled())
        {
            return "{}";
        }

        auto getmac = System::cmd_execute_and_capture_output("getmac");

        if (getmac.exit_code != 0) return "0";

        std::regex mac_regex("([a-fA-F0-9]{2}(-[a-fA-F0-9]{2}){5})");
        std::sregex_iterator next(getmac.output.begin(), getmac.output.end(), mac_regex);
        std::sregex_iterator last;

        while (next != last)
        {
            const auto match = *next;
            if (match[0] != "00-00-00-00-00-00")
            {
                return vcpkg::Hash::get_string_hash(match[0].str(), Hash::Algorithm::Sha256);
            }
            ++next;
        }

        return "0";
#else
        return "{}";
#endif
    }

    void Metrics::set_user_information(const std::string& user_id, const std::string& first_use_time)
    {
        g_metricmessage.user_id = user_id;
        g_metricmessage.user_timestamp = first_use_time;
    }

    void Metrics::init_user_information(std::string& user_id, std::string& first_use_time)
    {
        user_id = generate_random_UUID();
        first_use_time = get_current_date_time();
    }

    void Metrics::set_send_metrics(bool should_send_metrics) { g_should_send_metrics = should_send_metrics; }

    void Metrics::set_print_metrics(bool should_print_metrics) { g_should_print_metrics = should_print_metrics; }

    void Metrics::set_disabled(bool disabled)
    {
        set_vcpkg_disable_metrics_environment_variable(disabled);
        g_metrics_disabled = disabled;
    }

    bool Metrics::metrics_enabled()
    {
#if VCPKG_DISABLE_METRICS
        return false;
#else
        return !g_metrics_disabled;
#endif
    }

    void Metrics::track_metric(const std::string& name, double value)
    {
        if (!metrics_enabled())
        {
            return;
        }
        g_metricmessage.track_metric(name, value);
    }

    void Metrics::track_buildtime(const std::string& name, double value)
    {
        if (!metrics_enabled())
        {
            return;
        }
        g_metricmessage.track_buildtime(name, value);
    }

    void Metrics::track_property(const std::string& name, const std::string& value)
    {
        if (!metrics_enabled())
        {
            return;
        }
        g_metricmessage.track_property(name, value);
    }

    void Metrics::track_feature(const std::string& name, bool value)
    {
        if (!metrics_enabled())
        {
            return;
        }
        g_metricmessage.track_feature(name, value);
    }

    void Metrics::upload(const std::string& payload)
    {
        if (!metrics_enabled())
        {
            return;
        }

#if !defined(_WIN32)
        Util::unused(payload);
#else
        HINTERNET connect = nullptr, request = nullptr;
        BOOL results = FALSE;

        const HINTERNET session = WinHttpOpen(
            L"vcpkg/1.0", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);

        unsigned long secure_protocols = WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2;
        if (session && WinHttpSetOption(session, WINHTTP_OPTION_SECURE_PROTOCOLS, &secure_protocols, sizeof(DWORD)))
        {
            connect = WinHttpConnect(session, L"dc.services.visualstudio.com", INTERNET_DEFAULT_HTTPS_PORT, 0);
        }

        if (connect)
        {
            request = WinHttpOpenRequest(connect,
                                         L"POST",
                                         L"/v2/track",
                                         nullptr,
                                         WINHTTP_NO_REFERER,
                                         WINHTTP_DEFAULT_ACCEPT_TYPES,
                                         WINHTTP_FLAG_SECURE);
        }

        if (request)
        {
            if (MAXDWORD <= payload.size()) abort();
            std::wstring hdrs = L"Content-Type: application/json\r\n";
            std::string& p = const_cast<std::string&>(payload);
            results = WinHttpSendRequest(request,
                                         hdrs.c_str(),
                                         static_cast<DWORD>(hdrs.size()),
                                         static_cast<void*>(&p[0]),
                                         static_cast<DWORD>(payload.size()),
                                         static_cast<DWORD>(payload.size()),
                                         0);
        }

        if (results)
        {
            results = WinHttpReceiveResponse(request, nullptr);
        }

        DWORD http_code = 0, junk = sizeof(DWORD);

        if (results)
        {
            results = WinHttpQueryHeaders(request,
                                          WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                                          nullptr,
                                          &http_code,
                                          &junk,
                                          WINHTTP_NO_HEADER_INDEX);
        }

        std::vector<char> response_buffer;
        if (results)
        {
            DWORD available_data = 0, read_data = 0, total_data = 0;
            while ((results = WinHttpQueryDataAvailable(request, &available_data)) == TRUE && available_data > 0)
            {
                response_buffer.resize(response_buffer.size() + available_data);

                results = WinHttpReadData(request, &response_buffer.data()[total_data], available_data, &read_data);

                if (!results)
                {
                    break;
                }

                total_data += read_data;

                response_buffer.resize(total_data);
            }
        }

        if (!results)
        {
#ifndef NDEBUG
            __debugbreak();
            auto err = GetLastError();
            std::cerr << "[DEBUG] failed to connect to server: " << err << "\n";
#endif
        }

        if (request) WinHttpCloseHandle(request);
        if (connect) WinHttpCloseHandle(connect);
        if (session) WinHttpCloseHandle(session);
#endif
    }

    void Metrics::flush(Files::Filesystem& fs)
    {
        if (!metrics_enabled())
        {
            return;
        }

        const std::string payload = g_metricmessage.format_event_data_template();
        if (g_should_print_metrics) std::cerr << payload << "\n";
        if (!g_should_send_metrics) return;

#if defined(_WIN32)
        wchar_t temp_folder[MAX_PATH];
        GetTempPathW(MAX_PATH, temp_folder);

        const fs::path temp_folder_path = fs::path(temp_folder) / "vcpkg";
        const fs::path temp_folder_path_exe =
            temp_folder_path / Strings::format("vcpkgmetricsuploader-%s.exe", Commands::Version::base_version());
#endif

#if defined(_WIN32)

        const fs::path exe_path = [&fs]() -> fs::path {
            auto vcpkgdir = System::get_exe_path_of_current_process().parent_path();
            auto path = vcpkgdir / "vcpkgmetricsuploader.exe";
            if (fs.exists(path)) return path;

            path = vcpkgdir / "scripts" / "vcpkgmetricsuploader.exe";
            if (fs.exists(path)) return path;

            return "";
        }();

        std::error_code ec;
        fs.create_directories(temp_folder_path, ec);
        if (ec) return;
        fs.copy_file(exe_path, temp_folder_path_exe, fs::copy_options::skip_existing, ec);
        if (ec) return;
#else
        if (!fs.exists("/tmp")) return;
        const fs::path temp_folder_path = "/tmp/vcpkg";
        std::error_code ec;
        fs.create_directory(temp_folder_path, ec);
        // ignore error
        ec.clear();
#endif
        const fs::path vcpkg_metrics_txt_path = temp_folder_path / ("vcpkg" + generate_random_UUID() + ".txt");
        fs.write_contents(vcpkg_metrics_txt_path, payload, ec);
        if (ec) return;

#if defined(_WIN32)
        const std::string cmd_line = Strings::format("cmd /c \"start \"vcpkgmetricsuploader.exe\" \"%s\" \"%s\"\"",
                                                     temp_folder_path_exe.u8string(),
                                                     vcpkg_metrics_txt_path.u8string());
        System::cmd_execute_no_wait(cmd_line);
#else
        auto escaped_path = Strings::escape_string(vcpkg_metrics_txt_path.u8string(), '\'', '\\');
        const std::string cmd_line = Strings::format(
            R"((curl "https://dc.services.visualstudio.com/v2/track" -H "Content-Type: application/json" -X POST --tlsv1.2 --data '@%s' >/dev/null 2>&1; rm '%s') &)",
            escaped_path,
            escaped_path);
        System::cmd_execute_clean(cmd_line);
#endif
    }
}
