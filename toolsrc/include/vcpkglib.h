#pragma once

#include "StatusParagraphs.h"
#include "vcpkg_paths.h"
#include "ImmutableSortedVector.h"

namespace vcpkg
{
    StatusParagraphs database_load_check(const vcpkg_paths& paths);

    void write_update(const vcpkg_paths& paths, const StatusParagraph& p);

    struct StatusParagraph_and_associated_files
    {
        StatusParagraph pgh;
        ImmutableSortedVector<std::string> files;
    };

    std::vector<StatusParagraph_and_associated_files> get_installed_files(const vcpkg_paths& paths, const StatusParagraphs& status_db);
} // namespace vcpkg
