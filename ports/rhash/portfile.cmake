set(RHASH_XVERSION 1.4.0)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF df0c969966b5da10f2db5060cf329790db95080e # v1.4.0
    SHA512 eebd5872f5d40d5ef5b7fe857ff3099c3b60e37cedaacf7ae8da63bd18790a16546de1809fa9f8e4fa7eef178121051b267fedd5d237135b80201f8609d613b6
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/librhash)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/librhash
    PREFER_NINJA
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
