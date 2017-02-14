#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#include <iostream>
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
#include "vcpkg_info.h"
#include "vcpkg_Strings.h"

using namespace vcpkg;

bool g_debugging = false;

void invalid_command(const std::string& cmd)
{
    System::println(System::color::error, "invalid command: %s", cmd);
    Commands::Help::print_usage();
    exit(EXIT_FAILURE);
}

static void inner(const vcpkg_cmd_arguments& args)
{
    TrackProperty("command", args.command);
    if (args.command.empty())
    {
        Commands::Help::print_usage();
        exit(EXIT_FAILURE);
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
        auto vcpkg_root_dir_env = System::get_environmental_variable(L"VCPKG_ROOT");

        if (!vcpkg_root_dir_env.empty())
        {
            vcpkg_root_dir = fs::absolute(vcpkg_root_dir_env);
        }
        else
        {
            vcpkg_root_dir = Files::find_file_recursively_up(fs::absolute(System::get_exe_path_of_current_process()), ".vcpkg-root");
        }
    }

    Checks::check_exit(!vcpkg_root_dir.empty(), "Error: Could not detect vcpkg-root.");

    const expected<vcpkg_paths> expected_paths = vcpkg_paths::create(vcpkg_root_dir);
    Checks::check_exit(!expected_paths.error_code(), "Error: Invalid vcpkg root directory %s: %s", vcpkg_root_dir.string(), expected_paths.error_code().message());
    const vcpkg_paths paths = expected_paths.get_or_throw();
    int exit_code = _wchdir(paths.root.c_str());
    Checks::check_exit(exit_code == 0, "Changing the working dir failed");

    if (auto command_function = Commands::find(args.command, Commands::get_available_commands_type_b()))
    {
        return command_function(args, paths);
    }

    triplet default_target_triplet;
    if (args.target_triplet != nullptr)
    {
        default_target_triplet = triplet::from_canonical_name(*args.target_triplet);
    }
    else
    {
        const auto vcpkg_default_triplet_env = System::get_environmental_variable(L"VCPKG_DEFAULT_TRIPLET");
        if (!vcpkg_default_triplet_env.empty())
        {
            default_target_triplet = triplet::from_canonical_name(Strings::utf16_to_utf8(vcpkg_default_triplet_env));
        }
        else
        {
            default_target_triplet = triplet::X86_WINDOWS;
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
        std::string config_contents = Files::read_contents(localappdata / "vcpkg" / "config").get_or_throw();

        std::unordered_map<std::string, std::string> keys;
        auto pghs = Paragraphs::parse_paragraphs(config_contents);
        if (pghs.size() > 0)
            keys = pghs[0];

        for (size_t x = 1; x < pghs.size(); ++x)
        {
            for (auto&& p : pghs[x])
                keys.insert(p);
        }

        auto user_id = keys["User-Id"];
        auto user_time = keys["User-Since"];
        Checks::check_throw(!user_id.empty() && !user_time.empty(), ""); // Use as goto to the catch statement

        SetUserInformation(user_id, user_time);
        return;
    }
    catch (...)
    {
    }

    // config file not found, could not be read, or invalid
    std::string user_id, user_time;
    InitUserInformation(user_id, user_time);
    SetUserInformation(user_id, user_time);
    try
    {
        std::error_code ec;
        fs::create_directory(localappdata / "vcpkg", ec);
        std::ofstream(localappdata / "vcpkg" / "config", std::ios_base::out | std::ios_base::trunc)
            << "User-Id: " << user_id << "\n"
            << "User-Since: " << user_time << "\n";
    }
    catch (...)
    {
    }
}

static System::Stopwatch2 g_timer;

static std::string trim_path_from_command_line(const std::string& full_command_line)
{
    Checks::check_exit(full_command_line.size() > 0, "Internal failure - cannot have empty command line");

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

int wmain(const int argc, const wchar_t* const* const argv)
{
    if (argc == 0)
        std::abort();

    std::cout.sync_with_stdio(false);
    std::cout.imbue(std::locale::classic());

    g_timer.start();
    atexit([]()
        {
            g_timer.stop();
            TrackMetric("elapsed_us", g_timer.microseconds());
            Flush();
        });

    TrackProperty("version", Info::version());

    const std::string trimmed_command_line = trim_path_from_command_line(Strings::utf16_to_utf8(GetCommandLineW()));
    TrackProperty("cmdline", trimmed_command_line);
    loadConfig();
    TrackProperty("sqmuser", GetSQMUser());

    const vcpkg_cmd_arguments args = vcpkg_cmd_arguments::create_from_command_line(argc, argv);

    if (args.printmetrics != opt_bool_t::UNSPECIFIED)
        SetPrintMetrics(args.printmetrics == opt_bool_t::ENABLED);
    if (args.sendmetrics != opt_bool_t::UNSPECIFIED)
        SetSendMetrics(args.sendmetrics == opt_bool_t::ENABLED);

    if (args.debug != opt_bool_t::UNSPECIFIED)
    {
        g_debugging = (args.debug == opt_bool_t::ENABLED);
    }

    if (g_debugging)
    {
        inner(args);
        exit(EXIT_FAILURE);
    }

    std::string exc_msg;
    try
    {
        inner(args);
        exit(EXIT_FAILURE);
    }
    catch (std::exception& e)
    {
        exc_msg = e.what();
    }
    catch (...)
    {
        exc_msg = "unknown error(...)";
    }
    TrackProperty("error", exc_msg);
    std::cerr
        << "vcpkg.exe has crashed.\n"
        << "Please send an email to:\n"
        << "    " << Info::email() << "\n"
        << "containing a brief summary of what you were trying to do and the following data blob:\n"
        << "\n"
        << "Version=" << Info::version() << "\n"
        << "EXCEPTION='" << exc_msg << "'\n"
        << "CMD=\n";
    for (int x = 0; x < argc; ++x)
        std::cerr << Strings::utf16_to_utf8(argv[x]) << "|\n";
    std::cerr
        << "\n";
}
