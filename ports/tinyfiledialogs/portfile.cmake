if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# git: not cachable
# tinyfiledialogs-current.zip: changing SHA512
# last resort: explicit source files
# Reviewers may compare git and zip sources at the time of the port update.
set(ref fe637654492cb8257cb68a8025dfc09ce3e0f490)
string(SUBSTRING "${ref}" 0 7 short_ref)
vcpkg_download_distfile(tinyfiledialogs_c_file
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${ref}/tree/tinyfiledialogs.c?format=raw"
    FILENAME "tinyfiledialogs-${short_ref}.c"
    SHA512 8cd199ddb3320a8096f9d5ad4bdab45e982a189fe94e96a978ed88ef7c4ead5c69863565088b0ff1c446fca93bcbde95e206d1b4cd3f5f7fd84ffcf2011fc9d1
)
vcpkg_download_distfile(tinyfiledialogs_h_file
    URLS "https://sourceforge.net/p/tinyfiledialogs/code/ci/${ref}/tree/tinyfiledialogs.h?format=raw"
    FILENAME "tinyfiledialogs-${short_ref}.h"
    SHA512 8deaf823a5f6e9ec85e958f15a0e6d29957ed48748624bb52abce32ba55c26dbf186b09a6c0048439f27f5bae390fd2fee03757756a1ea172dbb28735293bb8f
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
