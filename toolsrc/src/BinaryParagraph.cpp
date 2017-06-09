#include "pch.h"

#include "BinaryParagraph.h"
#include "vcpkg_Checks.h"
#include "vcpkglib_helpers.h"

using namespace vcpkg::details;

namespace vcpkg
{
    namespace BinaryParagraphRequiredField
    {
        static const std::string PACKAGE = "Package";
        static const std::string VERSION = "Version";
        static const std::string ARCHITECTURE = "Architecture";
        static const std::string MULTI_ARCH = "Multi-Arch";
    }

    namespace BinaryParagraphOptionalField
    {
        static const std::string DESCRIPTION = "Description";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string DEPENDS = "Depends";
    }

    BinaryParagraph::BinaryParagraph() = default;

    BinaryParagraph::BinaryParagraph(std::unordered_map<std::string, std::string> fields)
    {
        const std::string name = details::remove_required_field(&fields, BinaryParagraphRequiredField::PACKAGE);
        const std::string architecture =
            details::remove_required_field(&fields, BinaryParagraphRequiredField::ARCHITECTURE);
        const Triplet triplet = Triplet::from_canonical_name(architecture);

        this->spec = PackageSpec::from_name_and_triplet(name, triplet).value_or_exit(VCPKG_LINE_INFO);
        this->version = details::remove_required_field(&fields, BinaryParagraphRequiredField::VERSION);

        this->description = details::remove_optional_field(&fields, BinaryParagraphOptionalField::DESCRIPTION);
        this->maintainer = details::remove_optional_field(&fields, BinaryParagraphOptionalField::MAINTAINER);

        std::string multi_arch = details::remove_required_field(&fields, BinaryParagraphRequiredField::MULTI_ARCH);
        Checks::check_exit(VCPKG_LINE_INFO, multi_arch == "same", "Multi-Arch must be 'same' but was %s", multi_arch);

        std::string deps = details::remove_optional_field(&fields, BinaryParagraphOptionalField::DEPENDS);
        this->depends = parse_comma_list(deps);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh, const Triplet& triplet)
    {
        this->spec = PackageSpec::from_name_and_triplet(spgh.name, triplet).value_or_exit(VCPKG_LINE_INFO);
        this->version = spgh.version;
        this->description = spgh.description;
        this->maintainer = spgh.maintainer;
        this->depends = filter_dependencies(spgh.depends, triplet);
    }

    std::string BinaryParagraph::displayname() const { return this->spec.to_string(); }

    std::string BinaryParagraph::dir() const { return this->spec.dir(); }

    std::string BinaryParagraph::fullstem() const
    {
        return Strings::format("%s_%s_%s", this->spec.name(), this->version, this->spec.triplet());
    }

    void serialize(const BinaryParagraph& pgh, std::string& out_str)
    {
        out_str.append("Package: ").append(pgh.spec.name()).push_back('\n');
        out_str.append("Version: ").append(pgh.version).push_back('\n');
        if (!pgh.depends.empty())
        {
            out_str.append("Depends: ");
            out_str.append(Strings::join(", ", pgh.depends));
            out_str.push_back('\n');
        }

        out_str.append("Architecture: ").append(pgh.spec.triplet().to_string()).push_back('\n');
        out_str.append("Multi-Arch: same\n");

        if (!pgh.maintainer.empty()) out_str.append("Maintainer: ").append(pgh.maintainer).push_back('\n');
        if (!pgh.description.empty()) out_str.append("Description: ").append(pgh.description).push_back('\n');
    }
}
