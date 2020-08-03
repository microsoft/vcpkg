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
    Span<const PackageNameAndFunction<const BasicCommand*>> get_available_basic_commands()
    {
        static const Version::VersionCommand version{};
        static const Contact::ContactCommand contact{};
        static std::vector<PackageNameAndFunction<const BasicCommand*>> t = {
            {"version", &version},
            {"contact", &contact},
        };
        return t;
    }

    Span<const PackageNameAndFunction<const PathsCommand*>> get_available_paths_commands()
    {
        static const Help::HelpCommand help{};
        static const Search::SearchCommand search{};
        static const List::ListCommand list{};
        static const Integrate::IntegrateCommand integrate{};
        static const Owns::OwnsCommand owns{};
        static const Update::UpdateCommand update{};
        static const Edit::EditCommand edit{};
        static const Create::CreateCommand create{};
        static const Cache::CacheCommand cache{};
        static const PortsDiff::PortsDiffCommand portsdiff{};
        static const Autocomplete::AutocompleteCommand autocomplete{};
        static const Hash::HashCommand hash{};
        static const Fetch::FetchCommand fetch{};
        static const CIClean::CICleanCommand ciclean{};
        static const PortHistory::PortHistoryCommand porthistory{};
        static const X_VSInstances::VSInstancesCommand vsinstances{};
        static const FormatManifest::FormatManifestCommand format_manifest{};

        static std::vector<PackageNameAndFunction<const PathsCommand*>> t = {
            {"/?", &help},
            {"help", &help},
            {"search", &search},
            {"list", &list},
            {"integrate", &integrate},
            {"owns", &owns},
            {"update", &update},
            {"edit", &edit},
            {"create", &create},
            {"cache", &cache},
            {"portsdiff", &portsdiff},
            {"autocomplete", &autocomplete},
            {"hash", &hash},
            {"fetch", &fetch},
            {"x-ci-clean", &ciclean},
            {"x-history", &porthistory},
            {"x-vsinstances", &vsinstances},
            {"x-format-manifest", &format_manifest},
        };
        return t;
    }

    Span<const PackageNameAndFunction<const TripletCommand*>> get_available_triplet_commands()
    {
        static const Install::InstallCommand install{};
        static const SetInstalled::SetInstalledCommand set_installed{};
        static const CI::CICommand ci{};
        static const Remove::RemoveCommand remove{};
        static const Upgrade::UpgradeCommand upgrade{};
        static const Build::BuildCommand build{};
        static const Env::EnvCommand env{};
        static const BuildExternal::BuildExternalCommand build_external{};
        static const Export::ExportCommand export_command{};
        static const DependInfo::DependInfoCommand depend_info{};

        static std::vector<PackageNameAndFunction<const TripletCommand*>> t = {
            {"install", &install},
            {"x-set-installed", &set_installed},
            {"ci", &ci},
            {"remove", &remove},
            {"upgrade", &upgrade},
            {"build", &build},
            {"env", &env},
            {"build-external", &build_external},
            {"export", &export_command},
            {"depend-info", &depend_info},
        };
        return t;
    }
}
