vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/spy
    REF "${VERSION}"
    SHA512 f997d61a73fafecb9af837b92ae9ceee515380852d900fc1778950885fbb62f1121e8923a991500d7380396d847c65e7fd33d41b616b2f66d0234c5a947e0dfd
    HEAD_REF main
)

# The build is written with copacabana, which CPM fetches at configure time; the
# copacabana port is handed to CPM instead, so nothing is downloaded here.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCPM_COPACABANA_SOURCE=${CURRENT_HOST_INSTALLED_DIR}/share/jfalcou-copacabana"
        -DCPM_LOCAL_PACKAGES_ONLY=ON
        -DSPY_BUILD_TEST=OFF
        -DSPY_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/spy)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
