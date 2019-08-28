include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF bc6ea664b17fb3736e1330e908aee00c4f3a750b
    SHA512 a629c0a3d6ca3c6e7681cb8632076940c81de1493e1fcdfb7cdfb7eab4c4a05ccf3b5d53c4c325548e770176ce36fb4e67f212f65713d2dacb679da570930380
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/src  DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/src ${CURRENT_PACKAGES_DIR}/include/uwebsockets/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)

