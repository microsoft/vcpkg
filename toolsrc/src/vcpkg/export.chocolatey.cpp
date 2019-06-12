#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/commands.h>
#include <vcpkg/export.h>
#include <vcpkg/export.chocolatey.h>
#include <vcpkg/install.h>

namespace vcpkg::Export::Chocolatey
{
    using Dependencies::ExportPlanAction;
    using Dependencies::ExportPlanType;
    using Install::InstallDir;

    static std::string create_nuspec_file_contents(const std::string& exported_root_dir,
                                                   const BinaryParagraph& binary_paragraph)
    {
        static constexpr auto CONTENT_TEMPLATE = R"(
<package>
    <metadata>
        <id>@PACKAGE_ID@</id>
        <version>@PACKAGE_VERSION@</version>
        <description><![CDATA[
            @PACKAGE_DESCRIPTION@
        ]]></description>
    </metadata>
    <files>
        <file src="@EXPORTED_ROOT_DIR@\installed\**" target="installed" />
    </files>
</package>
)";

        std::string nuspec_file_content = Strings::replace_all(CONTENT_TEMPLATE, "@PACKAGE_ID@", binary_paragraph.spec.name());
        nuspec_file_content = Strings::replace_all(std::move(nuspec_file_content), "@PACKAGE_VERSION@", binary_paragraph.version);
        nuspec_file_content =
            Strings::replace_all(std::move(nuspec_file_content), "@PACKAGE_DESCRIPTION@", binary_paragraph.description);
        nuspec_file_content =
            Strings::replace_all(std::move(nuspec_file_content), "@EXPORTED_ROOT_DIR@", exported_root_dir);
        return nuspec_file_content;
    }

    void do_export(const std::vector<ExportPlanAction>& export_plan,
                   const VcpkgPaths& paths)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path export_to_path = paths.root;
        const fs::path raw_exported_dir_path = export_to_path / "test-chocolatey";

        std::error_code ec;
        fs.remove_all(raw_exported_dir_path, ec);
        fs.create_directory(raw_exported_dir_path, ec);

        // execute the plan
        for (const ExportPlanAction& action : export_plan)
        {
            if (action.plan_type != ExportPlanType::ALREADY_BUILT)
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }

            const std::string display_name = action.spec.to_string();
            System::print2("Exporting package ", display_name, "...\n");

            const fs::path per_package_dir_path = raw_exported_dir_path / action.spec.name();

            const BinaryParagraph& binary_paragraph = action.core_paragraph().value_or_exit(VCPKG_LINE_INFO);

            const InstallDir dirs = InstallDir::from_destination_root(
                per_package_dir_path / "installed",
                action.spec.triplet().to_string(),
                per_package_dir_path / "installed" / "vcpkg" / "info" / (binary_paragraph.fullstem() + ".list"));

            Install::install_files_and_write_listfile(paths.get_filesystem(), paths.package_dir(action.spec), dirs);

            const std::string nuspec_file_content =
                create_nuspec_file_contents(raw_exported_dir_path.string(), binary_paragraph);
            const fs::path nuspec_file_path = per_package_dir_path / Strings::concat(binary_paragraph.spec.name(), ".nuspec");
            fs.write_contents(nuspec_file_path, nuspec_file_content);
        }
    }
}
