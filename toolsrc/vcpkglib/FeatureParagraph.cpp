#include "pch.h"

#include "SourceParagraph.h"
#include "Triplet.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Util.h"

namespace vcpkg
{
    std::vector<SourceParagraph> getSourceParagraphs(const std::vector<SourceControlFile>& control_files)
    {
        return Util::fmap(control_files, [](const SourceControlFile& x) { return x.core_paragraph; });
    }
}