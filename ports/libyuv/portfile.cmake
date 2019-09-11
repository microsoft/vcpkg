include(vcpkg_common_functions)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/libyuv/libyuv
    REF fec9121b676eccd9acea2460aec7d6ae219701b9
    PATCHES
        fix_cmakelists.patch
)

set(POSTFIX d)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX="${POSTFIX}"
)

vcpkg_install_cmake()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/yuv)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/yuvconvert.exe ${CURRENT_PACKAGES_DIR}/tools/yuv/yuvconvert.exe)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/yuvconvert.exe)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

set(LIBRARY_TYPE SHARED)
set(IMPORT_TYPE IMPLIB)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(LIBRARY_TYPE STATIC)
    set(IMPORT_TYPE LOCATION)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/libyuv.dll)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/libyuvd.dll)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libyuv RENAME copyright)
