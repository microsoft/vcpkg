include(vcpkg_common_functions)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(WIN32_INCLUDE_STDDEF_PATCH "x86-windows-include-stddef.patch")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(STATIC_PATCH "fix_static.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF 4d4004d91ccadd41ddb30b019f970a69bb23a1bc
    SHA512 648901de4629c8b11574894763a5fa61a3cb0420c5aa62cdff02c4641ba702ca73efba12b403076301e44a4f0a7c915da1f2c7a34b24377d0385af92f2eda892
    HEAD_REF master
    PATCHES
        ${STATIC_PATCH}
        ${WIN32_INCLUDE_STDDEF_PATCH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_SYSTEM_PUGIXML=ON
        -DUSE_HDF5_DATASET_SUPPORT=ON
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
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/ismrmrd/FindFFTW3.cmake)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/ismrmrd/cmake)

set(ISMRMRD_CMAKE_DIRS ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
foreach(ISMRMRD_CMAKE_DIR IN LISTS ISMRMRD_CMAKE_DIRS)
if (EXISTS ${ISMRMRD_CMAKE_DIR})
    file(GLOB ISMRMRD_CMAKE_FILES "${ISMRMRD_CMAKE_DIR}/ISMRMRD/ISMRMRD*.cmake")
    foreach(ICF ${ISMRMRD_CMAKE_FILES})
        file(COPY ${ICF} DESTINATION ${CURRENT_PACKAGES_DIR}/share/ismrmrd/cmake/)
    endforeach()
endif()
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${ISMRMRD_CMAKE_DIRS})

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    set(EXECUTABLE_SUFFIX ".exe")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_c_example${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_c_example${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_generate_cartesian_shepp_logan${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_generate_cartesian_shepp_logan${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_info${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_info${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_read_timing_test${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_read_timing_test${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_recon_cartesian_2d${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_recon_cartesian_2d${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_test_xml${EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_test_xml${EXECUTABLE_SUFFIX})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ismrmrd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ismrmrd/LICENSE ${CURRENT_PACKAGES_DIR}/share/ismrmrd/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/ismrmrd)
