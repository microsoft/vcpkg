include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/azmq
    REF v1.0.2
    SHA512 6e60a670d070ddf84dbd406e88225ff12f84ce39e0e64e9aff4314e174506c286d72cfebb5e2e51eab221f6e163a17cce539d052cea3c18954ec495b096f087b
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/azmq DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE-BOOST_1_0
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/azmq RENAME copyright)
