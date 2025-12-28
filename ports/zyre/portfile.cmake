vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/zyre
    REF baeed4e98934a997bd878ac3f9528285adfee3e0
    SHA512 c54ff0100f5d2f7ce28a9b0cf301c3af977a25cab1e742768b8cdae217fb8c3f7ec2e7c2e668c898a2154b29709c67b80bd1c6ce7bd632132f0afd419bf1158b
    HEAD_REF master
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
    "${SOURCE_PATH}/builds/cmake/Config.cmake.in"
    COPYONLY
)

foreach(_cmake_module Findczmq.cmake Findlibzmq.cmake)
    configure_file(
        "${CMAKE_CURRENT_LIST_DIR}/${_cmake_module}"
        "${SOURCE_PATH}/${_cmake_module}"
        COPYONLY
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYRE_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZYRE_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DZYRE_BUILD_SHARED=${ZYRE_BUILD_SHARED}
        -DZYRE_BUILD_STATIC=${ZYRE_BUILD_STATIC}
        -DENABLE_DRAFTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_copy_tools(TOOL_NAMES zpinger AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(ZYRE_BUILD_STATIC)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/zyre_library.h"
        "if defined ZYRE_STATIC"
        "if 1 //if defined ZYRE_STATIC"
    )
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
