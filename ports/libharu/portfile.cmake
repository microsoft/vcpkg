vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libharu/libharu
    REF v${VERSION}
    SHA512 422210b09f89643cb25808559aeea109db5cce8a71c779d51f87222cdd50434f4f0f92322ebe429fca8f85ad73592bcabb14c3e36cd0bea19b6ec4c729220522
    HEAD_REF master
    PATCHES
        fix-include-path.patch
        export-targets.patch
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

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libharu)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/debug/CHANGES"
    "${CURRENT_PACKAGES_DIR}/debug/INSTALL"
    "${CURRENT_PACKAGES_DIR}/README.md"
    "${CURRENT_PACKAGES_DIR}/CHANGES"
    "${CURRENT_PACKAGES_DIR}/INSTALL"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_TARGET_IS_WINDOWS)
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
endif()

vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
