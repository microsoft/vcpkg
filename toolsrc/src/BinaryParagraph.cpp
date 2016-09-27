#include "BinaryParagraph.h"
#include "vcpkglib_helpers.h"
#include "vcpkg_Checks.h"

using namespace vcpkg::details;

namespace vcpkg
{
    BinaryParagraph::BinaryParagraph() = default;

    BinaryParagraph::BinaryParagraph(const std::unordered_map<std::string, std::string>& fields) :
        name(required_field(fields, "Package")),
        version(required_field(fields, "Version")),
        description(optional_field(fields, "Description")),
        maintainer(optional_field(fields, "Maintainer"))
    {
        target_triplet.value = required_field(fields, "Architecture");
        {
            std::string multi_arch = required_field(fields, "Multi-Arch");
            Checks::check_throw(multi_arch == "same", "Multi-Arch must be 'same' but was %s", multi_arch);
        }

        std::string deps = optional_field(fields, "Depends");
        if (!deps.empty())
        {
            this->depends.clear();
            this->depends = parse_depends(deps);
        }
    }

    BinaryParagraph::BinaryParagraph(const SourceParagraph& spgh, const triplet& target_triplet)
    {
        this->name = spgh.name;
        this->version = spgh.version;
        this->description = spgh.description;
        this->maintainer = spgh.maintainer;
        this->depends = spgh.depends;
        this->target_triplet = target_triplet;
    }

    std::string BinaryParagraph::displayname() const
    {
        return Strings::format("%s:%s", this->name, this->target_triplet);
    }

    std::string BinaryParagraph::dir() const
    {
        return Strings::format("%s_%s", this->name, this->target_triplet);
    }

    std::string BinaryParagraph::fullstem() const
    {
        return Strings::format("%s_%s_%s", this->name, this->version, this->target_triplet);
    }

    std::ostream& operator<<(std::ostream& os, const BinaryParagraph& p)
    {
        os << "Package: " << p.name << "\n";
        os << "Version: " << p.version << "\n";
        if (!p.depends.empty())
        {
            os << "Depends: " << p.depends.front();

            auto b = p.depends.begin() + 1;
            auto e = p.depends.end();
            for (; b != e; ++b)
            {
                os << ", " << *b;
            }

            os << "\n";
        }
        os << "Architecture: " << p.target_triplet << "\n";
        os << "Multi-Arch: same\n";
        if (!p.maintainer.empty())
            os << "Maintainer: " << p.maintainer << "\n";
        if (!p.description.empty())
            os << "Description: " << p.description << "\n";
        return os;
    }
}
