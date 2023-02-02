vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/zyre
    REF 2648b7eb806a2494d6eb4177f0941232d83c5294
    SHA512 8940e82ccdc427734711d63dc01c81fe86c4ca6b7e97a69df979f4d48a4711df1ccaee6a3b6aa394f9ef91d719cb95851c4eb87dfa9ed6426e2577b95e0fb464
    HEAD_REF master
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in
    ${SOURCE_PATH}/builds/cmake/Config.cmake.in
    COPYONLY
)

foreach(_cmake_module Findczmq.cmake Findlibzmq.cmake)
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/${_cmake_module}
        ${SOURCE_PATH}/${_cmake_module}
        COPYONLY
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYRE_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZYRE_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DZYRE_BUILD_SHARED=${ZYRE_BUILD_SHARED}
        -DZYRE_BUILD_STATIC=${ZYRE_BUILD_STATIC}
        -DENABLE_DRAFTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})
endif()

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

vcpkg_copy_tools(TOOL_NAMES zpinger AUTO_CLEAN)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(ZYRE_BUILD_STATIC)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/zyre_library.h
        "if defined ZYRE_STATIC"
        "if 1 //if defined ZYRE_STATIC"
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_fixup_pkgconfig()
