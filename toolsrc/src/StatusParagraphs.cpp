#include "pch.h"
#include "StatusParagraphs.h"
#include "vcpkg_Checks.h"
#include <algorithm>
#include <algorithm>
#include <algorithm>

namespace vcpkg
{
    StatusParagraphs::StatusParagraphs() = default;

    StatusParagraphs::StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps)
        : paragraphs(std::move(ps))
    {
    };

    StatusParagraphs::const_iterator StatusParagraphs::find(const std::string& name, const Triplet& triplet) const
    {
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh)
                            {
                                const PackageSpec& spec = pgh->package.spec;
                                return spec.name() == name && spec.triplet() == triplet;
                            });
    }

    StatusParagraphs::iterator StatusParagraphs::find(const std::string& name, const Triplet& triplet)
    {
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh)
                            {
                                const PackageSpec& spec = pgh->package.spec;
                                return spec.name() == name && spec.triplet() == triplet;
                            });
    }

    StatusParagraphs::const_iterator StatusParagraphs::find_installed(const std::string& name, const Triplet& triplet) const
    {
        const const_iterator it = find(name, triplet);
        if (it != end() && (*it)->want == Want::INSTALL && (*it)->state == InstallState::INSTALLED)
        {
            return it;
        }

        return end();
    }

    StatusParagraphs::iterator StatusParagraphs::insert(std::unique_ptr<StatusParagraph> pgh)
    {
        Checks::check_exit(VCPKG_LINE_INFO, pgh != nullptr, "Inserted null paragraph");
        const PackageSpec& spec = pgh->package.spec;
        auto ptr = find(spec.name(), spec.triplet());
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
