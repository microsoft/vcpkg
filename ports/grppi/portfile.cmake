vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO arcosuc3m/grppi
	REF  v0.4.0
	SHA512 f8235af6832958de420a68d4465a6c63701ab4385f3430d32f77c1d5e8212001262aad1a8aae04261ba889d592798cd3963843b190d325bddc1fe7dcc4aebd7d 
    HEAD_REF master 
    PATCHES 
        fix-build-error.patch
        fix-support-other-compilers.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DGRPPI_DOXY_ENABLE=OFF
      -DGRPPI_EXAMPLE_APPLICATIONS_ENABLE=OFF
      -DGRPPI_UNIT_TEST_ENABLE=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
