if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "ismrmrd only supports dynamic library and crt linkage")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF 89d4f9982e8e593124ff981f91c97ad5b898eb00 
    SHA512 363390820bba665ab6fbd74c5ba862cb7ea9b8e7b21d68828e0d7f78616cd2ff5f91a11d872ff8cc92a1daed406c43c34da1dfb4309cd401467b8ec76c2f0d59
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DUSE_SYSTEM_PUGIXML=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ismrmrd/cmake)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll)
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll)
    file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll)
endif()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/FindFFTW3.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/FindFFTW3.cmake)

set(ISMRMRD_CMAKE_DIRS ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
foreach(ISMRMRD_CMAKE_DIR IN LISTS ISMRMRD_CMAKE_DIRS)
if (EXISTS ${ISMRMRD_CMAKE_DIR})
    file(GLOB ISMRMRD_CMAKE_FILES ${ISMRMRD_CMAKE_DIR} "ISMRMRD*.cmake")
    foreach(ICF IN LISTS ${ISMRMRD_CMAKE_FILES})
        file(COPY ${ISMRMRD_CMAKE_DIR}/ISMRMRD/${ICF} DESTINATION ${CURRENT_PACKAGES_DIR}/share/ismrmrd/cmake)
    endforeach()
    file(REMOVE_RECURSE ${ISMRMRD_CMAKE_DIR})
endif()
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_info.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_info.exe)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_c_example.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debub/bin/ismrmrd_c_example.exe)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_read_timing_test.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_read_timing_test.exe)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ismrmrd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ismrmrd/LICENSE ${CURRENT_PACKAGES_DIR}/share/ismrmrd/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/ismrmrd)
