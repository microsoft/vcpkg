include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libspatialindex/libspatialindex
    REF 1.9.0
    SHA512   368537e9bfe52db96486a1febfabe035f9f7714fd1cb50450e3ab89d51c5ffffb0e2ea219e08bee34f772ba9813a3a7f9e63d8b8946887ce83811ef68d17d1cc
    HEAD_REF master
	PATCHES
        static.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS -DCMAKE_DEBUG_POSTFIX=d -DSIDX_BUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

#Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspatialindex)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libspatialindex/COPYING ${CURRENT_PACKAGES_DIR}/share/libspatialindex/copyright)