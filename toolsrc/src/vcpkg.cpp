#if defined(_MSC_VER) && _MSC_VER < 1911
// [[nodiscard]] is not recognized before VS 2017 version 15.3
#pragma warning(disable : 5030)
#endif

#if defined(__GNUC__) && __GNUC__ < 7
// [[nodiscard]] is not recognized before GCC version 7
#pragma GCC diagnostic ignored "-Wattributes"
#endif

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#pragma warning(push)
#pragma warning(disable : 4768)
#include <ShlObj.h>
#pragma warning(pop)
#else
#include <unistd.h>
#endif

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/commands.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/userconfig.h>
#include <vcpkg/vcpkglib.h>

#include <cassert>
#include <fstream>
#include <memory>
#include <random>

#if defined(_WIN32)
#pragma comment(lib, "ole32")
#pragma comment(lib, "shell32")
#endif

using namespace vcpkg;

// 24 hours/day * 30 days/month * 6 months
static constexpr int SURVEY_INTERVAL_IN_HOURS = 24 * 30 * 6;

// Initial survey appears after 10 days. Therefore, subtract 24 hours/day * 10 days
static constexpr int SURVEY_INITIAL_OFFSET_IN_HOURS = SURVEY_INTERVAL_IN_HOURS - 24 * 10;

