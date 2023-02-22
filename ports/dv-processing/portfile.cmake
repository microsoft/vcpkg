vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/dv-processing
    REF b55a2e7a01ef49a861ee151bd542d4b32edfde30
    SHA512 7abf828e27af0b708c7fc3c6c78f00f9089d202a7e4a1d6c9a1f9416d2e9e394d470dc1b40ae2f491350b87f11cd17869b12ef10cd7c647e06627833f6d205f9
    HEAD_REF rel_1.7
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH CMAKEMOD_SOURCE_PATH
    REPO dv/cmakemod
    REF ec53dae89f6b037e9e640af5340d7bf67d84d278
    SHA512 e7907b1be9d85b02e1a1703cf001765119a7d07b1873148a0fbfe6945c519d85b1f9bc66b24f90d88759c2b32965304e1639f2ff136448be64fc88f81a0d4c2d
    HEAD_REF ec53dae89f6b037e9e640af5340d7bf67d84d278
)

file(GLOB CMAKEMOD_FILES "${CMAKEMOD_SOURCE_PATH}/*")
file(COPY ${CMAKEMOD_FILES} DESTINATION "${SOURCE_PATH}/cmake/modules")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_TESTS=OFF
        -DENABLE_SAMPLES=OFF
        -DENABLE_PYTHON=OFF
        -DENABLE_UTILITIES=OFF
        -DBUILD_CONFIG_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "dv-processing" CONFIG_PATH "share/dv-processing")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
