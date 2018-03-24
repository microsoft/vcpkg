include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building of HPX not supported yet. Building dynamic.") 
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO STEllAR-GROUP/hpx
    REF 1.1.0
    SHA512 435250143ddbd2608995fe3dc5c229a096312d7ac930925ae56d0abd2d5689886126f6e81bc7e37b84ca9bc99f951ef1f39580168a359c48788ac8d008bc7078
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        "-DBOOST_ROOT=${CURRENT_INSTALLED_DIR}/share/boost"
        "-DHWLOC_ROOT=${CURRENT_INSTALLED_DIR}/share/hwloc"
        -DHPX_WITH_VCPKG=ON
        -DHPX_WITH_HWLOC=ON
        -DHPX_WITH_TESTS=OFF
        -DHPX_WITH_EXAMPLES=OFF
        -DHPX_WITH_TOOLS=OFF
        -DHPX_WITH_RUNTIME=OFF
)

vcpkg_install_cmake()

# post build cleanup
file(GLOB SHARE_DIR ${CURRENT_PACKAGES_DIR}/share/hpx-*)
file(RENAME ${SHARE_DIR} ${CURRENT_PACKAGES_DIR}/share/hpx)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/HPX)

file(GLOB_RECURSE CMAKE_FILES "${CURRENT_PACKAGES_DIR}/share/hpx/*.cmake")
foreach(CMAKE_FILE IN LISTS CMAKE_FILES)
    file(READ ${CMAKE_FILE} _contents)
    string(REGEX REPLACE
        "lib/([A-Za-z0-9_.-]+\\.dll)"
        "bin/\\1"
        _contents "${_contents}")
    string(REGEX REPLACE
        "lib/hpx/([A-Za-z0-9_.-]+\\.dll)"
        "bin/\\1"
        _contents "${_contents}")
    file(WRITE ${CMAKE_FILE} "${_contents}")
endforeach()

file(READ "${CURRENT_PACKAGES_DIR}/share/hpx/HPXMacros.cmake" _contents)
string(REPLACE "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/cmake/HPX\")" "list(APPEND CMAKE_MODULE_PATH \"\${CMAKE_CURRENT_LIST_DIR}\")" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/hpx/HPXMacros.cmake" "${_contents}")

file(INSTALL
    ${SOURCE_PATH}/LICENSE_1_0.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/hpx RENAME copyright)

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/lib/*.dll)
if(DLLS)
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/lib/hpx/*.dll)
if(DLLS)
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
if(DLLS)
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/hpx/*.dll)
if(DLLS)
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${DLLS})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/bazel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/bazel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

vcpkg_copy_pdbs()
