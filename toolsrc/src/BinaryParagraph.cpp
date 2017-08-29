#include "pch.h"

#include "BinaryParagraph.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Parse.h"

namespace vcpkg
{
    namespace Fields
    {
        static const std::string PACKAGE = "Package";
        static const std::string VERSION = "Version";
        static const std::string ARCHITECTURE = "Architecture";
        static const std::string MULTI_ARCH = "Multi-Arch";
    }

    namespace Fields
    {
        static const std::string FEATURE = "Feature";
        static const std::string DESCRIPTION = "Description";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string DEPENDS = "Depends";
        static const std::string DEFAULTFEATURES = "Default-Features";
    }

    BinaryParagraph::BinaryParagraph() = default;

    BinaryParagraph::BinaryParagraph(std::unordered_map<std::string, std::string> fields)
    {
        using namespace vcpkg::Parse;

        ParagraphParser parser(std::move(fields));

        {
            std::string name;
            parser.required_field(Fields::PACKAGE, name);
            std::string architecture;
            parser.required_field(Fields::ARCHITECTURE, architecture);
            this->spec = PackageSpec::from_name_and_triplet(name, Triplet::from_canonical_name(architecture))
                             .value_or_exit(VCPKG_LINE_INFO);
        }

        // one or the other
        this->version = parser.optional_field(Fields::VERSION);
        this->feature = parser.optional_field(Fields::FEATURE);

        this->description = parser.optional_field(Fields::DESCRIPTION);
        this->maintainer = parser.optional_field(Fields::MAINTAINER);

        std::string multi_arch;
        parser.required_field(Fields::MULTI_ARCH, multi_arch);

        this->depends = parse_comma_list(parser.optional_field(Fields::DEPENDS));
        if (this->feature.empty())
        {
            this->default_features = parse_comma_list(parser.optional_field(Fields::DEFAULTFEATURES));
        }

        if (const auto err = parser.error_info(this->spec.to_string()))
        {
            System::println(
                System::Color::error, "Error: while parsing the Binary Paragraph for %s", this->spec.to_string());
            print_error_message(err);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // prefer failing above when possible because it gives better information
        Checks::check_exit(VCPKG_LINE_INFO, multi_arch == "same", "Multi-Arch must be 'same' but was %s", multi_arch);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh, const Triplet& triplet)
    {
        this->spec = PackageSpec::from_name_and_triplet(spgh.name, triplet).value_or_exit(VCPKG_LINE_INFO);
        this->version = spgh.version;
        this->description = spgh.description;
        this->maintainer = spgh.maintainer;
        this->depends = filter_dependencies(spgh.depends, triplet);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh, const FeatureParagraph& fpgh, const Triplet& triplet)
    {
        this->spec = PackageSpec::from_name_and_triplet(spgh.name, triplet).value_or_exit(VCPKG_LINE_INFO);
        this->version = Strings::EMPTY;
        this->feature = fpgh.name;
        this->description = fpgh.description;
        this->maintainer = Strings::EMPTY;
        this->depends = filter_dependencies(fpgh.depends, triplet);
    }

    std::string BinaryParagraph::displayname() const
    {
        const auto f = this->feature.empty() ? "core" : this->feature;
        return Strings::format("%s[%s]:%s", this->spec.name(), f, this->spec.triplet());
    }

    std::string BinaryParagraph::dir() const { return this->spec.dir(); }

    std::string BinaryParagraph::fullstem() const
    {
        return Strings::format("%s_%s_%s", this->spec.name(), this->version, this->spec.triplet());
    }

    void serialize(const BinaryParagraph& pgh, std::string& out_str)
    {
        out_str.append("Package: ").append(pgh.spec.name()).push_back('\n');
        if (!pgh.version.empty())
            out_str.append("Version: ").append(pgh.version).push_back('\n');
        else if (!pgh.feature.empty())
            out_str.append("Feature: ").append(pgh.feature).push_back('\n');
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
