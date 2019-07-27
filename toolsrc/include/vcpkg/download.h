#pragma once

#include <vcpkg/base/chrono.h>
#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/install.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <vector>

// "Download" should work almost identically to how "Install" works, so much of the logic is forwarded to "Install".
namespace vcpkg::Download
{
    // Build::ExtendedBuildResult perform_install_plan_action(const VcpkgPaths& paths,
    //                                                        const Dependencies::InstallPlanAction& action,
    //                                                        StatusParagraphs& status_db);

    Install::InstallSummary perform(const std::vector<Dependencies::AnyAction>& action_plan,
                                    const Install::KeepGoing keep_going,
                                    const VcpkgPaths& paths,
                                    StatusParagraphs& status_db);

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
}
