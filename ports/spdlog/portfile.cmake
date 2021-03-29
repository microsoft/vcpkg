vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF 100f30043f33277122e0991c83845a2617172ffd # v1.8.5
    SHA512 4ac4a2e32f940d1e9610eeca8644c936ba2cc94d24319b8f580485e6a7ea4091b5f79cb61336b49f25c679ae04ddc787f15733efdfc530ee336ca5258711d336
    HEAD_REF v1.x
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
	benchmark SPDLOG_BUILD_BENCH
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPDLOG_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPDLOG_FMT_EXTERNAL=ON
        -DSPDLOG_INSTALL=ON
        -DSPDLOG_BUILD_SHARED=${SPDLOG_BUILD_SHARED}
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
