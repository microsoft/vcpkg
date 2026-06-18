vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge1/ELFIO
    REF "Release_${VERSION}"
    SHA512 f5c8bc6cc98da845f6c011fc85b98476935c5d20d72b36bff5ad2472434494115ee7c06cfa37152c528e5931c39fe3cc084bfc8e6952b2c3e8f24b8601ae212f
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DELFIO_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
