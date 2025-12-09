if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# git: not cachable
# tinyfiledialogs-current.zip: changing SHA512
# last resort: explicit source files
# Reviewers may compare git and zip sources at the time of the port update.
set(ref b071fb40ad9b321408d480a6d1433bf21be01578)
string(SUBSTRING "${ref}" 0 7 short_ref)
vcpkg_download_distfile(tinyfiledialogs_c_file
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${ref}/tree/tinyfiledialogs.c?format=raw"
    FILENAME "tinyfiledialogs-${short_ref}.c"
    SHA512 cc8dd57d47ed9b449d91a66dad421140ef2aa8da00c622c0de3c13c9587ff1b7165343b61e40a2240eef7d15dc27fe28bd4595c89b52e3775060229a7c8a5926
)
vcpkg_download_distfile(tinyfiledialogs_h_file
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${ref}/tree/tinyfiledialogs.h?format=raw"
    FILENAME "tinyfiledialogs-${short_ref}.h"
    SHA512 7b95aa5e32065aee9d16a7cafe644ed93bc9e4cd139882f0298572da1418305ce30d0770e1a6f2b441fb7d9bcb710d57b54ca3c2eb67c9fd5f04c0fdbece31bf
)

file(READ "${tinyfiledialogs_c_file}" c_source)
if(NOT c_source MATCHES "tinyfd_version.8. = \"([^\"]*)\"" OR NOT CMAKE_MATCH_1 STREQUAL VERSION)
    message(FATAL_ERROR "Source doesn't declare match version ${VERSION}.")
elseif(NOT c_source MATCHES [[- License -[\r\n]*(.*)]])
    message(FATAL_ERROR "Failed to parse license from tinyfiledialogs.c")
endif()
string(REGEX REPLACE " *__*.*" "" license "${CMAKE_MATCH_1}")

set(source_path "${CURRENT_BUILDTREES_DIR}/src/${short_ref}")
file(MAKE_DIRECTORY "${source_path}")
file(COPY_FILE "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${source_path}/CMakeLists.txt")
file(COPY_FILE "${tinyfiledialogs_c_file}" "${source_path}/tinyfiledialogs.c")
file(COPY_FILE "${tinyfiledialogs_h_file}" "${source_path}/tinyfiledialogs.h")

vcpkg_cmake_configure(
    SOURCE_PATH "${source_path}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${license}")
