include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-CDR
    REF 649b9a0e763f8a4cfdd41238b1495c58b7ea6660
    SHA512 9a72c60f59572ec95b320a44f10ba841cb66d3f71e4ebb2b8f00f42400ea9dd379d884937b047206cdeb19f7c298782b3557113b9fb6a1b79a3a9e3592cb1eb9
    HEAD_REF master
    PATCHES install-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLICENSE_INSTALL_DIR=share/fastcdr
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/fastcdr/cmake)

file(READ "${CURRENT_PACKAGES_DIR}/share/fastcdr/fastcdr-config.cmake" _contents)
string(REPLACE "include(\${fastcdr_LIB_DIR}/fastcdr/cmake/fastcdr-targets.cmake)" "include(\${CMAKE_CURRENT_LIST_DIR}/fastcdr-targets.cmake)" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/fastcdr/fastcdr-config.cmake" "${_contents}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/lib/fastcdr ${CURRENT_PACKAGES_DIR}/debug/lib/fastcdr)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ ${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h EPROSIMA_AUTO_LINK_H)
    string(REPLACE "#define EPROSIMA_LIB_PREFIX \"lib\"" "#define EPROSIMA_LIB_PREFIX" EPROSIMA_AUTO_LINK_H "${EPROSIMA_AUTO_LINK_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h "${EPROSIMA_AUTO_LINK_H}")
else()
    file(READ ${CURRENT_PACKAGES_DIR}/include/fastcdr/config.h FASTCDR_H)
    string(REPLACE "#define _FASTCDR_CONFIG_H_" "#define _FASTCDR_CONFIG_H_\r\n#define FASTCDR_DYN_LINK" FASTCDR_H "${FASTCDR_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fastcdr/config.h "${FASTCDR_H}")
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/fastcdr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fastcdr/license ${CURRENT_PACKAGES_DIR}/share/fastcdr/copyright)
