#pragma once
#include <vcpkg/statusparagraph.h>

#include <iterator>
#include <memory>

namespace vcpkg
{
    /// <summary>Status paragraphs</summary>
    ///
    /// Collection of <see cref="vcpkg::StatusParagraph"/>, e.g. contains the information
    /// about whether a package is installed or not.
    ///
    struct StatusParagraphs
    {
        StatusParagraphs();
        explicit StatusParagraphs(std::vector<std::unique_ptr<StatusParagraph>>&& ps);

        using container = std::vector<std::unique_ptr<StatusParagraph>>;
        using iterator = container::reverse_iterator;
        using const_iterator = container::const_reverse_iterator;

        /// <summary>Find the StatusParagraph for given spec.</summary>
        /// <param name="spec">Package specification to find the status paragraph for</param>
        /// <returns>Iterator for found spec</returns>
        const_iterator find(const PackageSpec& spec) const { return find(spec.name(), spec.triplet()); }

        /// <summary>Find the StatusParagraph for given feature spec.</summary>
        /// <param name="spec">Feature specification to find the status paragraph for</param>
        /// <returns>Iterator for found spec</returns>
        const_iterator find(const FeatureSpec& spec) const { return find(spec.name(), spec.triplet(), spec.feature()); }

        /// <summary>Find a StatusParagraph by name, triplet and feature.</summary>
        /// <param name="name">Package name</param>
        /// <param name="triplet">Triplet</param>
        /// <param name="feature">Feature name</param>
        /// <returns>Iterator for found spec</returns>
        iterator find(const std::string& name, Triplet triplet, const std::string& feature = {});
        const_iterator find(const std::string& name, Triplet triplet, const std::string& feature = {}) const;

        std::vector<std::unique_ptr<StatusParagraph>*> find_all(const std::string& name, Triplet triplet);

        Optional<InstalledPackageView> get_installed_package_view(const PackageSpec& spec) const;

        /// <summary>Find the StatusParagraph for given spec if installed</summary>
        /// <param name="spec">Package specification to find the status for</param>
        /// <returns>Iterator for found spec</returns>
        const_iterator find_installed(const PackageSpec& spec) const;

        /// <summary>Find the StatusParagraph for given feature spec if installed</summary>
        /// <param name="spec">Feature specification to find the status for</param>
        /// <returns>Iterator for found spec</returns>
        const_iterator find_installed(const FeatureSpec& spec) const;

        /// <summary>Find the StatusParagraph for given spec and return its install status</summary>
        /// <param name="spec">Package specification to check if installed</param>
        /// <returns>`true` if installed, `false` if not or not found.</returns>
        bool is_installed(const PackageSpec& spec) const;

        /// <summary>Find the StatusParagraph for given feature spec and return its install status</summary>
        /// <param name="spec">Feature specification to check if installed</param>
        /// <returns>`true` if installed, `false` if not or not found.</returns>
        bool is_installed(const FeatureSpec& spec) const;

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
