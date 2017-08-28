#include "pch.h"

#include "vcpkg_Commands_Export_IFW.h"

namespace vcpkg::Commands::Export::IFW
{
    using Dependencies::ExportPlanAction;

    fs::path export_real_package(const fs::path &raw_exported_dir_path, const ExportPlanAction& action, Files::Filesystem& fs)
    {
        std::error_code ec;

        const BinaryParagraph& binary_paragraph =
            action.any_paragraph.binary_control_file.value_or_exit(VCPKG_LINE_INFO).core_paragraph;

        // Prepare meta dir
        const fs::path package_xml_file_path = raw_exported_dir_path / Strings::format("packages.%s.%s", action.spec.name(), action.spec.triplet().canonical_name()) / "meta" / "package.xml";
        const fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create directory for package file %s", package_xml_file_path.generic_string());
        std::vector<std::string> lines;
        std::string line; std::string skip = "    ";
        line = "<?xml version=\"1.0\"?>";
        lines.push_back(line); line.clear();
        line += "<Package>";
        lines.push_back(line); line = skip;
        line += "<DisplayName>";
        line += action.spec.to_string();
        line += "</DisplayName>";
        lines.push_back(line); line = skip;
        line += "<Version>";
        line += binary_paragraph.version; // TODO: Check IFW version format
        line += "</Version>";
        lines.push_back(line); line = skip;
        line += "<ReleaseDate>";
        line += "2017-08-31"; // TODO: Get real package release date
        line += "</ReleaseDate>";
        //if (!binary_paragraph.depends.empty())
        //{
        //    lines.push_back(line); line = skip;
        //    line += "<Dependencies>";
        ////    line += Strings::format("triplets.%s:", action.spec.triplet().canonical_name());
        //    line += Strings::format("packages.%s.%s:", binary_paragraph.depends[0], action.spec.triplet().canonical_name());
        //    for (size_t i = 1; i < binary_paragraph.depends.size(); ++i)
        //    {
        //        line += Strings::format(",packages.%s.%s:", binary_paragraph.depends[i], action.spec.triplet().canonical_name());
        //    }
        //    line += "</Dependencies>";
        //}
        lines.push_back(line); line = skip;
        line += "<AutoDependOn>";
        line += Strings::format("packages.%s:,triplets.%s:", action.spec.name(), action.spec.triplet().canonical_name());
        line += "</AutoDependOn>";
        lines.push_back(line); line = skip;
        line += "<Virtual>";
        line += "true"; // NOTE: hide real package
        line += "</Virtual>";
        lines.push_back(line); line = skip;
        line += "<Checkable>";
        line += "true";
        line += "</Checkable>";
        lines.push_back(line); line.clear();
        line = "</Package>";
        lines.push_back(line); line.clear();
        fs.write_lines(package_xml_file_path, lines);

        // Return dir path for export package data
        return raw_exported_dir_path / Strings::format("packages.%s.%s", action.spec.name(), action.spec.triplet().canonical_name()) / "data" / "installed";
    }

