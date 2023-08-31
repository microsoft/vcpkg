vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abumq/easyloggingpp
    REF "v${VERSION}"
    SHA512 e45789edaf7a43ad6a73861840d24ccce9b9d6bba1aaacf93c6ac26ff7449957251d2ca322c9da85130b893332dd305b13a2499eaffc65ecfaaafa3e11f8d63d
    HEAD_REF master
    PATCHES
        0001_add_cmake_options.patch
        0002_fix_build_uwp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
		std-locking     use_std_threads
		thread-safe     thread_safe
		no-defaultfile  no_default_logfile
)
if(VCPKG_TARGET_IS_UWP)
    set(TARGET_IS_UWP ON)
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dbuild_static_lib=ON
        -Dis_uwp=${TARGET_IS_UWP}
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
