#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/paragraphparser.h>

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
        static const std::string ABI = "Abi";
        static const std::string FEATURE = "Feature";
        static const std::string DESCRIPTION = "Description";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string DEPENDS = "Depends";
        static const std::string DEFAULTFEATURES = "Default-Features";
        static const std::string TYPE = "Type";
    }

    BinaryParagraph::BinaryParagraph() = default;

    BinaryParagraph::BinaryParagraph(Parse::Paragraph fields)
    {
        using namespace vcpkg::Parse;

        ParagraphParser parser(std::move(fields));

        {
            std::string name;
            parser.required_field(Fields::PACKAGE, name);
            std::string architecture;
            parser.required_field(Fields::ARCHITECTURE, architecture);
            this->spec = PackageSpec(std::move(name), Triplet::from_canonical_name(std::move(architecture)));
        }

        // one or the other
        this->version = parser.optional_field(Fields::VERSION);
        this->feature = parser.optional_field(Fields::FEATURE);

        this->description = parser.optional_field(Fields::DESCRIPTION);
        this->maintainer = parser.optional_field(Fields::MAINTAINER);

        this->abi = parser.optional_field(Fields::ABI);

        std::string multi_arch;
        parser.required_field(Fields::MULTI_ARCH, multi_arch);

        this->depends = Util::fmap(
            parse_qualified_specifier_list(parser.optional_field(Fields::DEPENDS)).value_or_exit(VCPKG_LINE_INFO),
            [](const ParsedQualifiedSpecifier& dep) {
                // for compatibility with previous vcpkg versions, we discard all irrelevant information
                return dep.name;
            });
        if (!this->is_feature())
        {
            this->default_features = parse_default_features_list(parser.optional_field(Fields::DEFAULTFEATURES))
                                         .value_or_exit(VCPKG_LINE_INFO);
        }

        this->type = Type::from_string(parser.optional_field(Fields::TYPE));

        if (const auto err = parser.error_info(this->spec.to_string()))
        {
            System::print2(System::Color::error, "Error: while parsing the Binary Paragraph for ", this->spec, '\n');
            print_error_message(err);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // prefer failing above when possible because it gives better information
        Checks::check_exit(VCPKG_LINE_INFO, multi_arch == "same", "Multi-Arch must be 'same' but was %s", multi_arch);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh,
                                     Triplet triplet,
                                     const std::string& abi_tag,
                                     const std::vector<FeatureSpec>& deps)
        : spec(spgh.name, triplet)
        , version(spgh.version)
        , description(spgh.description)
        , maintainer(spgh.maintainer)
        , abi(abi_tag)
        , type(spgh.type)
        , default_features(spgh.default_features)
    {
        this->depends = Util::fmap(deps, [](const FeatureSpec& spec) { return spec.spec().name(); });
        Util::sort_unique_erase(this->depends);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh,
                                     const FeatureParagraph& fpgh,
                                     Triplet triplet,
                                     const std ::vector<FeatureSpec>& deps)
        : spec(spgh.name, triplet)
        , version()
        , description(fpgh.description)
        , maintainer()
        , feature(fpgh.name)
        , type(spgh.type)
        , default_features()
    {
        this->depends = Util::fmap(deps, [](const FeatureSpec& spec) { return spec.spec().name(); });
        Util::sort_unique_erase(this->depends);
    }

    std::string BinaryParagraph::displayname() const
    {
        if (!this->is_feature() || this->feature == "core")
            return Strings::format("%s:%s", this->spec.name(), this->spec.triplet());
        return Strings::format("%s[%s]:%s", this->spec.name(), this->feature, this->spec.triplet());
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
        else if (pgh.is_feature())
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
        if (!pgh.abi.empty()) out_str.append("Abi: ").append(pgh.abi).push_back('\n');
        if (!pgh.description.empty()) out_str.append("Description: ").append(pgh.description).push_back('\n');

        out_str.append("Type: ").append(Type::to_string(pgh.type)).push_back('\n');
        if (!pgh.default_features.empty())
            out_str.append("Default-Features: ").append(Strings::join(", ", pgh.default_features)).push_back('\n');
    }
}
