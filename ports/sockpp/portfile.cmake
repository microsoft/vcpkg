include(vcpkg_common_functions)

vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fpagliughi/sockpp
    REF d8c86c01db43542a06ad05424da037f6b9892253
    SHA512 9b7ae3fea08bfd4a0d6479d7fbcc24da9101476c4f8e4a684138c7d974827cdf374282a4641e58f03c08aeb83f2c1856fc3c5193e5847fb4b3d9182c1c396087
    HEAD_REF master
)

vcpkg_replace_string(${SOURCE_PATH}/CMakeLists.txt "\${SOCKPP}-static" "\${SOCKPP}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOCKPP_BUILD_SHARED=OFF
        -DSOCKPP_BUILD_STATIC=ON
        -DSOCKPP_BUILD_DOCUMENTATION=OFF
        -DSOCKPP_BUILD_EXAMPLES=OFF
        -DSOCKPP_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
file(INSTALL ${CURRENT_PORT_DIR}/sockppConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
