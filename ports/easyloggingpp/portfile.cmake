vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abumq/easyloggingpp
    REF "v${VERSION}"
    SHA512 3df813f7f9796c81c974ba794624db2602253e14b938370deb4c851fe8725f5c7ebf71d7ae0277fcb770b043ccf8f04bbf8e770d14565f4cb704328973473387
    HEAD_REF master
    PATCHES
        0001_add_cmake_options.patch
        0002_fix_build_uwp.patch
        0003_fix_pkgconfig.patch
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
    OPTIONS_DEBUG
        -DELPP_PKGCONFIG_INSTALL_DIR="${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
    OPTIONS_RELEASE
        -DELPP_PKGCONFIG_INSTALL_DIR="${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CURRENT_PORT_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
