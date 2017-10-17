#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#pragma warning(push)
#pragma warning(disable : 4768)
#include <Shlobj.h>
#pragma warning(pop)
#else
#include <unistd.h>
#endif

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/vcpkglib.h>

#include <cassert>
#include <fstream>
#include <memory>

#pragma comment(lib, "ole32")
#pragma comment(lib, "shell32")

using namespace vcpkg;

void invalid_command(const std::string& cmd)
{
    System::println(System::Color::error, "invalid command: %s", cmd);
    Help::print_usage();
    Checks::exit_fail(VCPKG_LINE_INFO);
}

static void inner(const VcpkgCmdArguments& args)
{
    Metrics::g_metrics.lock()->track_property("command", args.command);
    if (args.command.empty())
    {
        Help::print_usage();
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    static const auto find_command = [&](auto&& commands) {
        auto it = Util::find_if(commands, [&](auto&& commandc) {
            return Strings::case_insensitive_ascii_equals(commandc.name, args.command);
        });
        using std::end;
        if (it != end(commands))
        {
            return &*it;
        }
        else
            return static_cast<decltype(&*it)>(nullptr);
    };

    if (const auto command_function = find_command(Commands::get_available_commands_type_c()))
    {
        return command_function->function(args);
    }

    fs::path vcpkg_root_dir;
    if (args.vcpkg_root_dir != nullptr)
    {
        vcpkg_root_dir = fs::stdfs::absolute(Strings::to_utf16(*args.vcpkg_root_dir));
    }
    else
    {
        const auto vcpkg_root_dir_env = System::get_environment_variable("VCPKG_ROOT");
        if (const auto v = vcpkg_root_dir_env.get())
        {
            vcpkg_root_dir = fs::stdfs::absolute(*v);
        }
        else
        {
            const fs::path current_path = fs::stdfs::current_path();
            vcpkg_root_dir = Files::get_real_filesystem().find_file_recursively_up(current_path, ".vcpkg-root");

            if (vcpkg_root_dir.empty())
            {
                vcpkg_root_dir = Files::get_real_filesystem().find_file_recursively_up(
                    fs::stdfs::absolute(System::get_exe_path_of_current_process()), ".vcpkg-root");
            }
        }
    }

    Checks::check_exit(VCPKG_LINE_INFO, !vcpkg_root_dir.empty(), "Error: Could not detect vcpkg-root.");

    const Expected<VcpkgPaths> expected_paths = VcpkgPaths::create(vcpkg_root_dir);
    Checks::check_exit(VCPKG_LINE_INFO,
                       !expected_paths.error(),
                       "Error: Invalid vcpkg root directory %s: %s",
                       vcpkg_root_dir.string(),
                       expected_paths.error().message());
    const VcpkgPaths paths = expected_paths.value_or_exit(VCPKG_LINE_INFO);

#if defined(_WIN32)
    const int exit_code = _wchdir(paths.root.c_str());
#else
    const int exit_code = chdir(paths.root.c_str());
#endif
    Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Changing the working dir failed");

    if (args.command != "autocomplete")
    {
        Commands::Version::warn_if_vcpkg_version_mismatch(paths);
    }

    if (const auto command_function = find_command(Commands::get_available_commands_type_b()))
    {
        return command_function->function(args, paths);
    }

    Triplet default_triplet;
    if (args.triplet != nullptr)
    {
        default_triplet = Triplet::from_canonical_name(*args.triplet);
    }
    else
    {
        const auto vcpkg_default_triplet_env = System::get_environment_variable("VCPKG_DEFAULT_TRIPLET");
        if (const auto v = vcpkg_default_triplet_env.get())
        {
            default_triplet = Triplet::from_canonical_name(*v);
        }
        else
        {
            default_triplet = Triplet::X86_WINDOWS;
        }
    }

    Input::check_triplet(default_triplet, paths);

    if (const auto command_function = find_command(Commands::get_available_commands_type_a()))
    {
        return command_function->function(args, paths, default_triplet);
    }

    return invalid_command(args.command);
}

static void load_config()
{
#if defined(_WIN32)
    fs::path localappdata;
    {
        // Config path in AppDataLocal
        wchar_t* localappdatapath = nullptr;
        if (S_OK != SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr, &localappdatapath)) __fastfail(1);
        localappdata = localappdatapath;
        CoTaskMemFree(localappdatapath);
    }

    try
    {
        auto maybe_pghs = Paragraphs::get_paragraphs(Files::get_real_filesystem(), localappdata / "vcpkg" / "config");
        if (const auto p_pghs = maybe_pghs.get())
        {
            const auto& pghs = *p_pghs;

            std::unordered_map<std::string, std::string> keys;
            if (pghs.size() > 0) keys = pghs[0];

            for (size_t x = 1; x < pghs.size(); ++x)
            {
                for (auto&& p : pghs[x])
                    keys.insert(p);
            }

            auto user_id = keys["User-Id"];
            auto user_time = keys["User-Since"];
            if (!user_id.empty() && !user_time.empty())
            {
                Metrics::g_metrics.lock()->set_user_information(user_id, user_time);
                return;
            }
        }
    }
    catch (...)
    {
    }

    // config file not found, could not be read, or invalid
    std::string user_id, user_time;
    {
        auto locked_metrics = Metrics::g_metrics.lock();
        locked_metrics->init_user_information(user_id, user_time);
        locked_metrics->set_user_information(user_id, user_time);
    }
    try
    {
        std::error_code ec;
        auto& fs = Files::get_real_filesystem();
        fs.create_directory(localappdata / "vcpkg", ec);
        fs.write_contents(localappdata / "vcpkg" / "config",
                          Strings::format("User-Id: %s\n"
                                          "User-Since: %s\n",
                                          user_id,
                                          user_time));
    }
    catch (...)
    {
    }
#endif
}

