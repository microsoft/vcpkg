include_guard(GLOBAL)
function(vcpkg_find_acquire_meson out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unrecognized arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_find_acquire_python3_interpreter(PYTHON3 MIN_VERSION 3.6)

    set(ref 6b7fc8dc48b0d1546206057ca8f7e38fbb4d0bcc)
    vcpkg_find_acquire_tool(
        OUT_TOOL_COMMAND out_tool_command
        TOOL_NAME meson
        VERSION 0.63.3
        DOWNLOAD_FILENAME "meson-${ref}.tar.gz"
        SHA512 a8e8780d7185b54a2e3d023cc8754314d2d5bec9d875e81c9f4a9222e6173eec98011c6862777dbd6253b07186a8ff5623974d5f613f0442aaeb1740a0f5706e
        URLS "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz"
        SEARCH_NAMES meson meson.py
        APT_PACKAGE_NAME meson
        BREW_PACKAGE_NAME meson
        VERSION_COMMAND --version
        EXACT_VERSION
        INTERPRETER "${PYTHON3}"
        ARCHIVE_SUBDIRECTORY "meson-${ref}"
        PATCHES
            "${CMAKE_CURRENT_LIST_DIR}/meson-intl.patch"
    )

    set("${out_var}" ${out_tool_command} PARENT_SCOPE)
endfunction()
