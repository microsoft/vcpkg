#include "pch.h"

#include <vcpkg/metrics.h>

#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>

#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")

namespace vcpkg::Metrics
{
    Util::LockGuarded<Metrics> g_metrics;

    static std::string get_current_date_time()
    {
        struct tm newtime;
        std::array<char, 80> date;
        date.fill(0);

#if defined(_WIN32)
        struct _timeb timebuffer;

        _ftime_s(&timebuffer);
        time_t now = timebuffer.time;
        const int milli = timebuffer.millitm;

        const errno_t err = gmtime_s(&newtime, &now);

        if (err)
        {
            return "";
        }
#else
        time_t now;
        time(&now);
        gmtime_r(&now, &newtime);
        const int milli = 0;
#endif

        strftime(&date[0], date.size(), "%Y-%m-%dT%H:%M:%S", &newtime);
        return std::string(&date[0]) + "." + std::to_string(milli) + "Z";
    }

    static std::string generate_random_UUID()
    {
        int part_sizes[] = {8, 4, 4, 4, 12};
        char uuid[37];
        memset(uuid, 0, sizeof(uuid));
        int num;
        srand(static_cast<int>(time(nullptr)));
        int index = 0;
        for (int part = 0; part < 5; part++)
        {
            if (part > 0)
            {
                uuid[index] = '-';
                index++;
            }

            // Generating UUID format version 4
            // http://en.wikipedia.org/wiki/Universally_unique_identifier
            for (int i = 0; i < part_sizes[part]; i++, index++)
            {
                if (part == 2 && i == 0)
                {
                    num = 4;
                }
                else if (part == 4 && i == 0)
                {
                    num = (rand() % 4) + 8;
                }
                else
                {
                    num = rand() % 16;
                }

                if (num < 10)
                {
                    uuid[index] = static_cast<char>('0' + num);
                }
                else
                {
                    uuid[index] = static_cast<char>('a' + (num - 10));
                }
            }
        }

        return uuid;
    }

    static const std::string& get_session_id()
    {
        static const std::string ID = generate_random_UUID();
        return ID;
    }

    static std::string to_json_string(const std::string& str)
    {
        std::string encoded = "\"";
        for (auto&& ch : str)
        {
            if (ch == '\\')
            {
                encoded.append("\\\\");
            }
            else if (ch == '"')
            {
                encoded.append("\\\"");
            }
            else if (ch < 0x20 || ch >= 0x80)
            {
                // Note: this treats incoming Strings as Latin-1
                static constexpr const char HEX[16] = {
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
                encoded.append("\\u00");
                encoded.push_back(HEX[ch / 16]);
                encoded.push_back(HEX[ch % 16]);
            }
            else
            {
                encoded.push_back(ch);
            }
        }
        encoded.push_back('"');
        return encoded;
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
        std::string properties;
        std::string measurements;

        void track_property(const std::string& name, const std::string& value)
        {
            if (properties.size() != 0) properties.push_back(',');
            properties.append(to_json_string(name));
            properties.push_back(':');
            properties.append(to_json_string(value));
        }

        void track_metric(const std::string& name, double value)
        {
            if (measurements.size() != 0) measurements.push_back(',');
            measurements.append(to_json_string(name));
            measurements.push_back(':');
            measurements.append(std::to_string(value));
        }

        std::string format_event_data_template() const
        {
            const std::string& session_id = get_session_id();
            return Strings::format(R"([{
    "ver": 1,
    "name": "Microsoft.ApplicationInsights.Event",
    "time": "%s",
    "sampleRate": 100.000000,
    "seq": "0:0",
    "iKey": "b4e88960-4393-4dd9-ab8e-97e8fe6d7603",
    "flags": 0.000000,
    "tags": {
        "ai.device.os": "Windows",
        "ai.device.osVersion": "%s",
        "ai.session.id": "%s",
        "ai.user.id": "%s",
        "ai.user.accountAcquisitionDate": "%s"
    },
    "data": {
        "baseType": "EventData",
        "baseData": {
            "ver": 2,
            "name": "commandline_test7",
            "properties": { %s },
            "measurements": { %s }
        }
    }
}])",
                                   timestamp,
                                   get_os_version_string(),
                                   session_id,
                                   user_id,
                                   user_timestamp,
                                   properties,
                                   measurements);
        }
    };

    static MetricMessage g_metricmessage;
    static bool g_should_send_metrics =
