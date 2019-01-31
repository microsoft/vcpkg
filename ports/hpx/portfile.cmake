include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building of HPX not supported yet. Building dynamic.") 
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO STEllAR-GROUP/hpx
    REF 1.2.0
    SHA512 caf2650381856db6a96fd4b120975d94d68d9bb19ada1d6cd076abe2d4aa1418e410167f774a881d95eacd0d46bbd5f90f16a4c77b4a2cf00e5b24ea17bfe670
    HEAD_REF master
    PATCHES boost-1.69.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        "-DBOOST_ROOT=${CURRENT_INSTALLED_DIR}/share/boost"
        "-DHWLOC_ROOT=${CURRENT_INSTALLED_DIR}/share/hwloc"
        -DHPX_WITH_VCPKG=ON
        -DHPX_WITH_TESTS=OFF
        -DHPX_WITH_EXAMPLES=OFF
        -DHPX_WITH_TOOLS=OFF
        -DHPX_WITH_RUNTIME=OFF
)

vcpkg_install_cmake()

# post build cleanup
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
        "bin/hpx/\\1"
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
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin/hpx)
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
if(DLLS)
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/hpx/*.dll)
if(DLLS)
    file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/hpx)
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
