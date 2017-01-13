#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands
{
    static void do_file_hash(fs::path const& path, std::wstring const& hashType)
    {
        auto cmd_line = Strings::wformat(LR"(CertUtil.exe -hashfile "%s" %s)",
                                         path.c_str(), hashType.c_str());
        auto ec_data = System::cmd_execute_and_capture_output(cmd_line);
        Checks::check_exit(ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

        std::string const& output = ec_data.output;

        auto start = output.find_first_of("\r\n");
        Checks::check_exit(start != std::string::npos, "Unexpected output format from command: %s", Strings::utf16_to_utf8(cmd_line));

        auto end = output.find_first_of("\r\n", start + 1);
        Checks::check_exit(end != std::string::npos, "Unexpected output format from command: %s", Strings::utf16_to_utf8(cmd_line));

        auto hash = output.substr(start, end - start);
        hash.erase(std::remove_if(hash.begin(), hash.end(), isspace), hash.end());
        System::println(hash);
    }

    void hash_command(const vcpkg_cmd_arguments& args)
    {
        static const std::string example = Strings::format(
            "The argument should be a file path\n%s", Commands::Helpers::create_example_string("hash boost_1_62_0.tar.bz2"));
        args.check_min_arg_count(1, example);
        args.check_max_arg_count(2, example);

        if (args.command_arguments.size() == 1)
        {
            do_file_hash(args.command_arguments[0], L"SHA512");
        }
        if (args.command_arguments.size() == 2)
        {
            do_file_hash(args.command_arguments[0], Strings::utf8_to_utf16(args.command_arguments[1]));
        }

        exit(EXIT_SUCCESS);
    }
}
