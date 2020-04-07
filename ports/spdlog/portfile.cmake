vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF 1549ff12f1aa61ffc4d9a8727c519034724392a0 #v1.4.2
    SHA512 c159aea475baecad0a5a9eef965856203c96aa855b0480e82d751bcc050c6e08bb0aa458544da061f5d744e17dcd27bd9b6e31a62d502834f02d3591f29febec
    HEAD_REF v1.x
    PATCHES
        disable-master-project-check.patch
        fix-feature-export.patch
        fix-error-4275.patch
        fix-uwp.patch
        fix-include.patch
)

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
        -DSPDLOG_INSTALL=ON
)

vcpkg_install_cmake()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/${PORT}/cmake")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/${PORT}/cmake)
endif()

vcpkg_copy_pdbs()

# use vcpkg-provided fmt library (see also option SPDLOG_FMT_EXTERNAL above)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/bundled)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/fmt.h
    "#if !defined(SPDLOG_FMT_EXTERNAL)"
    "#if 0 // !defined(SPDLOG_FMT_EXTERNAL)"
)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/ostr.h
    "#if !defined(SPDLOG_FMT_EXTERNAL)"
    "#if 0 // !defined(SPDLOG_FMT_EXTERNAL)"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/spdlog
                    ${CURRENT_PACKAGES_DIR}/debug/lib/spdlog
                    ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
