#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#include <fstream>
#include <memory>
#include <cassert>
#include "vcpkg_Commands.h"
#include "metrics.h"
#include <Shlobj.h>
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"
#include "Paragraphs.h"
#include "vcpkg_Strings.h"
#include "vcpkg_Chrono.h"
#include "vcpkglib.h"

using namespace vcpkg;

void invalid_command(const std::string& cmd)
{
    System::println(System::color::error, "invalid command: %s", cmd);
    Commands::Help::print_usage();
    Checks::exit_fail(VCPKG_LINE_INFO);
}

static void inner(const vcpkg_cmd_arguments& args)
{
    Metrics::track_property("command", args.command);
    if (args.command.empty())
    {
        Commands::Help::print_usage();
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    if (auto command_function = Commands::find(args.command, Commands::get_available_commands_type_c()))
    {
        return command_function(args);
    }

    fs::path vcpkg_root_dir;
    if (args.vcpkg_root_dir != nullptr)
    {
        vcpkg_root_dir = fs::absolute(Strings::utf8_to_utf16(*args.vcpkg_root_dir));
    }
    else
    {
        const optional<std::wstring> vcpkg_root_dir_env = System::get_environmental_variable(L"VCPKG_ROOT");
        if (auto v = vcpkg_root_dir_env.get())
        {
            vcpkg_root_dir = fs::absolute(*v);
        }
        else
        {
            vcpkg_root_dir = Files::find_file_recursively_up(fs::absolute(System::get_exe_path_of_current_process()), ".vcpkg-root");
        }
    }

    Checks::check_exit(VCPKG_LINE_INFO, !vcpkg_root_dir.empty(), "Error: Could not detect vcpkg-root.");

    const expected<vcpkg_paths> expected_paths = vcpkg_paths::create(vcpkg_root_dir);
    Checks::check_exit(VCPKG_LINE_INFO, !expected_paths.error_code(), "Error: Invalid vcpkg root directory %s: %s", vcpkg_root_dir.string(), expected_paths.error_code().message());
    const vcpkg_paths paths = expected_paths.value_or_exit(VCPKG_LINE_INFO);
    int exit_code = _wchdir(paths.root.c_str());
    Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Changing the working dir failed");

    if (auto command_function = Commands::find(args.command, Commands::get_available_commands_type_b()))
    {
        return command_function(args, paths);
    }

    Triplet default_target_triplet;
    if (args.target_triplet != nullptr)
    {
        default_target_triplet = Triplet::from_canonical_name(*args.target_triplet);
    }
    else
    {
        const optional<std::wstring> vcpkg_default_triplet_env = System::get_environmental_variable(L"VCPKG_DEFAULT_TRIPLET");
        if (auto v = vcpkg_default_triplet_env.get())
        {
            default_target_triplet = Triplet::from_canonical_name(Strings::utf16_to_utf8(*v));
        }
        else
        {
            default_target_triplet = Triplet::X86_WINDOWS;
        }
    }

    Input::check_triplet(default_target_triplet, paths);

    if (auto command_function = Commands::find(args.command, Commands::get_available_commands_type_a()))
    {
        return command_function(args, paths, default_target_triplet);
    }

    return invalid_command(args.command);
}

static void loadConfig()
{
    fs::path localappdata;
    {
        // Config path in AppDataLocal
        wchar_t* localappdatapath = nullptr;
        if (S_OK != SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr, &localappdatapath))
            __fastfail(1);
        localappdata = localappdatapath;
        CoTaskMemFree(localappdatapath);
    }

    try
    {
        auto maybe_pghs = Paragraphs::get_paragraphs(localappdata / "vcpkg" / "config");
        if (auto p_pghs = maybe_pghs.get())
        {
            const auto& pghs = *p_pghs;

            std::unordered_map<std::string, std::string> keys;
            if (pghs.size() > 0)
                keys = pghs[0];

            for (size_t x = 1; x < pghs.size(); ++x)
            {
                for (auto&& p : pghs[x])
                    keys.insert(p);
            }

            auto user_id = keys["User-Id"];
            auto user_time = keys["User-Since"];
            if (!user_id.empty() && !user_time.empty())
            {
                Metrics::set_user_information(user_id, user_time);
                return;
            }
        }
    }
    catch (...) { }

    // config file not found, could not be read, or invalid
    std::string user_id, user_time;
    Metrics::init_user_information(user_id, user_time);
    Metrics::set_user_information(user_id, user_time);
    try
    {
        std::error_code ec;
        fs::create_directory(localappdata / "vcpkg", ec);
        std::ofstream(localappdata / "vcpkg" / "config", std::ios_base::out | std::ios_base::trunc)
            << "User-Id: " << user_id << "\n"
            << "User-Since: " << user_time << "\n";
    }
    catch (...) { }
}

