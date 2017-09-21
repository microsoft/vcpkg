#include "pch.h"

#include "vcpkg_Commands_Export_IFW.h"

namespace vcpkg::Commands::Export::IFW
{
    using Dependencies::ExportPlanAction;

    fs::path export_real_package(const fs::path& raw_exported_dir_path,
                                 const ExportPlanAction& action,
                                 Files::Filesystem& fs)
    {
        std::error_code ec;

        const BinaryParagraph& binary_paragraph =
            action.any_paragraph.binary_control_file.value_or_exit(VCPKG_LINE_INFO).core_paragraph;

        // Prepare meta dir
        const fs::path package_xml_file_path =
            raw_exported_dir_path /
            Strings::format("packages.%s.%s", action.spec.name(), action.spec.triplet().canonical_name()) / "meta" /
            "package.xml";
        const fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Could not create directory for package file %s",
                           package_xml_file_path.generic_string());

        fs.write_contents(package_xml_file_path,
                          Strings::format(R"###(
<?xml version=\"1.0\"?>
<Package>
    <DisplayName>%s</DisplayName>
    <Version>%s</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>
    <AutoDependsOn>packages.%s:,triplets.%s:</AutoDependsOn>
    <Virtual>true</Virtual>
    <Checkable>true</Checkable>
</Package>
)###",
                                          action.spec.to_string(),
                                          binary_paragraph.version,
                                          action.spec.name(),
                                          action.spec.triplet().canonical_name()));

        // Return dir path for export package data
        return raw_exported_dir_path /
               Strings::format("packages.%s.%s", action.spec.name(), action.spec.triplet().canonical_name()) / "data" /
               "installed";
    }

    void export_unique_packages(const fs::path& raw_exported_dir_path,
                                std::map<std::string, const ExportPlanAction*> unique_packages,
                                Files::Filesystem& fs)
    {
        std::error_code ec;

        // packages

        fs::path package_xml_file_path = raw_exported_dir_path / "packages" / "meta" / "package.xml";
        fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Could not create directory for package file %s",
                           package_xml_file_path.generic_string());
        fs.write_contents(package_xml_file_path, R"###(
<?xml version=\"1.0\"?>
<Package>
    <DisplayName>Packages</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>
    <Checkable>true</Checkable>
</Package>
)###");

        for (auto package = unique_packages.begin(); package != unique_packages.end(); ++package)
        {
            const ExportPlanAction& action = *(package->second);
            const BinaryParagraph& binary_paragraph =
                action.any_paragraph.binary_control_file.value_or_exit(VCPKG_LINE_INFO).core_paragraph;

            package_xml_file_path =
                raw_exported_dir_path / Strings::format("packages.%s", package->first) / "meta" / "package.xml";
            package_xml_dir_path = package_xml_file_path.parent_path();
            fs.create_directories(package_xml_dir_path, ec);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !ec,
                               "Could not create directory for package file %s",
                               package_xml_file_path.generic_string());

            auto deps = Strings::join(
                ",", binary_paragraph.depends, [](const std::string& dep) { return "packages." + dep + ":"; });

            if (!deps.empty()) deps = "\n    " + deps;

            fs.write_contents(package_xml_file_path,
                              Strings::format(R"###(
<?xml version=\"1.0\"?>
<Package>
    <DisplayName>%s</DisplayName>
    <Description>%s</Description>
    <Version>%s</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>%s
    <Checkable>true</Checkable>
</Package>
)###",
                                              action.spec.name(),
                                              binary_paragraph.description,
                                              binary_paragraph.version,
                                              deps));
        }
    }

    void export_unique_triplets(const fs::path& raw_exported_dir_path,
                                std::set<std::string> unique_triplets,
                                Files::Filesystem& fs)
    {
        std::error_code ec;

        // triplets

        fs::path package_xml_file_path = raw_exported_dir_path / "triplets" / "meta" / "package.xml";
        fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Could not create directory for package file %s",
                           package_xml_file_path.generic_string());
        fs.write_contents(package_xml_file_path, R"###(
<?xml version=\"1.0\"?>
<Package>
    <DisplayName>Triplets</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>
    <Checkable>true</Checkable>
</Package>
)###");

        for (const std::string& triplet : unique_triplets)
        {
            package_xml_file_path =
                raw_exported_dir_path / Strings::format("triplets.%s", triplet) / "meta" / "package.xml";
            package_xml_dir_path = package_xml_file_path.parent_path();
            fs.create_directories(package_xml_dir_path, ec);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !ec,
                               "Could not create directory for package file %s",
                               package_xml_file_path.generic_string());
            fs.write_contents(package_xml_file_path, Strings::format(R"###(
<?xml version=\"1.0\"?>
<Package>
    <DisplayName>%s</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>
    <Checkable>true</Checkable>
</Package>
)###", triplet));
        }
    }

    void export_integration(const fs::path& raw_exported_dir_path, Files::Filesystem& fs)
    {
        std::error_code ec;

        // integration
        fs::path package_xml_file_path = raw_exported_dir_path / "integration" / "meta" / "package.xml";
        fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Could not create directory for package file %s",
                           package_xml_file_path.generic_string());

        fs.write_contents(package_xml_file_path, R"###(
<?xml version=\"1.0\"?>
<Package>
    <DisplayName>Integration</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>
    <Checkable>true</Checkable>
</Package>
)###");
    }

    void export_config(const fs::path& raw_exported_dir_path,
                       const std::string ifw_repository_url,
                       Files::Filesystem& fs)
    {
        std::error_code ec;

        // config.xml
        fs::path config_xml_file_path = raw_exported_dir_path / "config.xml";
        fs::path config_xml_dir_path = config_xml_file_path.parent_path();
        fs.create_directories(config_xml_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Could not create directory for configuration file %s",
                           config_xml_file_path.generic_string());
        std::string formatted_repo_url;
        if (!ifw_repository_url.empty())
        {
            formatted_repo_url = Strings::format(R"###(
    <RemoteRepositories>
        <Repository>
            <Url>%s</Url>
        </Repository>
    </RemoteRepositories>
)###",
                                                 formatted_repo_url);
        }

        fs.write_contents(config_xml_file_path, Strings::format(R"###(
<?xml version=\"1.0\"?>
<Installer>
    <Name>vcpkg</Name>
    <Version>1.0.0</Version>
    <ReleaseDate>2017-08-31</ReleaseDate>
    <TargetDir>@RootDir@/src/vcpkg</TargetDir>%s
</Installer>
)###", formatted_repo_url));
    }
}
