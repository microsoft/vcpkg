# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/json
    REF f357d7269b7503eed21d0c3b98b9075c28a98f56 # accessed on 2020-09-14
    SHA512 4a4be970779ed0c6044c7ad40918ad6b3908ca10dbfb3738cbebb62154d437ad13ca27947119a6b1a6c8d92b22a9282477c73ddc5721ca30b8b355b77d7ce729
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DTAOCPP_JSON_BUILD_TESTS=OFF
        -DTAOCPP_JSON_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/taocpp-json/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/share/doc
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
file(COPY ${SOURCE_PATH}/LICENSE.double-conversion DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/LICENSE.itoa DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/LICENSE.ryu DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
