set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenVPN/openvpn3
    REF release/3.7
    SHA512 de95bd2b1a01179aa81e1612be175540c2486b856f66880372d09966655bbbadd71d874ed49b032566dde2896207bc76298c5cfcf73e86272c04d5aaa977d660
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(COPY "${SOURCE_PATH}/openvpn" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/client/ovpncli.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/openvpn")

file(GLOB_RECURSE HEADERS "${CURRENT_PACKAGES_DIR}/include/openvpn/*")
foreach(HEADER IN LISTS HEADERS)
    file(READ "${HEADER}" _contents)
    string(REPLACE "defined(USE_ASIO)" "1" _contents "${_contents}")
    string(REPLACE "#ifdef USE_ASIO\n" "#if 1\n" _contents "${_contents}")
    string(REPLACE "defined(USE_MBEDTLS)" "1" _contents "${_contents}")
    string(REPLACE "#ifdef USE_MBEDTLS\n" "#if 1\n" _contents "${_contents}")
    file(WRITE "${HEADER}" "${_contents}")
endforeach()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-openvpn CONFIG_PATH share/unofficial-openvpn)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL
    "${SOURCE_PATH}/COPYRIGHT.AGPLV3"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
