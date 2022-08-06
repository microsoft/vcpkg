vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnr-isti-vclab/vcglib
    REF 2022.02
    SHA512 1a4b04c53eb52d0d9864f4e942f0a06e6f4fe5f2b5686fa534b6c68b715941147d89ed6d83bce9dc8d0c7029460824ab1f73231ba6b7c32472becfe641e2a7cb
    PATCHES
        consume-vcpkg-eigen3.patch
        fix-build.patch
    )

file(COPY ${SOURCE_PATH}/vcg/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/vcg)
file(COPY ${SOURCE_PATH}/wrap/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/wrap)
file(COPY ${SOURCE_PATH}/img/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/img)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
