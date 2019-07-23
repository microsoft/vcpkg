#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/binaryparagraph.h>
#include <vcpkg/parse.h>

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
        static const std::string EXTERNALFILES = "External-Files";
    }

    bool BinaryParagraph::is_consistent() const
    {
        switch (consistency)
        {
        case ConsistencyState::UNKNOWN :
            for (const auto& file_hash : external_files)
            {
                const auto& realfs = Files::get_real_filesystem();

                if (!realfs.is_regular_file(file_hash.first) ||
                    Hash::get_file_hash(realfs, file_hash.first, "SHA1") != file_hash.second)
                {
                    consistency = ConsistencyState::INCONSISTENT;
                    return false;
                }
            }

            consistency = ConsistencyState::CONSISTENT;
            return true;
        case ConsistencyState::CONSISTENT : return true;
        case ConsistencyState::INCONSISTENT : return false;
        }

        Checks::unreachable(VCPKG_LINE_INFO);
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
            this->spec = PackageSpec::from_name_and_triplet(name, Triplet::from_canonical_name(std::move(architecture)))
                             .value_or_exit(VCPKG_LINE_INFO);
        }

        // one or the other
        this->version = parser.optional_field(Fields::VERSION);
        this->feature = parser.optional_field(Fields::FEATURE);

        this->description = parser.optional_field(Fields::DESCRIPTION);
        this->maintainer = parser.optional_field(Fields::MAINTAINER);

        this->abi = parser.optional_field(Fields::ABI);

        std::string multi_arch;
        parser.required_field(Fields::MULTI_ARCH, multi_arch);

        this->depends = parse_comma_list(parser.optional_field(Fields::DEPENDS));
        if (this->feature.empty())
        {
            this->default_features = parse_comma_list(parser.optional_field(Fields::DEFAULTFEATURES));
        }

        std::vector<std::string> external_files_or_hashes =
            parse_comma_list(parser.optional_field(Fields::EXTERNALFILES));

        if (external_files_or_hashes.size() % 2 != 0)
        {
            Checks::exit_with_message(
                    VCPKG_LINE_INFO,
                    "The External-Files field is not composed of key-value pairs for ",
                    this->spec);
        }

        for (int i = 0; i < external_files_or_hashes.size(); i += 2)
        {
            external_files.emplace(
                    std::move(external_files_or_hashes[i]),
                    std::move(external_files_or_hashes[i+1]));
        }

        if (const auto err = parser.error_info(this->spec.to_string()))
        {
            System::print2(System::Color::error, "Error: while parsing the Binary Paragraph for ", this->spec, '\n');
            print_error_message(err);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // prefer failing above when possible because it gives better information
        Checks::check_exit(VCPKG_LINE_INFO, multi_arch == "same", "Multi-Arch must be 'same' but was %s", multi_arch);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh, const Triplet& triplet, const std::string& abi_tag)
        : version(spgh.version), description(spgh.description), maintainer(spgh.maintainer), abi(abi_tag)
    {
        this->spec = PackageSpec::from_name_and_triplet(spgh.name, triplet).value_or_exit(VCPKG_LINE_INFO);
        this->depends = filter_dependencies(spgh.depends, triplet);
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh, const FeatureParagraph& fpgh, const Triplet& triplet)
        : version(), description(fpgh.description), maintainer(), feature(fpgh.name)
    {
        this->spec = PackageSpec::from_name_and_triplet(spgh.name, triplet).value_or_exit(VCPKG_LINE_INFO);
        this->depends = filter_dependencies(fpgh.depends, triplet);
    }

    std::string BinaryParagraph::displayname() const
    {
        if (this->feature.empty() || this->feature == "core")
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
        if (!pgh.abi.empty()) out_str.append("Abi: ").append(pgh.abi).push_back('\n');
        if (!pgh.description.empty()) out_str.append("Description: ").append(pgh.description).push_back('\n');

        if (!pgh.external_files.empty())
        {
            out_str.append("External-Files: ");
            out_str.append(Strings::join(",",
                        Util::fmap(
                            pgh.external_files,
                            [](const std::pair<std::string, std::string>& kv)
                            {
                                return kv.first + "," + kv.second;
                            }))).push_back('\n');
        }
    }
}
