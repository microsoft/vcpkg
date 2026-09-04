# FAudio uses calender versioning (e.g., 26.01), but vcpkg drops them in versions
string(REGEX REPLACE "^([0-9]+)\\.([1-9])$" "\\1.0\\2" FAUDIO_REF "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${FAUDIO_REF}"
    SHA512 94a123767375a460e1cd87c582ec878adafa2cb976d9fb73f445e022ac9baa00bb2333c2f9c647911f0a6a0dcbb821cbe3e9c411f2bd77585121f1205a01fcc4
    HEAD_REF master
)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND options -DPLATFORM_WIN32=TRUE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FAudio)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    COMMENT [[
FAudio is licensed under the Zlib license.

The installed FAudio library also compiles in vendored stb and qoa components
from src/stb.h, src/stb_vorbis.h, and src/qoa_decoder.h. Those components are
available under the MIT license; the stb components also offer a public-domain
alternative.
]]
    FILE_LIST
       "${SOURCE_PATH}/LICENSE"
)
