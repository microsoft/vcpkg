vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO btzy/nativefiledialog-extended
    REF v${VERSION}
    SHA512 23d4021f40451c8b33305838c766fcced0d61567e1458b14d92a299fc74530577d666db8719ab3d49c8f6196b101c5c602d854f40db63b40666fb89bcc01a647
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
