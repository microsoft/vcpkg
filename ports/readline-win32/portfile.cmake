vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaozhuai/readline-win32
    REF 2b94fbb51f5da90b7bbd9b236da80be6f798e014
    SHA512 1285625ca6c608b98d13a783dd34461782bd88026bc09e6c9e70fd343e28561d1d7e5392b8068e52e93308029544276bdbc8ca12703c8976836561777a03dc17
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-readline-win32)
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/readline/rlstdc.h"
        "defined(USE_READLINE_STATIC)" "1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
