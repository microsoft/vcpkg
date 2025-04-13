vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO libcamera-org/libcamera
	REF "v${VERSION}"
	SHA512 251e6436cb6d41cf80a502889dcbfa2925fc1a9addecce16f9d38b4cd6b8a9bb519553b917315e21b61ec90349d7aa6132c071071aacc7040dc7ab9108abd51d
	HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(MESON)

x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PYTHON_EXECUTABLE "${PYTHON3}"
    PACKAGES "jinja2" "PyYaml" "ply"
)

vcpkg_configure_meson(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.rst")