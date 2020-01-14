include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(PIXMAN_VERSION 0.38.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz"
    FILENAME "pixman-${PIXMAN_VERSION}.tar.gz"
    SHA512 b66dc23c0bc7327cb90085cbc14ccf96ad58001a927f23af24e0258ca13f32d4255535862f1efcf00e9e723410aa9f51edf26fb01c8cde49379d1225acf7b5af
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PIXMAN_VERSION}
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/pixman)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}/pixman
        PREFER_NINJA
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-pixman TARGET_PATH share/unofficial-pixman)

    file(COPY
        "${SOURCE_PATH}/pixman/pixman.h"
        "${SOURCE_PATH}/pixman/pixman-accessor.h"
        "${SOURCE_PATH}/pixman/pixman-combine32.h"
        "${SOURCE_PATH}/pixman/pixman-compiler.h"
        "${SOURCE_PATH}/pixman/pixman-edge-imp.h"
        "${SOURCE_PATH}/pixman/pixman-inlines.h"
        "${SOURCE_PATH}/pixman/pixman-private.h"
        "${SOURCE_PATH}/pixman/pixman-version.h"
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )

    vcpkg_copy_pdbs()
    vcpkg_test_cmake(PACKAGE_NAME unofficial-pixman)
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
    )
    vcpkg_install_make()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
