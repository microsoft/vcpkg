#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"
#include <iostream>
#include <iomanip>
#include <Windows.h>

namespace fs = std::tr2::sys;

namespace vcpkg
{
	void file_hash_sha512(fs::path const & path, char const * hash)
	{
		auto cmd_line = Strings::format("Powershell -Command (Get-FileHash %s -Algorithm %s).Hash.ToLower()", 
			Strings::utf16_to_utf8(path.c_str()), 
			hash);
		auto ec_data = System::cmd_execute_and_capture_output(Strings::utf8_to_utf16(cmd_line));
		Checks::check_exit(ec_data.exit_code == 0, "Running command:\n   %s\n failed", cmd_line);
		System::print(ec_data.output.c_str());
	}

	void hash_command(const vcpkg_cmd_arguments& args)
	{
		static const std::string example = Strings::format(
			"The argument should be a file path\n%s", create_example_string("hash boost_1_62_0.tar.bz2"));
		args.check_min_arg_count(1, example.c_str());
		args.check_max_arg_count(2, example.c_str());

		if (args.command_arguments.size() == 1)
		{
			file_hash_sha512(args.command_arguments[0], "SHA512");
		}
		if (args.command_arguments.size() == 2)
		{
			file_hash_sha512(args.command_arguments[0], args.command_arguments[1].c_str());
		}

		exit(EXIT_SUCCESS);
	}
}
