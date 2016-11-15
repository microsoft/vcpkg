#pragma once
#include "StatusParagraph.h"
#include <memory>

namespace vcpkg
{
    struct StatusParagraphs
    {
        StatusParagraphs();
        explicit StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps);

        using container = std::vector<std::unique_ptr<StatusParagraph>>;
        using iterator = container::reverse_iterator;
        using const_iterator = container::const_reverse_iterator;

        const_iterator find(const package_spec& spec) const
        {
            return find(spec.name(), spec.target_triplet());
        }
        const_iterator find(const std::string& name, const triplet& target_triplet) const;
        iterator find(const std::string& name, const triplet& target_triplet);
        iterator find_installed(const std::string& name, const triplet& target_triplet);

        iterator insert(std::unique_ptr<StatusParagraph>);

        friend std::ostream& operator<<(std::ostream&, const StatusParagraphs&);

        auto end()
        {
            return paragraphs.rend();
        }

        auto end() const
        {
            return paragraphs.rend();
        }

        auto begin()
        {
            return paragraphs.rbegin();
        }

        auto begin() const
        {
            return paragraphs.rbegin();
        }

    private:
        std::vector<std::unique_ptr<StatusParagraph>> paragraphs;
    };

    std::ostream& operator<<(std::ostream&, const StatusParagraphs&);
}
