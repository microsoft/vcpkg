#header-only library
include(vcpkg_common_functions)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "${PORT} shared lib is not yet supported under windows.")
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.4.1
    SHA512 fd7122f1680667f47c6acc839c9ac3b10f89569695b654cfae2387ca263c49ab4ac9cbd81debe47ef637ffe026176d486320f7a47f22151905aae7cd28c4d90a
    HEAD_REF v1.x
    PATCHES
        fix-feature-export.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SPDLOG_BUILD_SHARED ON)
else()
    set(SPDLOG_BUILD_SHARED OFF)
endif()

set(SPDLOG_USE_BENCHMARK OFF)
if("benchmark" IN_LIST FEATURES)
    set(SPDLOG_USE_BENCHMARK ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_FMT_EXTERNAL=ON
        -DSPDLOG_BUILD_BENCH=${SPDLOG_USE_BENCHMARK}
        -DSPDLOG_BUILD_SHARED=${SPDLOG_BUILD_SHARED}
)

vcpkg_install_cmake()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/${PORT}/cmake")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/${PORT}/cmake)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/fmt.h
    "#if !defined(SPDLOG_FMT_EXTERNAL)"
    "#if 0 // !defined(SPDLOG_FMT_EXTERNAL)"
)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/ostr.h
    "#if !defined(SPDLOG_FMT_EXTERNAL)"
    "#if 0 // !defined(SPDLOG_FMT_EXTERNAL)"
)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spdlog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spdlog/LICENSE ${CURRENT_PACKAGES_DIR}/share/spdlog/copyright)