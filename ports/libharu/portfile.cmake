if("notiffsymbols" IN_LIST FEATURES)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(DISABLETIFF tiff.patch)
    endif()
endif()
vcpkg_download_distfile(SHADING_PR
    URLS "https://github.com/libharu/libharu/pull/157.diff"
    FILENAME "libharu-shading-pr-157.patch"
    SHA512 f2ddb22b54b4eccc79400b6a4b2d245a221898f75456a5a559523eab7a523a87dfc5dfd0ec5fb17a771697e03c7ea6ed4c6095eff73e0a4302cd6eb24584c957
)

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
        ${SHADING_PR}
        ${DISABLETIFF}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
  set(VCPKG_BUILD_STATIC_LIBS OFF)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
  set(VCPKG_BUILD_STATIC_LIBS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBHPDF_STATIC=${VCPKG_BUILD_STATIC_LIBS}
        -DLIBHPDF_SHARED=${VCPKG_BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
       if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
          file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libhpdfs.lib" "${CURRENT_PACKAGES_DIR}/lib/libhpdf.lib")
       endif()
       if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
          file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libhpdfsd.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/libhpdfd.lib")
       endif()
    else()
       if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
          file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libhpdfs.a" "${CURRENT_PACKAGES_DIR}/lib/libhpdf.a")
       endif()
       if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
          file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libhpdfs.a" "${CURRENT_PACKAGES_DIR}/debug/lib/libhpdfd.a")
       endif()
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/README"
    "${CURRENT_PACKAGES_DIR}/debug/CHANGES"
    "${CURRENT_PACKAGES_DIR}/debug/INSTALL"
    "${CURRENT_PACKAGES_DIR}/README"
    "${CURRENT_PACKAGES_DIR}/CHANGES"
    "${CURRENT_PACKAGES_DIR}/INSTALL"
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
