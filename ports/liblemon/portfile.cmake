vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VERSION ed2c21cbd6ef)

vcpkg_download_distfile(ARCHIVE
    URLS "https://lemon.cs.elte.hu/hg/lemon/archive/${VERSION}.zip"
    FILENAME "lemon-${VERSION}.zip"
    SHA512 849d99743a9c4eeee255fb09e586153cb41b7e1c159641665954af6f1d23f6fb830ce4d318aa39631a5ec6dce366d2f686a087bf62699c39733165a21c21bfd9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES
        fix-cmake.patch
        fix-cmake4.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=14
        -DLEMON_ENABLE_GLPK=OFF
        -DLEMON_ENABLE_ILOG=OFF
        -DLEMON_ENABLE_COIN=OFF
        -DLEMON_ENABLE_SOPLEX=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/lemon/cmake PACKAGE_NAME lemon)

vcpkg_fixup_pkgconfig()

file(GLOB EXE "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(COPY ${EXE} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/liblemon/")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/liblemon")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
