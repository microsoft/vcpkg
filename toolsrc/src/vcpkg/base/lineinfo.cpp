#include "pch.h"

#include <vcpkg/base/lineinfo.h>
#include <vcpkg/base/strings.h>

namespace vcpkg
{
    std::string LineInfo::to_string() const { return Strings::format("%s(%d)", this->file_name, this->line_number); }
}
