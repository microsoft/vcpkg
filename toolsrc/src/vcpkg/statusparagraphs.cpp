#include <vcpkg/base/checks.h>

#include <vcpkg/install.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg
{
    StatusParagraphs::StatusParagraphs() = default;

    StatusParagraphs::StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps) : paragraphs(std::move(ps))
    {
    }

    std::vector<std::unique_ptr<StatusParagraph>*> StatusParagraphs::find_all(const std::string& name, Triplet triplet)
    {
        std::vector<std::unique_ptr<StatusParagraph>*> spghs;
        for (auto&& p : *this)
        {
            if (p->package.spec.name() == name && p->package.spec.triplet() == triplet)
            {
                if (p->package.is_feature())
                    spghs.emplace_back(&p);
                else
                    spghs.emplace(spghs.begin(), &p);
            }
        }
        return spghs;
    }

    Optional<InstalledPackageView> StatusParagraphs::get_installed_package_view(const PackageSpec& spec) const
    {
        InstalledPackageView ipv;
        for (auto&& p : *this)
        {
            if (p->package.spec.name() == spec.name() && p->package.spec.triplet() == spec.triplet() &&
                p->is_installed())
            {
                if (p->package.is_feature())
                {
                    ipv.features.emplace_back(p.get());
                }
                else
                {
                    Checks::check_exit(VCPKG_LINE_INFO, ipv.core == nullptr);
                    ipv.core = p.get();
                }
            }
        }
        if (ipv.core != nullptr)
            return ipv;
        else
            return nullopt;
    }

    StatusParagraphs::iterator StatusParagraphs::find(const std::string& name,
                                                      Triplet triplet,
                                                      const std::string& feature)
    {
        if (feature == "core")
        {
            // The core feature maps to .feature is empty
            return find(name, triplet, {});
        }
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh) {
            const PackageSpec& spec = pgh->package.spec;
            return spec.name() == name && spec.triplet() == triplet && pgh->package.feature == feature;
        });
    }

    StatusParagraphs::const_iterator StatusParagraphs::find(const std::string& name,
                                                            Triplet triplet,
                                                            const std::string& feature) const
    {
        if (feature == "core")
        {
            // The core feature maps to .feature == ""
            return find(name, triplet, "");
        }
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh) {
            const PackageSpec& spec = pgh->package.spec;
            return spec.name() == name && spec.triplet() == triplet && pgh->package.feature == feature;
        });
    }

    StatusParagraphs::const_iterator StatusParagraphs::find_installed(const PackageSpec& spec) const
    {
        auto it = find(spec);
        if (it != end() && (*it)->is_installed())
        {
            return it;
        }
        else
        {
            return end();
        }
    }

    StatusParagraphs::const_iterator StatusParagraphs::find_installed(const FeatureSpec& spec) const
    {
        auto it = find(spec);
        if (it != end() && (*it)->is_installed())
        {
            return it;
        }
        else
        {
            return end();
        }
    }

    bool vcpkg::StatusParagraphs::is_installed(const PackageSpec& spec) const
    {
        auto it = find(spec);
        return it != end() && (*it)->is_installed();
    }

    bool vcpkg::StatusParagraphs::is_installed(const FeatureSpec& spec) const
    {
        auto it = find(spec);
        return it != end() && (*it)->is_installed();
    }

    StatusParagraphs::iterator StatusParagraphs::insert(std::unique_ptr<StatusParagraph> pgh)
    {
        Checks::check_exit(VCPKG_LINE_INFO, pgh != nullptr, "Inserted null paragraph");
        const PackageSpec& spec = pgh->package.spec;
        const auto ptr = find(spec.name(), spec.triplet(), pgh->package.feature);
        if (ptr == end())
        {
            paragraphs.push_back(std::move(pgh));
            return paragraphs.rbegin();
        }

        // consume data from provided pgh.
        **ptr = std::move(*pgh);
        return ptr;
    }

    void serialize(const StatusParagraphs& pghs, std::string& out_str)
    {
        for (auto& pgh : pghs.paragraphs)
        {
            serialize(*pgh, out_str);
            out_str.push_back('\n');
        }
    }

    Json::Value serialize_ipv(const InstalledPackageView& ipv, const VcpkgPaths& paths)
    {
        const auto& fs = paths.get_filesystem();
        Json::Object iobj;
        iobj.insert("version-string", Json::Value::string(ipv.core->package.version));
        iobj.insert("port-version", Json::Value::integer(ipv.core->package.port_version));
        iobj.insert("triplet", Json::Value::string(ipv.spec().triplet().to_string()));
        iobj.insert("abi", Json::Value::string(ipv.core->package.abi));
        Json::Array deps;
        for (auto&& dep : ipv.dependencies())
            deps.push_back(Json::Value::string(dep.to_string()));
        if (deps.size() != 0)
        {
            iobj.insert("dependencies", std::move(deps));
        }
        Json::Array features;
        for (auto&& feature : ipv.features)
        {
            features.push_back(Json::Value::string(feature->package.feature));
        }
        if (features.size() != 0)
        {
            iobj.insert("features", std::move(features));
        }
        auto usage = Install::get_cmake_usage(ipv.core->package, paths);
        if (!usage.message.empty())
        {
            iobj.insert("usage", Json::Value::string(std::move(usage.message)));
        }
        auto owns_files = fs.read_lines(paths.listfile_path(ipv.core->package)).value_or_exit(VCPKG_LINE_INFO);
        Json::Array owns;
        for (auto&& owns_file : owns_files)
            owns.push_back(Json::Value::string(std::move(owns_file)));

        iobj.insert("owns", std::move(owns));
        return Json::Value::object(std::move(iobj));
    }
}
