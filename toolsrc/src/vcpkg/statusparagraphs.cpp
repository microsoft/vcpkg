#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/statusparagraphs.h>

namespace vcpkg
{
    StatusParagraphs::StatusParagraphs() = default;

    StatusParagraphs::StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps)
        : paragraphs(std::move(ps)){};

    std::vector<std::unique_ptr<StatusParagraph>*> StatusParagraphs::find_all(const std::string& name,
                                                                              const Triplet& triplet)
    {
        std::vector<std::unique_ptr<StatusParagraph>*> spghs;
        for (auto&& p : *this)
        {
            if (p->package.spec.name() == name && p->package.spec.triplet() == triplet)
            {
                if (p->package.feature.empty())
                    spghs.emplace(spghs.begin(), &p);
                else
                    spghs.emplace_back(&p);
            }
        }
        return spghs;
    }

    std::vector<const std::unique_ptr<StatusParagraph>*> StatusParagraphs::find_all_installed(
        const PackageSpec& spec) const
    {
        std::vector<const std::unique_ptr<StatusParagraph>*> spghs;
        for (auto&& p : *this)
        {
            if (p->package.spec.name() == spec.name() && p->package.spec.triplet() == spec.triplet() &&
                p->is_installed())
            {
                if (p->package.feature.empty())
                    spghs.emplace(spghs.begin(), &p);
                else
                    spghs.emplace_back(&p);
            }
        }
        return spghs;
    }

    StatusParagraphs::iterator StatusParagraphs::find(const std::string& name,
                                                      const Triplet& triplet,
                                                      const std::string& feature)
    {
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh) {
            const PackageSpec& spec = pgh->package.spec;
            return spec.name() == name && spec.triplet() == triplet && pgh->package.feature == feature;
        });
    }

    StatusParagraphs::const_iterator StatusParagraphs::find(const std::string& name,
                                                            const Triplet& triplet,
                                                            const std::string& feature) const
    {
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

    bool vcpkg::StatusParagraphs::is_installed(const PackageSpec& spec) const
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
}
