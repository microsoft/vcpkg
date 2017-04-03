#pragma once
#include "StatusParagraph.h"
#include <memory>
#include <iterator>

namespace vcpkg
{
    struct StatusParagraphs
    {
        StatusParagraphs();
        explicit StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps);

        using container = std::vector<std::unique_ptr<StatusParagraph>>;
        using iterator = container::reverse_iterator;
        using const_iterator = container::const_reverse_iterator;

        const_iterator find(const PackageSpec& spec) const
        {
            return find(spec.name(), spec.target_triplet());
        }
        const_iterator find(const std::string& name, const triplet& target_triplet) const;
        iterator find(const std::string& name, const triplet& target_triplet);
        const_iterator find_installed(const std::string& name, const triplet& target_triplet) const;

        iterator insert(std::unique_ptr<StatusParagraph>);

        friend std::ostream& operator<<(std::ostream&, const StatusParagraphs&);

        iterator end()
        {
            return paragraphs.rend();
        }

        const_iterator end() const
        {
            return paragraphs.rend();
        }

        iterator begin()
        {
            return paragraphs.rbegin();
        }

        const_iterator begin() const
        {
            return paragraphs.rbegin();
        }

    private:
        std::vector<std::unique_ptr<StatusParagraph>> paragraphs;
    };

    std::ostream& operator<<(std::ostream&, const StatusParagraphs&);
}
