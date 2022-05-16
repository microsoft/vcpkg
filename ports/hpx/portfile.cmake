vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO STEllAR-GROUP/hpx
    REF 1.7.1
    SHA512 6bdb294da393a198abf81d5f63799a066334755eed0fda40bbfc4e9a774b6e19a3e5ad7ab45c989d31f3797e7b547bb552c29f51b552d9a79d166f86aee375a3
    HEAD_REF stable
    PATCHES
        fix-dependency-hwloc.patch
        fix-cmakecache-paths.patch
)

set(HPX_WITH_MALLOC system)
if(VCPKG_TARGET_IS_LINUX)
    # This is done at the request of the hpx maintainers; see
    # https://github.com/microsoft/vcpkg/pull/21673#issuecomment-979904882
    # It must match when gperftools is treated as a dependency of this port.
    set(HPX_WITH_MALLOC tcmalloc)
endif()


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHPX_WITH_VCPKG=ON
        -DHPX_WITH_TESTS=OFF
        -DHPX_WITH_EXAMPLES=OFF
        -DHPX_WITH_TOOLS=OFF
        -DHPX_WITH_RUNTIME=OFF
        "-DHPX_WITH_MALLOC=${HPX_WITH_MALLOC}"
)

vcpkg_cmake_install()

# post build cleanup
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/HPX)

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
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/HPXConfig.cmake"
    "set(HPX_BUILD_TYPE \"Release\")"
    "set(HPX_BUILD_TYPE \"\${CMAKE_BUILD_TYPE}\")")

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/HPXMacros.cmake"
    "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH}"
    "list(APPEND CMAKE_MODULE_PATH")

file(INSTALL
    "${SOURCE_PATH}/LICENSE_1_0.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
if(DLLS)
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/hpx/*.dll")
if(DLLS)
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/hpx")
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
if(DLLS)
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE ${DLLS})
endif()

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/hpx/*.dll")
if(DLLS)
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/hpx")
    file(REMOVE ${DLLS})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/hpxcxx" "\"${CURRENT_PACKAGES_DIR}\"" "os.path.dirname(os.path.dirname(os.path.realpath(__file__)))")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/hpxcxx" "\"${CURRENT_PACKAGES_DIR}/debug\"" "os.path.dirname(os.path.dirname(os.path.realpath(__file__)))")

vcpkg_copy_pdbs()
