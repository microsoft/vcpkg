vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO muflihun/easyloggingpp
    REF v9.97.0
    SHA512 e45789edaf7a43ad6a73861840d24ccce9b9d6bba1aaacf93c6ac26ff7449957251d2ca322c9da85130b893332dd305b13a2499eaffc65ecfaaafa3e11f8d63d
    HEAD_REF master
    PATCHES
        0001_add_cmake_options.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
		std-locking     use_std_threads
		thread-safe     thread_safe
		no-defaultfile  no_default_logfile
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dbuild_static_lib=ON
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
