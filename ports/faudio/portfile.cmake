# FAudio uses calender versioning (e.g., 26.01), but vcpkg drops them in versions
string(REGEX REPLACE "^([0-9]+)\\.([1-9])$" "\\1.0\\2" FAUDIO_REF "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${FAUDIO_REF}"
    SHA512 3d1001caa1394b194e64a23ecbb859ab8a6d7f446d107b0554241df966a4123994dc6eccb78d21b89d4890aef5709db78534f5a6d775da44950ff6ebf1f6a669
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