static std::string trim_path_from_command_line(const std::string& full_command_line)
{
    Checks::check_exit(
        VCPKG_LINE_INFO, full_command_line.size() > 0, "Internal failure - cannot have empty command line");

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

#if defined(_WIN32)
int wmain(const int argc, const wchar_t* const* const argv)
#else
int main(const int argc, const char* const* const argv)
#endif
{
    if (argc == 0) std::abort();

    *GlobalState::timer.lock() = Chrono::ElapsedTime::create_started();

#if defined(_WIN32)
    GlobalState::g_init_console_cp = GetConsoleCP();
    GlobalState::g_init_console_output_cp = GetConsoleOutputCP();

    SetConsoleCP(65001);
    SetConsoleOutputCP(65001);

    const std::string trimmed_command_line = trim_path_from_command_line(Strings::to_utf8(GetCommandLineW()));
#endif

    {
        auto locked_metrics = Metrics::g_metrics.lock();
        locked_metrics->track_property("version", Commands::Version::version());
#if defined(_WIN32)
        locked_metrics->track_property("cmdline", trimmed_command_line);
#endif
    }
    load_config();
    Metrics::g_metrics.lock()->track_property("sqmuser", Metrics::get_SQM_user());

    const VcpkgCmdArguments args = VcpkgCmdArguments::create_from_command_line(argc, argv);

    if (const auto p = args.printmetrics.get()) Metrics::g_metrics.lock()->set_print_metrics(*p);
    if (const auto p = args.sendmetrics.get()) Metrics::g_metrics.lock()->set_send_metrics(*p);
    if (const auto p = args.debug.get()) GlobalState::debugging = *p;

    Checks::register_console_ctrl_handler();

    if (GlobalState::debugging)
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
    Metrics::g_metrics.lock()->track_property("error", exc_msg);

    fflush(stdout);
    System::print("vcpkg.exe has crashed.\n"
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
    {
#if defined(_WIN32)
        System::println("%s|", Strings::to_utf8(argv[x]));
#else
        System::println("%s|", argv[x]);
#endif
    }
    fflush(stdout);
}
