vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/akali
    REF aa0ee3b82cef325ca582fce30bf3bf177ed81e9b
    SHA512 0d523191219b19bcf2becb2c9e78b32b50fbbd5a052dd5330e315a6310c0d5c322639434f710a37c6d98e23510506d294b52978f8487227d4461d29d4a6bb502
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AKALI_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DAKALI_STATIC:BOOL=${AKALI_STATIC}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/akali)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/akali)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h AKALI_EXPORT_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "#ifdef AKALI_STATIC" "#if 1" AKALI_EXPORT_H "${AKALI_EXPORT_H}")
else()
    string(REPLACE "#ifdef AKALI_STATIC" "#if 0" AKALI_EXPORT_H "${AKALI_EXPORT_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/akali/akali_export.h "${AKALI_EXPORT_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
