set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenVPN/openvpn3
    REF release/3.4.1
    SHA512 2d0a7d2d48047c969ba1cb49b34d51c85dd82ae97296d7c096ead13a8e7cc69fa3908262228e29d93f60b7273814d8ef5a402a5d401cd7f91370868d5d308678
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
