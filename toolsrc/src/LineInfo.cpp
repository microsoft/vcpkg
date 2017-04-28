#include "pch.h"

#include "LineInfo.h"
#include "vcpkg_Strings.h"

namespace vcpkg
{
    std::string LineInfo::to_string() const { return Strings::format("%s(%d)", this->file_name, this->line_number); }
}
