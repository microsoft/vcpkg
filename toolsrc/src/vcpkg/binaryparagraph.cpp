#include <vcpkg/base/checks.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/paragraphs.h>

namespace vcpkg
{
    namespace Fields
    {
        static const std::string PACKAGE = "Package";
        static const std::string VERSION = "Version";
        static const std::string PORT_VERSION = "Port-Version";
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
        static const std::string DEFAULT_FEATURES = "Default-Features";
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

        auto pv_str = parser.optional_field(Fields::PORT_VERSION);
        this->port_version = 0;
        if (!pv_str.empty())
        {
            auto pv_opt = Strings::strto<int>(pv_str);
            if (auto pv = pv_opt.get())
            {
                this->port_version = *pv;
            }
            else
            {
                parser.add_type_error(Fields::PORT_VERSION, "a non-negative integer");
            }
        }

        this->description = Strings::split(parser.optional_field(Fields::DESCRIPTION), '\n');
        for (auto& desc : this->description)
        {
            desc = Strings::trim(std::move(desc));
        }
        this->maintainers = Strings::split(parser.optional_field(Fields::MAINTAINER), '\n');
        for (auto& maintainer : this->maintainers)
        {
            maintainer = Strings::trim(std::move(maintainer));
        }

        this->abi = parser.optional_field(Fields::ABI);

        std::string multi_arch;
        parser.required_field(Fields::MULTI_ARCH, multi_arch);

