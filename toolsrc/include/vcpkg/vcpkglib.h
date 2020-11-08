#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/sortedvector.h>

#include <vcpkg/statusparagraphs.h>

namespace vcpkg
{
    StatusParagraphs database_load_check(const VcpkgPaths& paths);

    void write_update(const VcpkgPaths& paths, const StatusParagraph& p);

    struct StatusParagraphAndAssociatedFiles
    {
        StatusParagraph pgh;
        SortedVector<std::string> files;
    };

    std::vector<InstalledPackageView> get_installed_ports(const StatusParagraphs& status_db);
    std::vector<StatusParagraphAndAssociatedFiles> get_installed_files(const VcpkgPaths& paths,
                                                                       const StatusParagraphs& status_db);

    std::string shorten_text(const std::string& desc, const size_t length);
} // namespace vcpkg
