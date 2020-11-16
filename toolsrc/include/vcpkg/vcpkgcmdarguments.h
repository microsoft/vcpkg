#pragma once

#include <vcpkg/fwd/vcpkgcmdarguments.h>
#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/stringliteral.h>

#include <memory>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace vcpkg
{
    struct ParsedArguments
    {
        std::unordered_set<std::string> switches;
        std::unordered_map<std::string, std::string> settings;
        std::unordered_map<std::string, std::vector<std::string>> multisettings;
    };

    struct CommandSwitch
    {
        constexpr CommandSwitch(const StringLiteral& name, const StringLiteral& short_help_text)
            : name(name), short_help_text(short_help_text)
        {
        }

        StringLiteral name;
        StringLiteral short_help_text;
    };

    struct CommandSetting
    {
        constexpr CommandSetting(const StringLiteral& name, const StringLiteral& short_help_text)
            : name(name), short_help_text(short_help_text)
        {
        }

        StringLiteral name;
        StringLiteral short_help_text;
    };

    struct CommandMultiSetting
    {
        constexpr CommandMultiSetting(const StringLiteral& name, const StringLiteral& short_help_text)
            : name(name), short_help_text(short_help_text)
        {
        }

        StringLiteral name;
        StringLiteral short_help_text;
    };

    struct CommandOptionsStructure
    {
        Span<const CommandSwitch> switches;
        Span<const CommandSetting> settings;
        Span<const CommandMultiSetting> multisettings;
    };

    struct CommandStructure
    {
        std::string example_text;

        size_t minimum_arity;
        size_t maximum_arity;

        CommandOptionsStructure options;

        std::vector<std::string> (*valid_arguments)(const VcpkgPaths& paths);
    };

    void print_usage();
    void print_usage(const CommandStructure& command_structure);

#if defined(_WIN32)
    using CommandLineCharType = wchar_t;
#else
    using CommandLineCharType = char;
#endif

    std::string create_example_string(const std::string& command_and_arguments);

    std::string format_environment_variable(StringLiteral lit);

    struct HelpTableFormatter
    {
        void format(StringView col1, StringView col2);
        void example(StringView example_text);
        void header(StringView name);
        void blank();
        void text(StringView text, int indent = 0);

        std::string m_str;
    };

    struct FeatureFlagSettings
    {
        bool registries;
        bool compiler_tracking;
        bool binary_caching;
        bool versions;
    };

    struct VcpkgCmdArguments
    {
        static VcpkgCmdArguments create_from_command_line(const Files::Filesystem& fs,
                                                          const int argc,
                                                          const CommandLineCharType* const* const argv);
        static VcpkgCmdArguments create_from_arg_sequence(const std::string* arg_begin, const std::string* arg_end);

        static void append_common_options(HelpTableFormatter& target);

        constexpr static StringLiteral VCPKG_ROOT_DIR_ENV = "VCPKG_ROOT";
        constexpr static StringLiteral VCPKG_ROOT_DIR_ARG = "vcpkg-root";
        std::unique_ptr<std::string> vcpkg_root_dir;
        constexpr static StringLiteral MANIFEST_ROOT_DIR_ARG = "x-manifest-root";
        std::unique_ptr<std::string> manifest_root_dir;

        constexpr static StringLiteral BUILDTREES_ROOT_DIR_ARG = "x-buildtrees-root";
        std::unique_ptr<std::string> buildtrees_root_dir;
        constexpr static StringLiteral DOWNLOADS_ROOT_DIR_ENV = "VCPKG_DOWNLOADS";
        constexpr static StringLiteral DOWNLOADS_ROOT_DIR_ARG = "downloads-root";
        std::unique_ptr<std::string> downloads_root_dir;
        constexpr static StringLiteral INSTALL_ROOT_DIR_ARG = "x-install-root";
        std::unique_ptr<std::string> install_root_dir;
        constexpr static StringLiteral PACKAGES_ROOT_DIR_ARG = "x-packages-root";
        std::unique_ptr<std::string> packages_root_dir;
        constexpr static StringLiteral SCRIPTS_ROOT_DIR_ARG = "x-scripts-root";
        std::unique_ptr<std::string> scripts_root_dir;

        constexpr static StringLiteral DEFAULT_VISUAL_STUDIO_PATH_ENV = "VCPKG_VISUAL_STUDIO_PATH";
        std::unique_ptr<std::string> default_visual_studio_path;

        constexpr static StringLiteral TRIPLET_ENV = "VCPKG_DEFAULT_TRIPLET";
        constexpr static StringLiteral TRIPLET_ARG = "triplet";
        std::unique_ptr<std::string> triplet;
        constexpr static StringLiteral OVERLAY_PORTS_ENV = "VCPKG_OVERLAY_PORTS";
        constexpr static StringLiteral OVERLAY_PORTS_ARG = "overlay-ports";
        std::vector<std::string> overlay_ports;
        constexpr static StringLiteral OVERLAY_TRIPLETS_ENV = "VCPKG_OVERLAY_TRIPLETS";
        constexpr static StringLiteral OVERLAY_TRIPLETS_ARG = "overlay-triplets";
        std::vector<std::string> overlay_triplets;

        constexpr static StringLiteral BINARY_SOURCES_ARG = "binarysource";
        std::vector<std::string> binary_sources;

        constexpr static StringLiteral DEBUG_SWITCH = "debug";
        Optional<bool> debug = nullopt;
        constexpr static StringLiteral SEND_METRICS_SWITCH = "sendmetrics";
        Optional<bool> send_metrics = nullopt;
        // fully disable metrics -- both printing and sending
        constexpr static StringLiteral DISABLE_METRICS_ENV = "VCPKG_DISABLE_METRICS";
        constexpr static StringLiteral DISABLE_METRICS_SWITCH = "disable-metrics";
        Optional<bool> disable_metrics = nullopt;
        constexpr static StringLiteral PRINT_METRICS_SWITCH = "printmetrics";
        Optional<bool> print_metrics = nullopt;

        constexpr static StringLiteral WAIT_FOR_LOCK_SWITCH = "x-wait-for-lock";
        Optional<bool> wait_for_lock = nullopt;

        constexpr static StringLiteral IGNORE_LOCK_FAILURES_SWITCH = "x-ignore-lock-failures";
        constexpr static StringLiteral IGNORE_LOCK_FAILURES_ENV = "X_VCPKG_IGNORE_LOCK_FAILURES";
        Optional<bool> ignore_lock_failures = nullopt;

        constexpr static StringLiteral JSON_SWITCH = "x-json";
        Optional<bool> json = nullopt;

        // feature flags
        constexpr static StringLiteral FEATURE_FLAGS_ENV = "VCPKG_FEATURE_FLAGS";
        constexpr static StringLiteral FEATURE_FLAGS_ARG = "feature-flags";

        constexpr static StringLiteral FEATURE_PACKAGES_SWITCH = "featurepackages";
        Optional<bool> feature_packages = nullopt;
        constexpr static StringLiteral BINARY_CACHING_FEATURE = "binarycaching";
        constexpr static StringLiteral BINARY_CACHING_SWITCH = "binarycaching";
        Optional<bool> binary_caching = nullopt;
        constexpr static StringLiteral COMPILER_TRACKING_FEATURE = "compilertracking";
        Optional<bool> compiler_tracking = nullopt;
        constexpr static StringLiteral MANIFEST_MODE_FEATURE = "manifests";
        Optional<bool> manifest_mode = nullopt;
        constexpr static StringLiteral REGISTRIES_FEATURE = "registries";
        Optional<bool> registries_feature = nullopt;
        constexpr static StringLiteral VERSIONS_FEATURE = "versions";
        Optional<bool> versions_feature = nullopt;

        constexpr static StringLiteral RECURSIVE_DATA_ENV = "VCPKG_X_RECURSIVE_DATA";

        bool binary_caching_enabled() const { return binary_caching.value_or(true); }
        bool compiler_tracking_enabled() const { return compiler_tracking.value_or(true); }
        bool registries_enabled() const { return registries_feature.value_or(false); }
        bool versions_enabled() const { return versions_feature.value_or(false); }
        FeatureFlagSettings feature_flag_settings() const
        {
            FeatureFlagSettings f;
            f.binary_caching = binary_caching_enabled();
            f.compiler_tracking = compiler_tracking_enabled();
            f.registries = registries_enabled();
            f.versions = versions_enabled();
            return f;
        }

        bool output_json() const { return json.value_or(false); }
        bool is_recursive_invocation() const { return m_is_recursive_invocation; }

        std::string command;
        std::vector<std::string> command_arguments;

        ParsedArguments parse_arguments(const CommandStructure& command_structure) const;

        void imbue_from_environment();

        void check_feature_flag_consistency() const;

        void debug_print_feature_flags() const;
        void track_feature_flag_metrics() const;

    private:
        bool m_is_recursive_invocation = false;
        std::unordered_set<std::string> command_switches;
        std::unordered_map<std::string, std::vector<std::string>> command_options;
    };
}
