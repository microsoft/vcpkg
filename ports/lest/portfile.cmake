include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/lest
    REF v1.34.1
    SHA512 e2e2764f4095ff95b9faab01c2cb4bd2b527d3e582eba10a699d8e44d194c90409eabbc842cf7627fd6f1f1eaa4c45cf314959e79aea858346fb844962009f92
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/lest RENAME copyright)