#if defined(NDEBUG) && (DISABLE_METRICS == 0)
        true
#else
        false
#endif
        ;
    static bool g_should_print_metrics = false;

    bool get_compiled_metrics_enabled() { return DISABLE_METRICS == 0; }

    static fs::path get_vcpkg_root()
    {
        return Files::get_real_filesystem().find_file_recursively_up(
            fs::stdfs::absolute(System::get_exe_path_of_current_process()), ".vcpkg-root");
    }

    std::string get_MAC_user()
    {
#if defined(_WIN32)
        auto getmac = System::cmd_execute_and_capture_output("getmac");

        if (getmac.exit_code != 0) return "0";

        std::regex mac_regex("([a-fA-F0-9]{2}(-[a-fA-F0-9]{2}){5})");
        std::sregex_iterator next(getmac.output.begin(), getmac.output.end(), mac_regex);
        std::sregex_iterator last;

        while (next != last)
        {
            auto match = *next;
            if (match[0] != "00-00-00-00-00-00")
            {
                const std::string matchstr = match[0];
                const System::PowershellParameter value("Value", matchstr);
                auto hash_result = System::powershell_execute_and_capture_output(
                    "SHA256Hash", get_vcpkg_root() / "scripts" / "SHA256Hash.ps1", {value});
                Util::erase_remove_if(hash_result,
                                      [](char ch) { return !(ch >= 'A' && ch <= 'F') && !(ch >= '0' && ch <= '9'); });
                hash_result = Strings::ascii_to_lowercase(hash_result);
                return hash_result;
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

    void Metrics::track_metric(const std::string& name, double value) { g_metricmessage.track_metric(name, value); }

    void Metrics::track_property(const std::string& name, const std::string& value)
    {
        g_metricmessage.track_property(name, value);
    }

    void Metrics::upload(const std::string& payload)
    {
#if defined(_WIN32)
        HINTERNET connect = nullptr, request = nullptr;
        BOOL results = FALSE;

        const HINTERNET session = WinHttpOpen(
            L"vcpkg/1.0", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
        if (session) connect = WinHttpConnect(session, L"dc.services.visualstudio.com", INTERNET_DEFAULT_HTTPS_PORT, 0);

        if (connect)
            request = WinHttpOpenRequest(connect,
                                         L"POST",
                                         L"/v2/track",
                                         nullptr,
                                         WINHTTP_NO_REFERER,
                                         WINHTTP_DEFAULT_ACCEPT_TYPES,
                                         WINHTTP_FLAG_SECURE);

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

    void Metrics::flush()
    {
#if defined(_WIN32)
        const std::string payload = g_metricmessage.format_event_data_template();
        if (g_should_print_metrics) std::cerr << payload << "\n";
        if (!g_should_send_metrics) return;

        // upload(payload);

        wchar_t temp_folder[MAX_PATH];
        GetTempPathW(MAX_PATH, temp_folder);

        const fs::path temp_folder_path = temp_folder;
        const fs::path temp_folder_path_exe = temp_folder_path / "vcpkgmetricsuploader.exe";

        auto& fs = Files::get_real_filesystem();

        if (true)
        {
            const fs::path exe_path = [&fs]() -> fs::path {
                auto vcpkgdir = System::get_exe_path_of_current_process().parent_path();
                auto path = vcpkgdir / "vcpkgmetricsuploader.exe";
                if (fs.exists(path)) return path;

                path = vcpkgdir / "scripts" / "vcpkgmetricsuploader.exe";
                if (fs.exists(path)) return path;

                return "";
            }();

            std::error_code ec;
            fs.copy_file(exe_path, temp_folder_path_exe, fs::copy_options::skip_existing, ec);
            if (ec) return;
        }

        const fs::path vcpkg_metrics_txt_path = temp_folder_path / ("vcpkg" + generate_random_UUID() + ".txt");
        fs.write_contents(vcpkg_metrics_txt_path, payload);

        const std::string cmd_line =
            Strings::format("start %s %s", temp_folder_path_exe.u8string(), vcpkg_metrics_txt_path.u8string());
        System::cmd_execute_clean(cmd_line);
#endif
    }
}
