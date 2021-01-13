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

static void write_message(const HANDLE hStdOut, const wchar_t* msg)
{
    size_t wcharsToWrite = wide_length(msg);
    if (wcharsToWrite == 0)
    {
        return;
    }

    if (wcharsToWrite > 65535)
    {
        win32_abort();
    }

    if (WriteConsoleW(hStdOut, msg, wcharsToWrite, 0, 0))
    {
        return;
    }

    // this happens if output has been redirected
    int narrowChars = WideCharToMultiByte(CP_ACP, 0, msg, (int)wcharsToWrite, 0, 0, 0, 0);
    if (narrowChars == 0)
    {
        win32_abort();
    }

    char* narrowBuffer = HeapAlloc(GetProcessHeap(), 0, (size_t)narrowChars);
    if (WideCharToMultiByte(CP_ACP, 0, msg, (int)wcharsToWrite, narrowBuffer, narrowChars, 0, 0) == 0)
    {
        win32_abort();
    }

    while (narrowChars != 0)
    {
        DWORD charsWritten;
        if (!WriteFile(hStdOut, narrowBuffer, (DWORD)narrowChars, &charsWritten, 0))
        {
            win32_abort();
        }

        narrowChars -= (int)charsWritten;
    }

    if (!HeapFree(GetProcessHeap(), 0, narrowBuffer))
    {
        win32_abort();
    }
}

static void write_number(const HANDLE hStdOut, DWORD number)
{
    wchar_t buffer[11]; // 4294967295\0
    wchar_t* firstDigit = buffer + 11;
    *--firstDigit = L'\0';
    if (number == 0)
    {
        *--firstDigit = L'0';
    }
    else
    {
        do
        {
            *--firstDigit = L'0' + number % 10;
            number /= 10;
        } while (number != 0);
    }

    write_message(hStdOut, firstDigit);
}

static void write_hex(const HANDLE hStdOut, DWORD number)
{
    wchar_t buffer[] = L"0x00000000";
    wchar_t* firstDigit = buffer + (sizeof(buffer) / sizeof(wchar_t)) - 1;
    while (number != 0)
    {
        *--firstDigit = L"0123456789ABCDEF"[number % 16];
        number /= 16;
    }

    write_message(hStdOut, buffer);
}

