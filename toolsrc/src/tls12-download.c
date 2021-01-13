#include <Windows.h>
#include <process.h>
#include <winhttp.h>
/*
 * This program must be as small as possible, because it is committed in binary form to the
 * vcpkg github repo to enable downloading the main vcpkg program on Windows 7, where TLS 1.2 is
 * unavailable to PowerShell.
 * To that end it avoids using C runtime functions (beyond the vcruntime ones the compiler
 * injects itself).
 * (In testing as of 2021-01-07, this version that doesn't link with the CRT is ~8kb, whereas a
 * hello world program that does link with the CRT is ~300kb)
 */

static void __declspec(noreturn) win32_abort()
{
    /*
     * Note that TerminateProcess does not return when called from the terminated process, see
     * https://github.com/MicrosoftDocs/sdk-api/pull/626
     */
    TerminateProcess(GetCurrentProcess(), 3);
}

static size_t wide_length(const wchar_t* str)
{
    size_t answer = 0;
    while (*str)
    {
        ++answer;
        ++str;
    }
    return answer;
}

static void write_message(const HANDLE std_out, const wchar_t* msg)
{
    size_t wchars_to_write = wide_length(msg);
    if (wchars_to_write == 0)
    {
        return;
    }

    if (wchars_to_write > 65535)
    {
        win32_abort();
    }

    if (WriteConsoleW(std_out, msg, wchars_to_write, 0, 0))
    {
        return;
    }

    // this happens if output has been redirected
    int narrow_chars = WideCharToMultiByte(CP_ACP, 0, msg, (int)wchars_to_write, 0, 0, 0, 0);
    if (narrow_chars == 0)
    {
        win32_abort();
    }

    char* narrow_buffer = HeapAlloc(GetProcessHeap(), 0, (size_t)narrow_chars);
    if (WideCharToMultiByte(CP_ACP, 0, msg, (int)wchars_to_write, narrow_buffer, narrow_chars, 0, 0) == 0)
    {
        win32_abort();
    }

    while (narrow_chars != 0)
    {
        DWORD chars_written;
        if (!WriteFile(std_out, narrow_buffer, (DWORD)narrow_chars, &chars_written, 0))
        {
            win32_abort();
        }

        narrow_chars -= (int)chars_written;
    }

    if (!HeapFree(GetProcessHeap(), 0, narrow_buffer))
    {
        win32_abort();
    }
}

static void write_number(const HANDLE std_out, DWORD number)
{
    wchar_t buffer[11]; // 4294967295\0
    wchar_t* first_digit = buffer + 11;
    *--first_digit = L'\0';
    if (number == 0)
    {
        *--first_digit = L'0';
    }
    else
    {
        do
        {
            *--first_digit = L'0' + number % 10;
            number /= 10;
        } while (number != 0);
    }

    write_message(std_out, first_digit);
}

static void write_hex(const HANDLE std_out, DWORD number)
{
    wchar_t buffer[] = L"0x00000000";
    wchar_t* first_digit = buffer + (sizeof(buffer) / sizeof(wchar_t)) - 1;
    while (number != 0)
    {
        *--first_digit = L"0123456789ABCDEF"[number % 16];
        number /= 16;
    }

    write_message(std_out, buffer);
}

static void __declspec(noreturn) abort_api_failure(const HANDLE std_out, const wchar_t* api_name)
{
    DWORD last_error = GetLastError();
    write_message(std_out, L"While calling Windows API function ");
    write_message(std_out, api_name);
    write_message(std_out, L" got error ");
    write_hex(std_out, last_error);
    write_message(std_out, L":\r\n");
    wchar_t* message;
    if (FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_ALLOCATE_BUFFER,
                       GetModuleHandleW(L"winhttp.dll"),
                       last_error,
                       0,
                       (LPWSTR)&message,
                       0,
                       0))
    {
        write_message(std_out, message);
        // intentionally leaks the message buffer
    }
    else
    {
        last_error = GetLastError();
        write_message(std_out, L"(unknown error, FormatMessageW failed with ");
        write_hex(std_out, last_error);
        write_message(std_out, L")");
    }

    write_message(std_out, L"\r\n");
    FlushFileBuffers(std_out);
    win32_abort();
}

