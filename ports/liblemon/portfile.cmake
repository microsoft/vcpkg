vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VERSION a278d16bd2d0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://lemon.cs.elte.hu/hg/lemon/archive/${VERSION}.zip"
    FILENAME "lemon-${VERSION}.zip"
    SHA512 db303a78a9f1235775917dd19af21f72358bbbce9292ea6d6a0475bdbf709d2c183089df4bad753b882012007c34662c463fb70ecfa37b565d7dc11443f11d07
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
