vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  ospray/rkcommon
    REF "v${VERSION}"
    SHA512 48ced20506344250fd2b91875f8282c3b39828ac3eb0c8c0e2505dcc5cdb85a8f36dd328294f165aab66bdfe836b81b7a2c9f6f5c7ab49d281df5a3f95075548
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
