vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slirp/libslirp
    REF "v${VERSION}"
    SHA512 15592d5015e2ccee6a096a907cde3ec2aad423f9815ae2831b61f41d366322e1865e8fbb3b6cf61608aeb991f2039a5e80ed7c367cce9cfb71e35102eeb8c836
    HEAD_REF master
)

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
