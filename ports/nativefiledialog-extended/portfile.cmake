vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO btzy/nativefiledialog-extended
    REF v${VERSION}
    SHA512 564919ff370397238f9b324128c85f9c62ebf4dc3a13bc3488269f46243da1abd3563ac902cc13f6db127c1835d44d254c010ca5339a28acfd7d91b5264ae897
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wayland NFD_WAYLAND
)

set(copyright_files "${SOURCE_PATH}/LICENSE")
if(NFD_WAYLAND)
    # Upstream expects wayland-protocols as a git submodule, which is not part of the release archive.
    set(wayland_protocol_file "${CURRENT_INSTALLED_DIR}/share/wayland-protocols/unstable/xdg-foreign/xdg-foreign-unstable-v1.xml")
    file(COPY "${wayland_protocol_file}"
        DESTINATION "${SOURCE_PATH}/3ps/wayland-protocols/unstable/xdg-foreign"
    )
    list(APPEND copyright_files "${wayland_protocol_file}")
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/wayland")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNFD_BUILD_TESTS=OFF
        -DNFD_PORTAL=ON
    MAYBE_UNUSED_VARIABLES
        # Used only for Linux builds.
        NFD_PORTAL
        NFD_WAYLAND
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME nfd CONFIG_PATH lib/cmake/nfd)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST ${copyright_files})
