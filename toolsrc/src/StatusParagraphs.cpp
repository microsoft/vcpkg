#include "StatusParagraphs.h"
#include <algorithm>
#include "vcpkg_Checks.h"

namespace vcpkg
{
    StatusParagraphs::StatusParagraphs() = default;

    StatusParagraphs::StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps)
        : paragraphs(std::move(ps))
    {
    };

    StatusParagraphs::const_iterator StatusParagraphs::find(const std::string& name, const triplet& target_triplet) const
    {
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh)
                            {
                                const package_spec& spec = pgh->package.spec;
                                return spec.name() == name && spec.target_triplet() == target_triplet;
                            });
    }

    StatusParagraphs::iterator StatusParagraphs::find(const std::string& name, const triplet& target_triplet)
    {
        return std::find_if(begin(), end(), [&](const std::unique_ptr<StatusParagraph>& pgh)
                            {
                                const package_spec& spec = pgh->package.spec;
                                return spec.name() == name && spec.target_triplet() == target_triplet;
                            });
    }

    StatusParagraphs::iterator StatusParagraphs::find_installed(const std::string& name, const triplet& target_triplet)
    {
        auto it = find(name, target_triplet);
        if (it != end() && (*it)->want == want_t::install)
        {
            return it;
        }

        return end();
    }

    StatusParagraphs::iterator StatusParagraphs::insert(std::unique_ptr<StatusParagraph> pgh)
    {
        Checks::check_throw(pgh != nullptr, "Inserted null paragraph");
        const package_spec& spec = pgh->package.spec;
        auto ptr = find(spec.name(), spec.target_triplet());
        if (ptr == end())
        {
            paragraphs.push_back(std::move(pgh));
            return paragraphs.rbegin();
        }

        // consume data from provided pgh.
        **ptr = std::move(*pgh);
        return ptr;
    }

    std::ostream& vcpkg::operator<<(std::ostream& os, const StatusParagraphs& l)
    {
        for (auto& pgh : l.paragraphs)
        {
            os << *pgh;
            os << "\n";
        }
        return os;
    }
}
