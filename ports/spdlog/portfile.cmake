vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF 83b9149930f392d7797b54fe97a66ab3f2120671 #v1.6.0
    SHA512 b41201e036891ef34399b387d9a04d36687f05aa420a5e324836131e217ffff0d6658a17472817534b45bed6ae10f8b780805a537cb93ffb058f17013af9b14d
    HEAD_REF v1.x
    PATCHES
        fix-feature-export.patch
        fix-error-4275.patch # Actually a defect in fmtlib
        fix-includes-external-fmt.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        benchmark SPDLOG_BUILD_BENCH
        coarse-clock SPDLOG_CLOCK_COARSE
        no-atomic-levels SPDLOG_NO_ATOMIC_LEVELS
        no-child-fd SPDLOG_PREVENT_CHILD_FD
        no-exceptions SPDLOG_NO_EXCEPTIONS
        no-local-storage SPDLOG_NO_TLS
        no-thread-id SPDLOG_NO_THREAD_ID
        pch SPDLOG_ENABLE_PCH
        shared SPDLOG_BUILD_SHARED
        wchar SPDLOG_WCHAR_SUPPORT
        wchar SPDLOG_WCHAR_FILENAMES
    INVERTED_FEATURES
        disable-warnings SPDLOG_BUILD_WARNINGS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_MASTER_PROJECT=OFF
        -DSPDLOG_FMT_EXTERNAL=ON
        ${FEATURE_OPTIONS}
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