    void export_unique_packages(const fs::path &raw_exported_dir_path, std::map<std::string, const ExportPlanAction*> unique_packages, Files::Filesystem& fs)
    {
        std::error_code ec;

        // packages

        fs::path package_xml_file_path = raw_exported_dir_path / "packages" / "meta" / "package.xml";
        fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create directory for package file %s", package_xml_file_path.generic_string());
        std::vector<std::string> lines;
        std::string line; std::string skip = "    ";
        line = "<?xml version=\"1.0\"?>";
        lines.push_back(line); line.clear();
        line += "<Package>";
        lines.push_back(line); line = skip;
        line += "<DisplayName>";
        line += "Packages";
        line += "</DisplayName>";
        lines.push_back(line); line = skip;
        line = "<Version>";
        line += "1.0.0"; // TODO: Get real packages package version
        line += "</Version>";
        lines.push_back(line); line = skip;
        line += "<ReleaseDate>";
        line += "2017-08-31"; // TODO: Get real package release date
        line += "</ReleaseDate>";
        lines.push_back(line); line = skip;
        line += "<Checkable>";
        line += "true";
        line += "</Checkable>";
        lines.push_back(line); line.clear();
        line = "</Package>";
        lines.push_back(line); line.clear();
        fs.write_lines(package_xml_file_path, lines);

        for (auto package = unique_packages.begin(); package != unique_packages.end(); ++package)
        {
            const ExportPlanAction& action = *(package->second);
            const BinaryParagraph& binary_paragraph =
                action.any_paragraph.binary_control_file.value_or_exit(VCPKG_LINE_INFO).core_paragraph;

            package_xml_file_path = raw_exported_dir_path / Strings::format("packages.%s", package->first) / "meta" / "package.xml";
            package_xml_dir_path = package_xml_file_path.parent_path();
            fs.create_directories(package_xml_dir_path, ec);
            Checks::check_exit(
                VCPKG_LINE_INFO, !ec, "Could not create directory for package file %s", package_xml_file_path.generic_string());
            lines.clear();
            line.clear();
            skip = "    ";
            line = "<?xml version=\"1.0\"?>";
            lines.push_back(line); line.clear();
            line += "<Package>";
            lines.push_back(line); line = skip;
            line += "<DisplayName>";
            line += action.spec.name();
            line += "</DisplayName>";
            lines.push_back(line); line = skip;
            line += "<Description>";
            line += binary_paragraph.description;
            line += "</Description>";
            lines.push_back(line); line = skip;
            line += "<Version>";
            line += binary_paragraph.version; // TODO: Check IFW version format
            line += "</Version>";
            lines.push_back(line); line = skip;
            line += "<ReleaseDate>";
            line += "2017-08-31"; // TODO: Get real package release date
            line += "</ReleaseDate>";
            if (!binary_paragraph.depends.empty())
            {
                lines.push_back(line); line = skip;
                line += "<Dependencies>";
                line += Strings::format("packages.%s:", binary_paragraph.depends[0]);
                for (size_t i = 1; i < binary_paragraph.depends.size(); ++i)
                {
                    line += Strings::format(",packages.%s:", binary_paragraph.depends[i]);
                }
                line += "</Dependencies>";
            }
            lines.push_back(line); line = skip;
            line += "<Checkable>";
            line += "true";
            line += "</Checkable>";
            lines.push_back(line); line.clear();
            line = "</Package>";
            lines.push_back(line); line.clear();
            fs.write_lines(package_xml_file_path, lines);
        }
    }

    void export_unique_triplets(const fs::path &raw_exported_dir_path, std::set<std::string> unique_triplets, Files::Filesystem& fs)
    {
        std::error_code ec;

        // triplets

        fs::path package_xml_file_path = raw_exported_dir_path / "triplets" / "meta" / "package.xml";
        fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create directory for package file %s", package_xml_file_path.generic_string());
        std::vector<std::string> lines;
        std::string line; std::string skip = "    ";
        line = "<?xml version=\"1.0\"?>";
        lines.push_back(line); line.clear();
        line += "<Package>";
        lines.push_back(line); line = skip;
        line += "<DisplayName>";
        line += "Triplets";
        line += "</DisplayName>";
        lines.push_back(line); line = skip;
        line = "<Version>";
        line += "1.0.0"; // TODO: Get real triplits package version
        line += "</Version>";
        lines.push_back(line); line = skip;
        line += "<ReleaseDate>";
        line += "2017-08-31"; // TODO: Get real package release date
        line += "</ReleaseDate>";
        lines.push_back(line); line = skip;
        line += "<Checkable>";
        line += "true";
        line += "</Checkable>";
        lines.push_back(line); line.clear();
        line = "</Package>";
        lines.push_back(line); line.clear();
        fs.write_lines(package_xml_file_path, lines);

        for (const std::string &triplet : unique_triplets)
        {
            package_xml_file_path = raw_exported_dir_path / Strings::format("triplets.%s", triplet) / "meta" / "package.xml";
            package_xml_dir_path = package_xml_file_path.parent_path();
            fs.create_directories(package_xml_dir_path, ec);
            Checks::check_exit(
                VCPKG_LINE_INFO, !ec, "Could not create directory for package file %s", package_xml_file_path.generic_string());
            lines.clear();
            line.clear();
            skip = "    ";
            line = "<?xml version=\"1.0\"?>";
            lines.push_back(line); line.clear();
            line += "<Package>";
            lines.push_back(line); line = skip;
            line += "<DisplayName>";
            line += triplet;
            line += "</DisplayName>";
            lines.push_back(line); line = skip;
            line += "<Version>";
            line += "1.0.0"; // TODO: Get real package version
            line += "</Version>";
            lines.push_back(line); line = skip;
            line += "<ReleaseDate>";
            line += "2017-08-31"; // TODO: Get real package release date
            line += "</ReleaseDate>";
            lines.push_back(line); line = skip;
            line += "<Checkable>";
            line += "true";
            line += "</Checkable>";
            lines.push_back(line); line.clear();
            line = "</Package>";
            lines.push_back(line); line.clear();
            fs.write_lines(package_xml_file_path, lines);
        }
    }

