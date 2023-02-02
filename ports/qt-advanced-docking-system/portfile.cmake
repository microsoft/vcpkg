vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF d5fefaa35fb53e299b7f39b0d8f541954c710d94
    SHA512 fcafee34d4d5365b3677c648e0d9a1ea8afd5463ca682ae19b10661490aca44d4f010ba768ed9c639b8ada10106be7aff336c2b7b42f10dc12db6b51988b4e22
    HEAD_REF master
    PATCHES
        config_changes.patch
        qt.patch
)

if(VCPKG_CROSSCOMPILING)
    list(APPEND _qarg_OPTIONS "-DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR}")
    list(APPEND _qarg_OPTIONS "-DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_qarg_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DADS_VERSION=${VERSION}
        -DQT_VERSION_MAJOR=6
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=TRUE
        -DBUILD_STATIC=${BUILD_STATIC}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Qt5
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "qtadvanceddocking" CONFIG_PATH "lib/cmake/qtadvanceddocking")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/license")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/license")

file(INSTALL "${SOURCE_PATH}/gnu-lgpl-v2.1.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
