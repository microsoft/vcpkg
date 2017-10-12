#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Util.h"

namespace vcpkg::Commands::Hash
{
    static void do_file_hash(fs::path const& path, std::wstring const& hash_type)
    {
        const auto cmd_line = Strings::wformat(LR"(CertUtil.exe -hashfile "%s" %s)", path.c_str(), hash_type);
        const auto ec_data = System::cmd_execute_and_capture_output(cmd_line);
        Checks::check_exit(
            VCPKG_LINE_INFO, ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::to_utf8(cmd_line));

        std::string const& output = ec_data.output;

        const auto start = output.find_first_of("\r\n");
        Checks::check_exit(VCPKG_LINE_INFO,
                           start != std::string::npos,
                           "Unexpected output format from command: %s",
                           Strings::to_utf8(cmd_line));

        const auto end = output.find_first_of("\r\n", start + 1);
        Checks::check_exit(VCPKG_LINE_INFO,
                           end != std::string::npos,
                           "Unexpected output format from command: %s",
                           Strings::to_utf8(cmd_line));

        auto hash = output.substr(start, end - start);
        Util::erase_remove_if(hash, isspace);
        System::println(hash);
    }

    void perform_and_exit(const VcpkgCmdArguments& args)
    {
        static const std::string EXAMPLE =
            Strings::format("The argument should be a file path\n%s",
                            Commands::Help::create_example_string("hash boost_1_62_0.tar.bz2"));
        args.check_min_arg_count(1, EXAMPLE);
        args.check_max_arg_count(2, EXAMPLE);
        args.check_and_get_optional_command_arguments({});

        if (args.command_arguments.size() == 1)
        {
            do_file_hash(args.command_arguments[0], L"SHA512");
        }
        if (args.command_arguments.size() == 2)
        {
            do_file_hash(args.command_arguments[0], Strings::to_utf16(args.command_arguments[1]));
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