        this->dependencies = Util::fmap(
            parse_qualified_specifier_list(parser.optional_field(Fields::DEPENDS)).value_or_exit(VCPKG_LINE_INFO),
            [](const ParsedQualifiedSpecifier& dep) {
                // for compatibility with previous vcpkg versions, we discard all irrelevant information
                return dep.name;
            });
        if (!this->is_feature())
        {
            this->default_features = parse_default_features_list(parser.optional_field(Fields::DEFAULT_FEATURES))
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
        , port_version(spgh.port_version)
        , description(spgh.description)
        , maintainers(spgh.maintainers)
        , feature()
        , default_features(spgh.default_features)
        , dependencies()
        , abi(abi_tag)
        , type(spgh.type)
    {
        this->dependencies = Util::fmap(deps, [](const FeatureSpec& spec) { return spec.spec().name(); });
        Util::sort_unique_erase(this->dependencies);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh,
                                     const FeatureParagraph& fpgh,
                                     Triplet triplet,
                                     const std ::vector<FeatureSpec>& deps)
        : spec(spgh.name, triplet)
        , version()
        , port_version()
        , description(fpgh.description)
        , maintainers()
        , feature(fpgh.name)
        , default_features()
        , dependencies()
        , abi()
        , type(spgh.type)
    {
        this->dependencies = Util::fmap(deps, [](const FeatureSpec& spec) { return spec.spec().name(); });
        Util::sort_unique_erase(this->dependencies);
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

    bool operator==(const BinaryParagraph& lhs, const BinaryParagraph& rhs)
    {
        if (lhs.spec != rhs.spec) return false;
        if (lhs.version != rhs.version) return false;
        if (lhs.port_version != rhs.port_version) return false;
        if (lhs.description != rhs.description) return false;
        if (lhs.maintainers != rhs.maintainers) return false;
        if (lhs.feature != rhs.feature) return false;
        if (lhs.default_features != rhs.default_features) return false;
        if (lhs.dependencies != rhs.dependencies) return false;
        if (lhs.abi != rhs.abi) return false;
        if (lhs.type != rhs.type) return false;

        return true;
    }

    bool operator!=(const BinaryParagraph& lhs, const BinaryParagraph& rhs) { return !(lhs == rhs); }

    static void serialize_string(StringView name, const std::string& field, std::string& out_str)
    {
        if (field.empty())
        {
            return;
        }

        out_str.append(name.begin(), name.end()).append(": ").append(field).push_back('\n');
    }
    static void serialize_array(StringView name,
                                const std::vector<std::string>& array,
                                std::string& out_str,
                                const char* joiner = ", ")
    {
        if (array.empty())
        {
            return;
        }

        out_str.append(name.begin(), name.end()).append(": ");
        out_str.append(Strings::join(joiner, array));
        out_str.push_back('\n');
    }
    static void serialize_paragraph(StringView name, const std::vector<std::string>& array, std::string& out_str)
    {
        serialize_array(name, array, out_str, "\n    ");
    }

    void serialize(const BinaryParagraph& pgh, std::string& out_str)
    {
        const size_t initial_end = out_str.size();

        serialize_string(Fields::PACKAGE, pgh.spec.name(), out_str);

        serialize_string(Fields::VERSION, pgh.version, out_str);
        if (pgh.port_version != 0)
        {
            out_str.append(Fields::PORT_VERSION).append(": ").append(std::to_string(pgh.port_version)).push_back('\n');
        }

        if (pgh.is_feature())
        {
            serialize_string(Fields::FEATURE, pgh.feature, out_str);
        }

        if (!pgh.dependencies.empty())
        {
            serialize_array(Fields::DEPENDS, pgh.dependencies, out_str);
        }

        serialize_string(Fields::ARCHITECTURE, pgh.spec.triplet().to_string(), out_str);
        serialize_string(Fields::MULTI_ARCH, "same", out_str);

        serialize_paragraph(Fields::MAINTAINER, pgh.maintainers, out_str);

        serialize_string(Fields::ABI, pgh.abi, out_str);

        serialize_paragraph(Fields::DESCRIPTION, pgh.description, out_str);

        serialize_string(Fields::TYPE, Type::to_string(pgh.type), out_str);
        serialize_array(Fields::DEFAULT_FEATURES, pgh.default_features, out_str);

        // sanity check the serialized data
        const auto my_paragraph = out_str.substr(initial_end);
        auto parsed_paragraph = Paragraphs::parse_single_paragraph(
            out_str.substr(initial_end), "vcpkg::serialize(const BinaryParagraph&, std::string&)");
        if (!parsed_paragraph.has_value())
        {
            Checks::exit_with_message(VCPKG_LINE_INFO,
                                      R"([sanity check] Failed to parse a serialized binary paragraph.
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:
    Error: %s

=== Serialized BinaryParagraph ===
%s
            )",
                                      parsed_paragraph.error(),
                                      my_paragraph);
        }

        auto binary_paragraph = BinaryParagraph(*parsed_paragraph.get());
        if (binary_paragraph != pgh)
        {
            const auto& join_str = R"(", ")";
            Checks::exit_with_message(
                VCPKG_LINE_INFO,
                R"([sanity check] The serialized binary paragraph was different from the original binary paragraph.
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:

=== Original BinaryParagraph ===
spec: "%s"
version: "%s"
port_version: %d
description: ["%s"]
maintainers: ["%s"]
feature: "%s"
default_features: ["%s"]
dependencies: ["%s"]
abi: "%s"
type: %s

=== Serialized BinaryParagraph ===
spec: "%s"
version: "%s"
port_version: %d
description: ["%s"]
maintainers: ["%s"]
feature: "%s"
default_features: ["%s"]
dependencies: ["%s"]
abi: "%s"
type: %s
)",
                pgh.spec.to_string(),
                pgh.version,
                pgh.port_version,
                Strings::join(join_str, pgh.description),
                Strings::join(join_str, pgh.maintainers),
                pgh.feature,
                Strings::join(join_str, pgh.default_features),
                Strings::join(join_str, pgh.dependencies),
                pgh.abi,
                Type::to_string(pgh.type),
                binary_paragraph.spec.to_string(),
                binary_paragraph.version,
                binary_paragraph.port_version,
                Strings::join(join_str, binary_paragraph.description),
                Strings::join(join_str, binary_paragraph.maintainers),
                binary_paragraph.feature,
                Strings::join(join_str, binary_paragraph.default_features),
                Strings::join(join_str, binary_paragraph.dependencies),
                binary_paragraph.abi,
                Type::to_string(binary_paragraph.type));
        }
    }
}
