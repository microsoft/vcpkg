include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-CDR
    REF v1.0.9
    SHA512 2825e61fc4736c9364fc3130f649798cec11fcb56dc5e202c17731121ad8a2795f0fbf8acb5d8d662181bc470e7a3e95a5027283872714be505bb2562c2e2312
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
