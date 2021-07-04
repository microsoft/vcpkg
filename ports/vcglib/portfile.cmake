vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnr-isti-vclab/vcglib
    REF v1.0.1
    SHA512 55d1854054744abae2d41e7b5041df89253bae108df5fc1cfe777013de7192dce04bc474475cb11a1d0343ebcab1ea61b381d9d9c36c452528043e85e75bc211
    PATCHES consume-vcpkg-eigen3.patch
    )

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vcglib/copyright COPYONLY)

file(COPY ${SOURCE_PATH}/vcg/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/vcg)
file(COPY ${SOURCE_PATH}/wrap/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/wrap)
file(COPY ${SOURCE_PATH}/img/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/img)
