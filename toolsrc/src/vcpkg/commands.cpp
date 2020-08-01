#include "pch.h"

#include <vcpkg/base/system.print.h>

#include <vcpkg/build.h>
#include <vcpkg/commands.autocomplete.h>
#include <vcpkg/commands.buildexternal.h>
#include <vcpkg/commands.cache.h>
#include <vcpkg/commands.ci.h>
#include <vcpkg/commands.ciclean.h>
#include <vcpkg/commands.contact.h>
#include <vcpkg/commands.create.h>
#include <vcpkg/commands.dependinfo.h>
#include <vcpkg/commands.edit.h>
#include <vcpkg/commands.env.h>
#include <vcpkg/commands.fetch.h>
#include <vcpkg/commands.format-manifest.h>
#include <vcpkg/commands.h>
#include <vcpkg/commands.hash.h>
#include <vcpkg/commands.integrate.h>
#include <vcpkg/commands.list.h>
#include <vcpkg/commands.owns.h>
#include <vcpkg/commands.porthistory.h>
#include <vcpkg/commands.portsdiff.h>
#include <vcpkg/commands.search.h>
#include <vcpkg/commands.setinstalled.h>
#include <vcpkg/commands.upgrade.h>
#include <vcpkg/commands.version.h>
#include <vcpkg/commands.xvsinstances.h>
#include <vcpkg/export.h>
#include <vcpkg/help.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>
#include <vcpkg/update.h>

namespace vcpkg::Commands
{
    Span<const PackageNameAndFunction<CommandTypeA>> get_available_commands_type_a()
    {
        static std::vector<PackageNameAndFunction<CommandTypeA>> t = {
            {"install", &Install::perform_and_exit},
            {"x-set-installed", &SetInstalled::perform_and_exit},
            {"ci", &CI::perform_and_exit},
            {"remove", &Remove::perform_and_exit},
            {"upgrade", &Upgrade::perform_and_exit},
            {"build", &Build::Command::perform_and_exit},
            {"env", &Env::perform_and_exit},
            {"build-external", &BuildExternal::perform_and_exit},
            {"export", &Export::perform_and_exit},
            {"depend-info", &DependInfo::perform_and_exit},
        };
        return t;
    }

    Span<const PackageNameAndFunction<CommandTypeB>> get_available_commands_type_b()
    {
        static std::vector<PackageNameAndFunction<CommandTypeB>> t = {
            {"/?", &Help::perform_and_exit},
            {"help", &Help::perform_and_exit},
            {"search", &Search::perform_and_exit},
            {"list", &List::perform_and_exit},
            {"integrate", &Integrate::perform_and_exit},
            {"owns", &Owns::perform_and_exit},
            {"update", &Update::perform_and_exit},
            {"edit", &Edit::perform_and_exit},
            {"create", &Create::perform_and_exit},
            {"cache", &Cache::perform_and_exit},
            {"portsdiff", &PortsDiff::perform_and_exit},
            {"autocomplete", &Autocomplete::perform_and_exit},
            {"hash", &Hash::perform_and_exit},
            {"fetch", &Fetch::perform_and_exit},
            {"x-ci-clean", &CIClean::perform_and_exit},
            {"x-history", &PortHistory::perform_and_exit},
            {"x-vsinstances", &X_VSInstances::perform_and_exit},
            {"x-format-manifest", &FormatManifest::perform_and_exit},
        };
        return t;
    }

    Span<const PackageNameAndFunction<CommandTypeC>> get_available_commands_type_c()
    {
        static std::vector<PackageNameAndFunction<CommandTypeC>> t = {
            {"version", &Version::perform_and_exit},
            {"contact", &Contact::perform_and_exit},
        };
        return t;
    }
}
