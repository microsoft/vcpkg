set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

string(REPLACE "." "_" poppler_data_version "POPPLER_DATA_${VERSION}")

vcpkg_from_gitlab(
    GITLAB_URL gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO poppler/poppler-data
    REF "${poppler_data_version}"
    SHA512 1d2cb04604a1a3d33edc45638d1a6ddacbcf99eeeed8bca7462cbd5d244edbebe94cd1f2487189060b0927287a8571fcc29ee3b3cd7fb4dc1c4d8f819d035a0a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
