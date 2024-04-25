vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  ospray/rkcommon
    REF 0b8856cd9278474b56dc5bcff516a4b9482cf147
    SHA512 836e888e33406f6825b8f5570894402460b3ae65a68ca8aeecf2c8e712f70e9392fdbb2131d538dbf47fc48a0664568e1fd60968452c7517cfeb17c0e608fecf
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