static void __declspec(noreturn) abort_api_failure(const HANDLE hStdOut, const wchar_t* api_name)
{
    DWORD lastError = GetLastError();
    write_message(hStdOut, L"While calling Windows API function ");
    write_message(hStdOut, api_name);
    write_message(hStdOut, L" got error ");
    write_hex(hStdOut, lastError);
    write_message(hStdOut, L":\r\n");
    wchar_t* message;
    if (FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_ALLOCATE_BUFFER,
                       GetModuleHandleW(L"winhttp.dll"),
                       lastError,
                       0,
                       (LPWSTR)&message,
                       0,
                       0))
    {
        write_message(hStdOut, message);
        // intentionally leaks the message buffer
    }
    else
    {
        lastError = GetLastError();
        write_message(hStdOut, L"(unknown error, FormatMessageW failed with ");
        write_hex(hStdOut, lastError);
        write_message(hStdOut, L")");
    }

    write_message(hStdOut, L"\r\n");
    FlushFileBuffers(hStdOut);
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

    const HANDLE stdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (stdOut == INVALID_HANDLE_VALUE)
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
        write_message(stdOut, L"Usage: tls12-download.exe DOMAIN RELATIVE-PATH OUT-FILE\r\n");
        return 1;
    }

    const wchar_t* const domain = argv[1];
    const wchar_t* const relative_path = argv[2];
    const wchar_t* const out_file_path = argv[3];
    write_message(stdOut, L"Downloading https://");
    write_message(stdOut, domain);
    write_message(stdOut, relative_path);
    write_message(stdOut, L" -> ");
    write_message(stdOut, out_file_path);

    wchar_t https_proxy_env[32767];
    DWORD dwAccessType;
    const wchar_t* pszProxyW;
    const wchar_t* pszProxyBypassW;
    if (GetEnvironmentVariableW(L"HTTPS_PROXY", https_proxy_env, sizeof(https_proxy_env) / sizeof(wchar_t)))
    {
        dwAccessType = WINHTTP_ACCESS_TYPE_NAMED_PROXY;
        pszProxyW = https_proxy_env;
        pszProxyBypassW = L"<local>";
        write_message(stdOut, L" (using proxy: ");
        write_message(stdOut, pszProxyW);
        write_message(stdOut, L")");
    }
    else if (GetLastError() == ERROR_ENVVAR_NOT_FOUND)
    {
        dwAccessType = WINHTTP_ACCESS_TYPE_NO_PROXY;
        pszProxyW = WINHTTP_NO_PROXY_NAME;
        pszProxyBypassW = WINHTTP_NO_PROXY_BYPASS;
    }
    else
    {
        abort_api_failure(stdOut, L"GetEnvironmentVariableW");
    }

    write_message(stdOut, L"\r\n");

    const HANDLE outFile = CreateFileW(out_file_path, FILE_WRITE_DATA, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if (outFile == INVALID_HANDLE_VALUE)
    {
        abort_api_failure(stdOut, L"CreateFileW");
    }

    BOOL results = FALSE;
    const HINTERNET session = WinHttpOpen(L"tls12-download/1.0", dwAccessType, pszProxyW, pszProxyBypassW, 0);
    if (!session)
    {
        abort_api_failure(stdOut, L"WinHttpOpen");
    }

    unsigned long secure_protocols = WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2;
    if (!WinHttpSetOption(session, WINHTTP_OPTION_SECURE_PROTOCOLS, &secure_protocols, sizeof(DWORD)))
    {
        abort_api_failure(stdOut, L"WinHttpSetOption");
    }

    const HINTERNET connect = WinHttpConnect(session, domain, INTERNET_DEFAULT_HTTPS_PORT, 0);
    if (!connect)
    {
        abort_api_failure(stdOut, L"WinHttpConnect");
    }

    const HINTERNET request = WinHttpOpenRequest(
        connect, L"GET", relative_path, 0, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE);
    if (!request)
    {
        abort_api_failure(stdOut, L"WinHttpOpenRequest");
    }

    if (!WinHttpSendRequest(request, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0))
    {
        abort_api_failure(stdOut, L"WinHttpSendRequest");
    }

    if (!WinHttpReceiveResponse(request, 0))
    {
        abort_api_failure(stdOut, L"WinHttpReceiveResponse");
    }

    DWORD httpCode = 0;
    DWORD unused = sizeof(httpCode);

    if (!WinHttpQueryHeaders(request,
                             WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                             WINHTTP_HEADER_NAME_BY_INDEX,
                             &httpCode,
                             &unused,
                             WINHTTP_NO_HEADER_INDEX))
    {
        abort_api_failure(stdOut, L"WinHttpQueryHeaders");
    }

    if (httpCode != 200)
    {
        write_message(stdOut, L"Download failed, server returned HTTP status: ");
        write_number(stdOut, httpCode);
        write_message(stdOut, L"\r\n");
        FlushFileBuffers(stdOut);
        TerminateProcess(GetCurrentProcess(), 2);
    }

    char buffer[32768];
    for (;;)
    {
        DWORD receivedBytes;
        if (!WinHttpReadData(request, buffer, sizeof(buffer), &receivedBytes))
        {
            abort_api_failure(stdOut, L"WinHttpReadData");
        }

        if (receivedBytes == 0)
        {
            break; // end of response
        }

        do
        {
            DWORD writtenBytes;
            if (!WriteFile(outFile, buffer, receivedBytes, &writtenBytes, 0))
            {
                abort_api_failure(stdOut, L"WriteFile");
            }

            receivedBytes -= writtenBytes;
        } while (receivedBytes != 0);
    }

    WinHttpCloseHandle(request);
    WinHttpCloseHandle(connect);
    WinHttpCloseHandle(session);
    CloseHandle(outFile);

    write_message(stdOut, L"Done.\r\n");
    FlushFileBuffers(stdOut);
    TerminateProcess(GetCurrentProcess(), 0);
    return 0;
}
