if("notiffsymbols" IN_LIST FEATURES)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(DISABLETIFF tiff.patch)
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libharu/libharu
    REF d84867ebf9f3de6afd661d2cdaff102457fbc371
    SHA512 789579dd52c1056ae90a4ce5360c26ba92cadae5341a3901c4159afe624129a1f628fa6412952a398e048b0e5040c93f7ed5b4e4bc620a22d897098298fe2a99
    HEAD_REF master
    PATCHES
        fix-build-fail.patch
        add-boolean-typedef.patch
        # This patch adds shading support which is required for VTK. If desired, this could be moved into an on-by-default feature.
        pr-157.patch # Remove on next version update
        ${DISABLETIFF}
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBHPDF_STATIC=${BUILD_STATIC}
        -DLIBHPDF_SHARED=${BUILD_SHARED}
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libhpdfs${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/lib/libhpdf${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libhpdfsd${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/lib/libhpdfd${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/README"
    "${CURRENT_PACKAGES_DIR}/debug/CHANGES"
    "${CURRENT_PACKAGES_DIR}/debug/INSTALL"
    "${CURRENT_PACKAGES_DIR}/debug/if"
    "${CURRENT_PACKAGES_DIR}/README"
    "${CURRENT_PACKAGES_DIR}/CHANGES"
    "${CURRENT_PACKAGES_DIR}/INSTALL"
    "${CURRENT_PACKAGES_DIR}/if"
)

file(READ "${CURRENT_PACKAGES_DIR}/include/hpdf.h" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "#ifdef HPDF_DLL\n" "#if 1\n" _contents "${_contents}")
else()
    string(REPLACE "#ifdef HPDF_DLL\n" "#if 0\n" _contents "${_contents}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/hpdf.h" "${_contents}")

file(READ "${CURRENT_PACKAGES_DIR}/include/hpdf_types.h" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "#ifdef HPDF_DLL\n" "#if 1\n" _contents "${_contents}")
else()
    string(REPLACE "#ifdef HPDF_DLL\n" "#if 0\n" _contents "${_contents}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/hpdf_types.h" "${_contents}")

vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENCE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
