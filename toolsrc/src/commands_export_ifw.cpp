#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_Commands_Export.h"
#include "vcpkg_Commands_Export_IFW.h"

namespace vcpkg::Commands::Export::IFW
{
    using Dependencies::ExportPlanAction;
    using Dependencies::ExportPlanType;
    using Install::InstallDir;

    static std::string create_release_date()
    {
        const tm date_time = System::get_current_date_time();

        // Format is: YYYY-mm-dd
        // 10 characters + 1 null terminating character will be written for a total of 11 chars
        char mbstr[11];
        const size_t bytes_written = std::strftime(mbstr, sizeof(mbstr), "%Y-%m-%d", &date_time);
        Checks::check_exit(VCPKG_LINE_INFO,
            bytes_written == 10,
            "Expected 10 bytes to be written, but %u were written",
            bytes_written);
        const std::string date_time_as_string(mbstr);
        return date_time_as_string;
    }

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
                          Strings::format(
R"###(<?xml version="1.0"?>
<Package>
    <DisplayName>%s</DisplayName>
    <Version>%s</Version>
    <ReleaseDate>%s</ReleaseDate>
    <AutoDependOn>packages.%s:,triplets.%s:</AutoDependOn>
    <Virtual>true</Virtual>
</Package>
)###",
                                          action.spec.to_string(),
                                          binary_paragraph.version,
                                          create_release_date(),
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
        fs.write_contents(package_xml_file_path, Strings::format(
R"###(<?xml version="1.0"?>
<Package>
    <DisplayName>Packages</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>%s</ReleaseDate>
</Package>
)###",
            create_release_date()));

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

            if (!deps.empty()) deps = "\n    <Dependencies>" + deps + "</Dependencies>";

            fs.write_contents(package_xml_file_path,
                              Strings::format(
R"###(<?xml version="1.0"?>
<Package>
    <DisplayName>%s</DisplayName>
    <Description>%s</Description>
    <Version>%s</Version>
    <ReleaseDate>%s</ReleaseDate>%s
</Package>
)###",
                                              action.spec.name(),
                                              binary_paragraph.description,
                                              binary_paragraph.version,
                                              create_release_date(),
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
        fs.write_contents(package_xml_file_path, Strings::format(
R"###(<?xml version="1.0"?>
<Package>
    <DisplayName>Triplets</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>%s</ReleaseDate>
</Package>
)###",
            create_release_date()));

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
            fs.write_contents(package_xml_file_path, Strings::format(
R"###(<?xml version="1.0"?>
<Package>
    <DisplayName>%s</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>%s</ReleaseDate>
</Package>
)###",
                triplet,
                create_release_date()));
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

        fs.write_contents(package_xml_file_path, Strings::format(
R"###(<?xml version="1.0"?>
<Package>
    <DisplayName>Integration</DisplayName>
    <Version>1.0.0</Version>
    <ReleaseDate>%s</ReleaseDate>
</Package>
)###",
            create_release_date()));
    }

    void export_config(const std::string &export_id, const Options &ifw_options, const VcpkgPaths& paths)
    {
        std::error_code ec;
        Files::Filesystem& fs = paths.get_filesystem();

        const fs::path config_xml_file_path = ifw_options.maybe_config_file_path.has_value() ?
            fs::path(ifw_options.maybe_config_file_path.value_or_exit(VCPKG_LINE_INFO))
            : paths.root / (export_id + "-ifw-configuration") / "config.xml";

        fs::path config_xml_dir_path = config_xml_file_path.parent_path();
        fs.create_directories(config_xml_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Could not create directory for configuration file %s",
                           config_xml_file_path.generic_string());

        std::string formatted_repo_url;
        std::string ifw_repo_url = ifw_options.maybe_repository_url.value_or("");
        if (!ifw_repo_url.empty())
        {
            formatted_repo_url = Strings::format(R"###(
    <RemoteRepositories>
        <Repository>
            <Url>%s</Url>
        </Repository>
    </RemoteRepositories>)###",
                ifw_repo_url);
        }

        fs.write_contents(config_xml_file_path, Strings::format(
R"###(<?xml version="1.0"?>
<Installer>
    <Name>vcpkg</Name>
    <Version>1.0.0</Version>
    <TargetDir>@RootDir@/src/vcpkg</TargetDir>%s
</Installer>
)###",
            formatted_repo_url));

        System::println("Created ifw configuration file: %s", config_xml_file_path.generic_string());
    }

    void do_export(const std::vector<ExportPlanAction> &export_plan, const std::string &export_id, const Options &ifw_options, const VcpkgPaths& paths)
    {
        System::println("Creating ifw packages... ");

        std::error_code ec;
        Files::Filesystem& fs = paths.get_filesystem();

        const fs::path ifw_packages_dir_path = ifw_options.maybe_packages_dir_path.has_value() ?
            fs::path(ifw_options.maybe_packages_dir_path.value_or_exit(VCPKG_LINE_INFO))
            : paths.root / (export_id + "-ifw-packages");

        fs.remove_all(ifw_packages_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
            !ec,
            "Could not remove outdated packages directory %s",
            ifw_packages_dir_path.generic_string());

        fs.create_directory(ifw_packages_dir_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
            !ec,
            "Could not create packages directory %s",
            ifw_packages_dir_path.generic_string());

        // execute the plan
        std::map<std::string, const ExportPlanAction*> unique_packages;
        std::set<std::string> unique_triplets;
        for (const ExportPlanAction& action : export_plan)
        {
            if (action.plan_type != ExportPlanType::ALREADY_BUILT)
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }

            const std::string display_name = action.spec.to_string();
            System::println("Exporting package %s... ", display_name);

            const BinaryParagraph& binary_paragraph =
                action.any_paragraph.binary_control_file.value_or_exit(VCPKG_LINE_INFO).core_paragraph;

            unique_packages[action.spec.name()] = &action;
            unique_triplets.insert(action.spec.triplet().canonical_name());

            // Export real package and return data dir for installation
            fs::path ifw_package_dir_path = export_real_package(ifw_packages_dir_path, action, fs);

            // Copy package data
            const InstallDir dirs = InstallDir::from_destination_root(ifw_package_dir_path,
                action.spec.triplet().to_string(),
                ifw_package_dir_path / "vcpkg" / "info" /
                (binary_paragraph.fullstem() + ".list"));

            Install::install_files_and_write_listfile(paths.get_filesystem(), paths.package_dir(action.spec), dirs);
            System::println(System::Color::success, "Exporting package %s... done", display_name);
        }

        // Unique packages
        export_unique_packages(ifw_packages_dir_path, unique_packages, fs);

        // Unique triplets
        export_unique_triplets(ifw_packages_dir_path, unique_triplets, fs);

        // Copy files needed for integration
        export_integration_files(ifw_packages_dir_path / "integration" / "data", paths);
        // Integration
        export_integration(ifw_packages_dir_path, fs);

        System::println("Created ifw packages directory: %s", ifw_packages_dir_path.generic_string());

        // Configuration
        export_config(export_id, ifw_options, paths);
    }
}
