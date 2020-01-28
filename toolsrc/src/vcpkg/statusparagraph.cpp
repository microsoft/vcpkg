#include "pch.h"

#include <vcpkg/base/util.h>
#include <vcpkg/statusparagraph.h>

using namespace vcpkg::Parse;

namespace vcpkg
{
    namespace BinaryParagraphRequiredField
    {
        static const std::string STATUS = "Status";
    }

    StatusParagraph::StatusParagraph() noexcept : want(Want::ERROR_STATE), state(InstallState::ERROR_STATE) {}

    void serialize(const StatusParagraph& pgh, std::string& out_str)
    {
        serialize(pgh.package, out_str);
        out_str.append("Status: ")
            .append(to_string(pgh.want))
            .append(" ok ")
            .append(to_string(pgh.state))
            .push_back('\n');
    }

    StatusParagraph::StatusParagraph(Parse::RawParagraph&& fields)
        : want(Want::ERROR_STATE), state(InstallState::ERROR_STATE)
    {
        auto status_it = fields.find(BinaryParagraphRequiredField::STATUS);
        Checks::check_exit(VCPKG_LINE_INFO, status_it != fields.end(), "Expected 'Status' field in status paragraph");
        std::string status_field = std::move(status_it->second);
        fields.erase(status_it);

        this->package = BinaryParagraph(std::move(fields));

        auto b = status_field.begin();
        const auto mark = b;
        const auto e = status_field.end();

        // Todo: improve error handling
        while (b != e && *b != ' ')
            ++b;

        want = [](const std::string& text) {
            if (text == "unknown") return Want::UNKNOWN;
            if (text == "install") return Want::INSTALL;
            if (text == "hold") return Want::HOLD;
            if (text == "deinstall") return Want::DEINSTALL;
            if (text == "purge") return Want::PURGE;
            return Want::ERROR_STATE;
        }(std::string(mark, b));

        if (std::distance(b, e) < 4) return;
        b += 4;

        state = [](const std::string& text) {
            if (text == "not-installed") return InstallState::NOT_INSTALLED;
            if (text == "installed") return InstallState::INSTALLED;
            if (text == "half-installed") return InstallState::HALF_INSTALLED;
            return InstallState::ERROR_STATE;
        }(std::string(b, e));
    }

    std::string to_string(InstallState f)
    {
        switch (f)
        {
            case InstallState::HALF_INSTALLED: return "half-installed";
            case InstallState::INSTALLED: return "installed";
            case InstallState::NOT_INSTALLED: return "not-installed";
            default: return "error";
        }
    }

    std::string to_string(Want f)
    {
        switch (f)
        {
            case Want::DEINSTALL: return "deinstall";
            case Want::HOLD: return "hold";
            case Want::INSTALL: return "install";
            case Want::PURGE: return "purge";
            case Want::UNKNOWN: return "unknown";
            default: return "error";
        }
    }

    std::unordered_map<std::string, std::vector<FeatureSpec>> InstalledPackageView::feature_dependencies() const
    {
        auto extract_deps = [&](const std::string& dep) {
            FullPackageSpec dependency =
                FullPackageSpec::from_string(dep, spec().triplet()).value_or_exit(VCPKG_LINE_INFO);
            std::vector<FeatureSpec> fspecs;

            for (std::string& feature : dependency.features)
            {
                fspecs.emplace_back(dependency.package_spec, std::move(feature));
            }

            return fspecs;
        };

        std::unordered_map<std::string, std::vector<FeatureSpec>> deps;

        for (const StatusParagraph* const& feature : features)
        {
            deps.emplace(feature->package.feature, Util::fmap_flatten(feature->package.depends, extract_deps));
        }

        deps.emplace("core", Util::fmap_flatten(core->package.depends, extract_deps));

        return deps;
    }

    std::vector<PackageSpec> InstalledPackageView::dependencies() const
    {
        // accumulate all features in installed dependencies
        // Todo: make this unneeded by collapsing all package dependencies into the core package
        auto deps = Util::fmap_flatten(features, [](const StatusParagraph* pgh) -> std::vector<std::string> const& {
            return pgh->package.depends;
        });

        // Add the core paragraph dependencies to the list
        deps.insert(deps.end(), core->package.depends.begin(), core->package.depends.end());

        auto&& l_spec = spec();

        // <hack>
        // This is a hack to work around existing installations that put featurespecs into binary packages
        // (example: curl[core])
        for (auto&& dep : deps)
        {
            dep.erase(std::find(dep.begin(), dep.end(), '['), dep.end());
        }
        Util::erase_remove_if(deps, [&](auto&& e) { return e == l_spec.name(); });
        // </hack>
        Util::sort_unique_erase(deps);

        return PackageSpec::to_package_specs(deps, l_spec.triplet());
    }
}
