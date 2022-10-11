vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libssh2/libssh2
    REF libssh2-1.10.0
    SHA512 615E28880695911F5700CC7AC3DDA6B894384C0B1D8B02B53C2EB58F1839F47211934A292F490AD7DDEF7E63F332E0EBF44F8E6334F64BE8D143C72032356C1F
    HEAD_REF master
    PATCHES
        0001-Fix-UWP.patch
        0002-fix-macros.patch
        0003-fix-openssl3.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib ENABLE_ZLIB_COMPRESSION
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_DEBUG_LOGGING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libssh2)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh2.h" "ifdef LIBSSH2_WIN32" "if 1")
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh2.h" "ifdef _WINDLL" "if 1")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh2.h" "ifdef _WINDLL" "if 0")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Do not delete the entire share directory as it contains the *-config.cmake files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