    void export_integration(const fs::path &raw_exported_dir_path, Files::Filesystem& fs)
    {
        std::error_code ec;

        // integration
        fs::path package_xml_file_path = raw_exported_dir_path / "integration" / "meta" / "package.xml";
        fs::path package_xml_dir_path = package_xml_file_path.parent_path();
        fs.create_directories(package_xml_dir_path, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create directory for package file %s", package_xml_file_path.generic_string());
        std::vector<std::string> lines;
        std::string line; std::string skip = "    ";
        line = "<?xml version=\"1.0\"?>";
        lines.push_back(line); line.clear();
        line += "<Package>";
        lines.push_back(line); line = skip;
        line += "<DisplayName>";
        line += "Integration";
        line += "</DisplayName>";
        lines.push_back(line); line = skip;
        line = "<Version>";
        line += "1.0.0"; // TODO: Get real integration package version
        line += "</Version>";
        lines.push_back(line); line = skip;
        line += "<ReleaseDate>";
        line += "2017-08-31"; // TODO: Get real package release date
        line += "</ReleaseDate>";
        lines.push_back(line); line.clear();
        line = "</Package>";
        lines.push_back(line); line.clear();
        fs.write_lines(package_xml_file_path, lines);
    }

    void export_config(const fs::path &raw_exported_dir_path, const std::string ifw_repository_url, Files::Filesystem& fs)
    {
        std::error_code ec;

        // config.xml
        fs::path config_xml_file_path = raw_exported_dir_path / "config.xml";
        fs::path config_xml_dir_path = config_xml_file_path.parent_path();
        fs.create_directories(config_xml_dir_path, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create directory for configuration file %s", config_xml_file_path.generic_string());
        std::vector<std::string> lines;
        std::string line; std::string skip = "    ";
        line = "<?xml version=\"1.0\"?>";
        lines.push_back(line); line.clear();
        line += "<Installer>";
        lines.push_back(line); line = skip;
        line += "<Name>";
        line += "vcpkg";
        line += "</Name>";
        lines.push_back(line); line = skip;
        line += "<Version>";
        line += "1.0.0"; // TODO: Get real vcpkg installer version
        line += "</Version>";
        //lines.push_back(line); line = skip;
        //line += "<AllowAllInNameAndVersion>true</AllowAllInNameAndVersion>";
        lines.push_back(line); line = skip;
        line += "<TargetDir>";
        line += "@RootDir@/src/vcpkg";
        line += "</TargetDir>";
        if (!ifw_repository_url.empty())
        {
            lines.push_back(line); line = skip;
            line += "<RemoteRepositories>";
            lines.push_back(line); line = skip + skip;
            line += "<Repository>";
            lines.push_back(line); line = skip + skip + skip;
            line += "<Url>";
            line += ifw_repository_url;
            line += "</Url>";
            lines.push_back(line); line = skip + skip;
            line += "</Repository>";
            lines.push_back(line); line = skip;
            line += "</RemoteRepositories>";
        }
        lines.push_back(line); line.clear();
        line = "</Installer>";
        lines.push_back(line); line.clear();
        fs.write_lines(config_xml_file_path, lines);
    }
}
