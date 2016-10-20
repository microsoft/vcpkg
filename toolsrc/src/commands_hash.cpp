#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include <algorithm>

namespace vcpkg
{
    void hash_command(const vcpkg_cmd_arguments& args)
    {
        if (args.command_arguments.size() != 1)
        {
            System::println(System::color::error, "Error: %s requires 1 parameter", args.command);
            print_example(Strings::format(R"(%s C:\path\to\file)", args.command).c_str());
            exit(EXIT_FAILURE);
        }

        const std::string& path = args.command_arguments.at(0);
        const std::wstring cmd_line = Strings::wformat(LR"(certutil.exe -hashfile "%s" SHA512)",
                                                       Strings::utf8_to_utf16(path));

        auto ec_data = System::cmd_execute_and_capture_output(cmd_line);
        Checks::check_exit(ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

        const std::string& output = ec_data.output;
        const std::string leading_text = Strings::format("SHA512 hash of file %s:", path);
        const std::string trailing_text = "CertUtil: -hashfile command completed successfully.";
        auto start = output.find(leading_text) + leading_text.size();
        Checks::check_exit(start != std::string::npos, "Unexpected output format from command: %s", Strings::utf16_to_utf8(cmd_line));
        auto end = output.find(trailing_text);
        Checks::check_exit(end != std::string::npos, "Unexpected output format from command: %s", Strings::utf16_to_utf8(cmd_line));
        std::string hash = output.substr(start, end - start);
        hash.erase(std::remove_if(hash.begin(), hash.end(), isspace), hash.end());

        System::println("");
        System::println(hash.c_str());
        System::println("");
    }
}
