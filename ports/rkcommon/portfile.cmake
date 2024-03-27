vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  ospray/rkcommon
    REF "v${VERSION}"
    SHA512 fd4ac6d6261f9620ed93f3266249323dea790c90b3d6f1b2bdd31e03b6397d5648f6139694ebb978d9c27a3cb2e2a9ef78ed7fe0d42c7668585243a457908f6c
    HEAD_REF master
    PATCHES fix-static.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/rkcommon_redist_deps.cmake")
file(TOUCH "${SOURCE_PATH}/cmake/rkcommon_redist_deps.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rkcommon/common.h" "defined(rkcommon_SHARED)" "0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rkcommon/common.h" "defined(rkcommon_SHARED)" "1")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}-${VERSION}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
