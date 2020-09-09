#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>

#include <vcpkg/commands.upload-metrics.h>
#include <vcpkg/metrics.h>
#include <vcpkg/vcpkgcmdarguments.h>

using namespace vcpkg;

#if VCPKG_DISABLE_METRICS
#error Attempt to build commands.upload-metrics.cpp when metrics are disabled.
#endif // VCPKG_DISABLE_METRICS

namespace vcpkg::Commands::UploadMetrics
{
    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("x-upload-metrics metrics.txt"),
        1,
        1,
    };

    void UploadMetricsCommand::perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs) const
    {
        (void)args.parse_arguments(COMMAND_STRUCTURE);
        const auto& payload_path = args.command_arguments[0];
        auto payload = fs.read_contents(payload_path).value_or_exit(VCPKG_LINE_INFO);
        Metrics::g_metrics.lock()->upload(payload);
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
