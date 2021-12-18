vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-CDR
    REF 065d49248bd4afbae670836ee1f1c718b9760dde # v1.0.15
    SHA512 1e011f1848abace94299368a5150f9f7513a676ccdc2b2247cebcb098f7b397e9bd20f5663bc35ea9921b1c91654af39e19b867b73c38bdc5612e0e2b926743a
    HEAD_REF master
    PATCHES install-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fastcdr)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/lib/fastcdr ${CURRENT_PACKAGES_DIR}/debug/lib/fastcdr)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ ${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h EPROSIMA_AUTO_LINK_H)
    string(REPLACE "#define EPROSIMA_LIB_PREFIX \"lib\"" "#define EPROSIMA_LIB_PREFIX" EPROSIMA_AUTO_LINK_H "${EPROSIMA_AUTO_LINK_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h "${EPROSIMA_AUTO_LINK_H}")
else()
    file(READ ${CURRENT_PACKAGES_DIR}/include/fastcdr/config.h FASTCDR_H)
    string(REPLACE "#define _FASTCDR_CONFIG_H_" "#define _FASTCDR_CONFIG_H_\r\n#define FASTCDR_DYN_LINK" FASTCDR_H "${FASTCDR_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fastcdr/config.h "${FASTCDR_H}")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
