vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 2afe62ec77c558c6c81435b479a99c0a188c5113 #v3.8.1
    SHA512 2580f93901a72adc63151f25983a0414d732cf7e40a9255ca8ff2f6fbcecde886ab43a09a19dca16d19ec76ee8b4ecfd7af8f673012a04c0fc6c577721891715 
    HEAD_REF master
    PATCHES
        hardcode_version.patch
        qt.patch
)

if(VCPKG_CROSSCOMPILING)
    list(APPEND _qarg_OPTIONS -DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR})
    list(APPEND _qarg_OPTIONS -DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 AND VCPKG_TARGET_IS_WINDOWS) # Remove if PR #16111 is merged
        list(APPEND _qarg_OPTIONS -DCMAKE_CROSSCOMPILING=ON -DCMAKE_SYSTEM_PROCESSOR:STRING=ARM64 -DCMAKE_SYSTEM_NAME:STRING=Windows)
    endif()
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        ${_qarg_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DVERSION_SHORT=3.8.1
        -DQT_VERSION_MAJOR=6
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=TRUE
        -DBUILD_STATIC=${BUILD_STATIC}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Qt5
)
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
file(INSTALL "${SOURCE_PATH}/gnu-lgpl-v2.1.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/license")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_cmake_config_fixup(PACKAGE_NAME "qtadvanceddocking" CONFIG_PATH "lib/cmake/qtadvanceddocking")
