vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF cf6f1dd01e660d5865d68bf5fa78f6376b89470a #v1.5.0
    SHA512 eafe7e12f9be9f5be48d66ca6f7253a7de34ae29e35887249bc447c7d5e97322bfe64ca68fc1b2ff1e9e36f703fb467b0bd14e19ce48844924dd42844b9209a4
    HEAD_REF v1.x
    PATCHES
        disable-master-project-check.patch
        fix-feature-export.patch
        fix-error-4275.patch # Actually a defect in fmtlib
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/spdlog
                    ${CURRENT_PACKAGES_DIR}/debug/lib/spdlog
                    ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
