vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF "v${VERSION}"
    SHA512 358318a249e22f5228516309d267593b8da9005de015dc0f59645fbfd7a5001e10be9144f32437acc2f6921d952e03adbaf8b9ca5b6620e191346bb569c04780
    HEAD_REF master
    PATCHES fix-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mat73           MATIO_WITH_HDF5
        mat73           MATIO_MAT73
        zlib            MATIO_WITH_ZLIB
        extended-sparse MATIO_EXTENDED_SPARSE
        pic             MATIO_PIC
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DMATIO_SHARED=${BUILD_SHARED}
        -DMATIO_USE_CONAN=OFF
)

vcpkg_cmake_install()

set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix [[${prefix}]])
set(libdir [[${prefix}/lib]])
set(includedir [[${prefix}/include]])
configure_file("${SOURCE_PATH}/matio.pc.in" "${SOURCE_PATH}/matio.pc" @ONLY)
file(INSTALL "${SOURCE_PATH}/matio.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
if(NOT VCPKG_BUILD_TYPE)
    set(includedir [[${prefix}/../include]])
    file(INSTALL "${SOURCE_PATH}/matio.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES matdump AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