#ifndef NDEBUG
int main()
#else  // ^^^ debug // !debug vvv
int __stdcall entry()
#endif // ^^^ !debug
{
#ifdef NDEBUG
    __security_init_cookie();
#endif // ^^^ release

    const HANDLE std_out = GetStdHandle(STD_OUTPUT_HANDLE);
    if (std_out == INVALID_HANDLE_VALUE)
    {
        win32_abort();
    }

    int argc;
    wchar_t** argv = CommandLineToArgvW(GetCommandLineW(), &argc); // intentionally leaks argv
    if (argv == 0)
    {
        win32_abort();
    }

    if (argc != 4)
    {
        write_message(std_out, L"Usage: tls12-download.exe DOMAIN RELATIVE-PATH OUT-FILE\r\n");
        return 1;
    }

    const wchar_t* const domain = argv[1];
    const wchar_t* const relative_path = argv[2];
    const wchar_t* const out_file_path = argv[3];
    write_message(std_out, L"Downloading https://");
    write_message(std_out, domain);
    write_message(std_out, relative_path);
    write_message(std_out, L" -> ");
    write_message(std_out, out_file_path);

    wchar_t https_proxy_env[32767];
    DWORD access_type;
    const wchar_t* proxy_setting;
    const wchar_t* proxy_bypass_setting;
    if (GetEnvironmentVariableW(L"HTTPS_PROXY", https_proxy_env, sizeof(https_proxy_env) / sizeof(wchar_t)))
    {
        access_type = WINHTTP_ACCESS_TYPE_NAMED_PROXY;
        proxy_setting = https_proxy_env;
        proxy_bypass_setting = L"<local>";
        write_message(std_out, L" (using proxy: ");
        write_message(std_out, proxy_setting);
        write_message(std_out, L")");
    }
    else if (GetLastError() == ERROR_ENVVAR_NOT_FOUND)
    {
        access_type = WINHTTP_ACCESS_TYPE_NO_PROXY;
        proxy_setting = WINHTTP_NO_PROXY_NAME;
        proxy_bypass_setting = WINHTTP_NO_PROXY_BYPASS;
    }
    else
    {
        abort_api_failure(std_out, L"GetEnvironmentVariableW");
    }

    write_message(std_out, L"\r\n");

    const HANDLE out_file = CreateFileW(out_file_path, FILE_WRITE_DATA, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if (out_file == INVALID_HANDLE_VALUE)
    {
        abort_api_failure(std_out, L"CreateFileW");
    }

    BOOL results = FALSE;
    const HINTERNET session = WinHttpOpen(L"tls12-download/1.0", access_type, proxy_setting, proxy_bypass_setting, 0);
    if (!session)
    {
        abort_api_failure(std_out, L"WinHttpOpen");
    }

    unsigned long secure_protocols = WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2;
    if (!WinHttpSetOption(session, WINHTTP_OPTION_SECURE_PROTOCOLS, &secure_protocols, sizeof(DWORD)))
    {
        abort_api_failure(std_out, L"WinHttpSetOption");
    }

    const HINTERNET connect = WinHttpConnect(session, domain, INTERNET_DEFAULT_HTTPS_PORT, 0);
    if (!connect)
    {
        abort_api_failure(std_out, L"WinHttpConnect");
    }

    const HINTERNET request = WinHttpOpenRequest(
        connect, L"GET", relative_path, 0, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE);
    if (!request)
    {
        abort_api_failure(std_out, L"WinHttpOpenRequest");
    }

    if (!WinHttpSendRequest(request, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0))
    {
        abort_api_failure(std_out, L"WinHttpSendRequest");
    }

    if (!WinHttpReceiveResponse(request, 0))
    {
        abort_api_failure(std_out, L"WinHttpReceiveResponse");
    }

    DWORD http_code = 0;
    DWORD query_headers_buffer_size = sizeof(http_code);
    if (!WinHttpQueryHeaders(request,
                             WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                             WINHTTP_HEADER_NAME_BY_INDEX,
                             &http_code,
                             &query_headers_buffer_size,
                             WINHTTP_NO_HEADER_INDEX))
    {
        abort_api_failure(std_out, L"WinHttpQueryHeaders");
    }

    if (http_code != 200)
    {
        write_message(std_out, L"Download failed, server returned HTTP status: ");
        write_number(std_out, http_code);
        write_message(std_out, L"\r\n");
        FlushFileBuffers(std_out);
        TerminateProcess(GetCurrentProcess(), 2);
    }

    char buffer[32768];
    for (;;)
    {
        DWORD received_bytes;
        if (!WinHttpReadData(request, buffer, sizeof(buffer), &received_bytes))
        {
            abort_api_failure(std_out, L"WinHttpReadData");
        }

        if (received_bytes == 0)
        {
            break; // end of response
        }

        do
        {
            DWORD written_bytes;
            if (!WriteFile(out_file, buffer, received_bytes, &written_bytes, 0))
            {
                abort_api_failure(std_out, L"WriteFile");
            }

            received_bytes -= written_bytes;
        } while (received_bytes != 0);
    }

    WinHttpCloseHandle(request);
    WinHttpCloseHandle(connect);
    WinHttpCloseHandle(session);
    CloseHandle(out_file);

    write_message(std_out, L"Done.\r\n");
    FlushFileBuffers(std_out);
    TerminateProcess(GetCurrentProcess(), 0);
    return 0;
}