void invalid_command(const std::string& cmd)
{
    System::print2(System::Color::error, "invalid command: ", cmd, '\n');
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
        vcpkg_root_dir = fs::stdfs::absolute(fs::u8path(*args.vcpkg_root_dir));
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

    Debug::print("Using vcpkg-root: ", vcpkg_root_dir.u8string(), '\n');

    auto default_vs_path = System::get_environment_variable("VCPKG_VISUAL_STUDIO_PATH").value_or("");

    const Expected<VcpkgPaths> expected_paths = VcpkgPaths::create(vcpkg_root_dir, default_vs_path);
    Checks::check_exit(VCPKG_LINE_INFO,
                       !expected_paths.error(),
                       "Error: Invalid vcpkg root directory %s: %s",
                       vcpkg_root_dir.string(),
                       expected_paths.error().message());
    const VcpkgPaths& paths = expected_paths.value_or_exit(VCPKG_LINE_INFO);

#if defined(_WIN32)
    const int exit_code = _wchdir(paths.root.c_str());
#else
    const int exit_code = chdir(paths.root.c_str());
#endif
    Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Changing the working dir failed");

    if (args.command == "install" || args.command == "remove" || args.command == "export" || args.command == "update")
    {
        Commands::Version::warn_if_vcpkg_version_mismatch(paths);
        std::string surveydate = *GlobalState::g_surveydate.lock();
        auto maybe_surveydate = Chrono::CTime::parse(surveydate);
        if (auto p_surveydate = maybe_surveydate.get())
        {
            const auto now = Chrono::CTime::get_current_date_time().value_or_exit(VCPKG_LINE_INFO);
            const auto delta = now.to_time_point() - p_surveydate->to_time_point();
            if (std::chrono::duration_cast<std::chrono::hours>(delta).count() > SURVEY_INTERVAL_IN_HOURS)
            {
                std::default_random_engine generator(
                    static_cast<unsigned int>(now.to_time_point().time_since_epoch().count()));
                std::uniform_int_distribution<int> distribution(1, 4);

                if (distribution(generator) == 1)
                {
                    Metrics::g_metrics.lock()->track_property("surveyprompt", "true");
                    System::print2(
                        System::Color::success,
                        "Your feedback is important to improve Vcpkg! Please take 3 minutes to complete our survey "
                        "by running: vcpkg contact --survey\n");
                }
            }
        }
    }

    if (const auto command_function = find_command(Commands::get_available_commands_type_b()))
    {
        return command_function->function(args, paths);
    }

    Triplet default_triplet;
    if (args.triplet != nullptr)
    {
        default_triplet = Triplet::from_canonical_name(std::string(*args.triplet));
    }
    else
    {
        auto vcpkg_default_triplet_env = System::get_environment_variable("VCPKG_DEFAULT_TRIPLET");
        if (auto v = vcpkg_default_triplet_env.get())
        {
            default_triplet = Triplet::from_canonical_name(std::move(*v));
        }
        else
        {
#if defined(_WIN32)
            default_triplet = Triplet::X86_WINDOWS;
#elif defined(__APPLE__)
            default_triplet = Triplet::from_canonical_name("x64-osx");
#elif defined(__FreeBSD__)
            default_triplet = Triplet::from_canonical_name("x64-freebsd");
#elif defined(__GLIBC__)
            default_triplet = Triplet::from_canonical_name("x64-linux");
#else
            default_triplet = Triplet::from_canonical_name("x64-linux-musl");
#endif
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
    auto& fs = Files::get_real_filesystem();

    auto config = UserConfig::try_read_data(fs);

    bool write_config = false;

    // config file not found, could not be read, or invalid
    if (config.user_id.empty() || config.user_time.empty())
    {
        ::vcpkg::Metrics::Metrics::init_user_information(config.user_id, config.user_time);
        write_config = true;
    }

#if defined(_WIN32)
    if (config.user_mac.empty())
    {
        config.user_mac = Metrics::get_MAC_user();
        write_config = true;
    }
#endif

    {
        auto locked_metrics = Metrics::g_metrics.lock();
        locked_metrics->set_user_information(config.user_id, config.user_time);
#if defined(_WIN32)
        locked_metrics->track_property("user_mac", config.user_mac);
#endif
    }

    if (config.last_completed_survey.empty())
    {
        const auto now = Chrono::CTime::parse(config.user_time).value_or_exit(VCPKG_LINE_INFO);
        const Chrono::CTime offset = now.add_hours(-SURVEY_INITIAL_OFFSET_IN_HOURS);
        config.last_completed_survey = offset.to_string();
    }

    GlobalState::g_surveydate.lock()->assign(config.last_completed_survey);

    if (write_config)
    {
        config.try_write_data(fs);
    }
}

#if defined(_WIN32)
static std::string trim_path_from_command_line(const std::string& full_command_line)
{
    Checks::check_exit(
        VCPKG_LINE_INFO, !full_command_line.empty(), "Internal failure - cannot have empty command line");

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
#endif

#if defined(_WIN32)
int wmain(const int argc, const wchar_t* const* const argv)
#else
int main(const int argc, const char* const* const argv)
#endif
{
    if (argc == 0) std::abort();

    *GlobalState::timer.lock() = Chrono::ElapsedTimer::create_started();

#if defined(_WIN32)
    GlobalState::g_init_console_cp = GetConsoleCP();
    GlobalState::g_init_console_output_cp = GetConsoleOutputCP();
    GlobalState::g_init_console_initialized = true;

    SetConsoleCP(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);

    const std::string trimmed_command_line = trim_path_from_command_line(Strings::to_utf8(GetCommandLineW()));
#endif

    Checks::register_global_shutdown_handler([]() {
        const auto elapsed_us_inner = GlobalState::timer.lock()->microseconds();

        bool debugging = Debug::g_debugging;

        auto metrics = Metrics::g_metrics.lock();
        metrics->track_metric("elapsed_us", elapsed_us_inner);
        Debug::g_debugging = false;
        metrics->flush();

#if defined(_WIN32)
        if (GlobalState::g_init_console_initialized)
        {
            SetConsoleCP(GlobalState::g_init_console_cp);
            SetConsoleOutputCP(GlobalState::g_init_console_output_cp);
        }
#endif

        auto elapsed_us = GlobalState::timer.lock()->microseconds();
        if (debugging)
            System::printf("[DEBUG] Exiting after %d us (%d us)\n",
                           static_cast<int>(elapsed_us),
                           static_cast<int>(elapsed_us_inner));
    });

    {
        auto locked_metrics = Metrics::g_metrics.lock();
        locked_metrics->track_property("version", Commands::Version::version());
#if defined(_WIN32)
        locked_metrics->track_property("cmdline", trimmed_command_line);
#endif
    }

    System::register_console_ctrl_handler();

    load_config();

    const auto vcpkg_feature_flags_env = System::get_environment_variable("VCPKG_FEATURE_FLAGS");
    if (const auto v = vcpkg_feature_flags_env.get())
    {
        auto flags = Strings::split(*v, ",");
        if (std::find(flags.begin(), flags.end(), "binarycaching") != flags.end()) GlobalState::g_binary_caching = true;
    }

    const VcpkgCmdArguments args = VcpkgCmdArguments::create_from_command_line(argc, argv);

    if (const auto p = args.binarycaching.get()) GlobalState::g_binary_caching = *p;

    if (const auto p = args.printmetrics.get()) Metrics::g_metrics.lock()->set_print_metrics(*p);
    if (const auto p = args.sendmetrics.get()) Metrics::g_metrics.lock()->set_send_metrics(*p);
    if (const auto p = args.debug.get()) Debug::g_debugging = *p;

    if (Debug::g_debugging)
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
    System::printf("vcpkg.exe has crashed.\n"
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
        System::print2(Strings::to_utf8(argv[x]), "|\n");
#else
        System::print2(argv[x], "|\n");
#endif
    }
    fflush(stdout);

    // It is expected that one of the sub-commands will exit cleanly before we get here.
    Checks::exit_fail(VCPKG_LINE_INFO);
}
