if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-mpi/hwloc
    REF hwloc-1.11.7
    SHA512 bc3a74c60bfbed1e860c2fe2b5b49956eca5cfd9c00a262f6cd3026a42ae8b5411fa296e471a95cba657d943b8853675442e796e648034398af3015e5f59476e)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH} 
    PREFER_NINJA
    OPTIONS_DEBUG
        -DHWLOC_SKIP_INCLUDES=ON)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/hwloc/autogen/config.h PUBLIC_CONFIG_H)
string(REPLACE "defined( DECLSPEC_EXPORTS )" "0" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined( _USRDLL )" "0" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
else()
    string(REPLACE "defined( _USRDLL )" "1" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/hwloc/autogen/config.h "${PUBLIC_CONFIG_H}")

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/tools)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/hwloc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hwloc/COPYING ${CURRENT_PACKAGES_DIR}/share/hwloc/copyright)
