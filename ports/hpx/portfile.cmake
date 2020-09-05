
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO STEllAR-GROUP/hpx
    REF 1.5.0
    SHA512 3ce52def94d2d76bc19f0c3a411581a69af95123bbc38b4bd777b8d89523d0e22769ac2e7bb62c756f0126f39c378dfdd503a10499d3497bfe40cc71c046c70b
    HEAD_REF stable
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

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/HPXMacros.cmake"
    "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \"\${CMAKE_CURRENT_LIST_DIR}\")"
    "list(APPEND CMAKE_MODULE_PATH \"\${CMAKE_CURRENT_LIST_DIR}\")")

file(INSTALL
    ${SOURCE_PATH}/LICENSE_1_0.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

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
