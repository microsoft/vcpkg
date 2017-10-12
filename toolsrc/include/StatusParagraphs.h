#pragma once
#include "StatusParagraph.h"
#include <iterator>
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

        const_iterator find(const PackageSpec& spec) const { return find(spec.name(), spec.triplet()); }
        const_iterator find(const std::string& name, const Triplet& triplet) const;
        iterator find(const std::string& name, const Triplet& triplet);
        std::vector<std::unique_ptr<StatusParagraph>*> find_all(const std::string& name, const Triplet& triplet);
        iterator find(const std::string& name, const Triplet& triplet, const std::string& feature);

        const_iterator find_installed(const PackageSpec& spec) const
        {
            return find_installed(spec.name(), spec.triplet());
        }
        const_iterator find_installed(const std::string& name, const Triplet& triplet) const;

        iterator insert(std::unique_ptr<StatusParagraph>);

        friend void serialize(const StatusParagraphs& pgh, std::string& out_str);

        iterator end() { return paragraphs.rend(); }

        const_iterator end() const { return paragraphs.rend(); }

        iterator begin() { return paragraphs.rbegin(); }

        const_iterator begin() const { return paragraphs.rbegin(); }

    private:
        std::vector<std::unique_ptr<StatusParagraph>> paragraphs;
    };

    void serialize(const StatusParagraphs& pgh, std::string& out_str);
}
