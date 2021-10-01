vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenVPN/tap-windows6
    REF 0e30f5c13b3c7b0bdd60da915350f653e4c14d92
    SHA512 88edecccd4818091f7d70b66f3dfa07146f010a064829dc971abdd0c180ce1f72db9d8f3a1c9f5b4fb3f31e7afe3eadbd7d6f7d711f698e723441d30beaf9e30
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/src/tap-windows.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/COPYRIGHT.MIT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/tap-windows6 RENAME copyright)
