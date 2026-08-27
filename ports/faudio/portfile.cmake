# FAudio uses calender versioning (e.g., 26.01), but vcpkg drops them in versions
string(REGEX REPLACE "^([0-9]+)\\.([1-9])$" "\\1.0\\2" FAUDIO_REF "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${FAUDIO_REF}"
    SHA512 07d262b2cb000b8d1d0419e38c3d6692c9eed4d01f0324b102a97f55b4830d330359b0d60456601aab6e22e80ebd4cd1badc71654512aff90d7f1f0a1ab8816d
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
