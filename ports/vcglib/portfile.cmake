vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnr-isti-vclab/vcglib
    REF "${VERSION}"
    SHA512 867a4e4e038f2c67000486a207c04a69ae7fa8dff5be73b4bae8a67ae1530faeb8d20915086c334da545b6e3511b4fe6b1135d732f41b632cf3256687882218e
    PATCHES
        consume-vcpkg-eigen3.patch
        fix-build.patch
    )

file(COPY ${SOURCE_PATH}/vcg/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/vcg)
file(COPY ${SOURCE_PATH}/wrap/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/wrap)
file(COPY ${SOURCE_PATH}/img/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/img)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
