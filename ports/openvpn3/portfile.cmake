include(vcpkg_common_functions)

set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenVPN/openvpn3
    REF 3d5dd9ee3b4182032044d775de5401fc6a7a63ae
    SHA512 6a8ed20662efa576c57f38fb9579c5808f745d44e8cd6a84055bec10a58ede5d27e207a842f79ac6a2f7d986494fbd2415f9d59e2b23bd38e45c68546a227697
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/openvpn DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(COPY ${SOURCE_PATH}/client/ovpncli.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/openvpn/)

file(GLOB_RECURSE HEADERS ${CURRENT_PACKAGES_DIR}/include/openvpn/*)
foreach(HEADER IN LISTS HEADERS)
    file(READ "${HEADER}" _contents)
    string(REPLACE "defined(USE_ASIO)" "1" _contents "${_contents}")
    string(REPLACE "#ifdef USE_ASIO\n" "#if 1\n" _contents "${_contents}")
    string(REPLACE "defined(USE_MBEDTLS)" "1" _contents "${_contents}")
    string(REPLACE "#ifdef USE_MBEDTLS\n" "#if 1\n" _contents "${_contents}")
    file(WRITE "${HEADER}" "${_contents}")
endforeach()

file(INSTALL
    ${SOURCE_PATH}/COPYRIGHT.AGPLV3
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/openvpn3 RENAME copyright)