static std::string trim_path_from_command_line(const std::string& full_command_line)
{
    Checks::check_exit(VCPKG_LINE_INFO, full_command_line.size() > 0, "Internal failure - cannot have empty command line");

    if (full_command_line[0] == '"')
    {
        auto it = std::find(full_command_line.cbegin() + 1, full_command_line.cend(), '"');
        if (it != full_command_line.cend()) // Skip over the quote
            ++it;
        while (it != full_command_line.cend() && *it == ' ') // Skip over a space
            ++it;
        return std::string(it, full_command_line.cend());
    }

    auto it = std::find(full_command_line.cbegin(), full_command_line.cend(), ' ');
    while (it != full_command_line.cend() && *it == ' ')
        ++it;
    return std::string(it, full_command_line.cend());
}

static ElapsedTime g_timer;

int wmain(const int argc, const wchar_t* const* const argv)
{
    if (argc == 0)
        std::abort();

    g_timer = ElapsedTime::create_started();
    atexit([]()
        {
            auto elapsed_us = g_timer.microseconds();
            Metrics::track_metric("elapsed_us", elapsed_us);
            Metrics::flush();
        });

    Metrics::track_property("version", Commands::Version::version());

    const std::string trimmed_command_line = trim_path_from_command_line(Strings::utf16_to_utf8(GetCommandLineW()));
    Metrics::track_property("cmdline", trimmed_command_line);
    loadConfig();
    Metrics::track_property("sqmuser", Metrics::get_SQM_user());

    const vcpkg_cmd_arguments args = vcpkg_cmd_arguments::create_from_command_line(argc, argv);

    if (args.printmetrics != OptBoolT::UNSPECIFIED)
        Metrics::set_print_metrics(args.printmetrics == OptBoolT::ENABLED);
    if (args.sendmetrics != OptBoolT::UNSPECIFIED)
        Metrics::set_send_metrics(args.sendmetrics == OptBoolT::ENABLED);

    if (args.debug != OptBoolT::UNSPECIFIED)
    {
        g_debugging = (args.debug == OptBoolT::ENABLED);
    }

    if (g_debugging)
    {
        inner(args);
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    std::string exc_msg;
    try
    {
        inner(args);
        Checks::exit_fail(VCPKG_LINE_INFO);
    }
    catch (std::exception& e)
    {
        exc_msg = e.what();
    }
    catch (...)
    {
        exc_msg = "unknown error(...)";
    }
    Metrics::track_property("error", exc_msg);

    fflush(stdout);
    System::print(
        "vcpkg.exe has crashed.\n"
        "Please send an email to:\n"
        "    %s\n"
        "containing a brief summary of what you were trying to do and the following data blob:\n"
        "\n"
        "Version=%s\n"
        "EXCEPTION='%s'\n"
        "CMD=\n",
        Commands::Contact::email(),
        Commands::Version::version(),
        exc_msg);
    fflush(stdout);
    for (int x = 0; x < argc; ++x)
        System::println("%s|", Strings::utf16_to_utf8(argv[x]));
    fflush(stdout);
}
