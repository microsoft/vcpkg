if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenVPN/openvpn3
    REF "release/${VERSION}"
    SHA512 f096644078c10022685c1a8f7e0afddf352b4a5c229a772d24adbc6ec3f44e27501beabd28c4da1b6b182ae9d220b80865757693d52d085817d42f2322b71213
    HEAD_REF master
    PATCHES
        dependencies.diff
        mbedtls-compat.diff
        only-library.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SWIG_LIB=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
        -DUSE_MBEDTLS=1   # vcpkg legacy choice
)

vcpkg_cmake_install()

file(COPY "${SOURCE_PATH}/client/ovpncli.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/openvpn")
file(COPY "${SOURCE_PATH}/openvpn" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB_RECURSE HEADERS "${CURRENT_PACKAGES_DIR}/include/openvpn/*")
foreach(HEADER IN LISTS HEADERS)
    file(READ "${HEADER}" _contents)
    string(REPLACE "defined(USE_ASIO)" "1" _contents "${_contents}")
    string(REPLACE "#ifdef USE_ASIO\n" "#if 1\n" _contents "${_contents}")
    string(REPLACE "defined(USE_MBEDTLS)" "1" _contents "${_contents}")
    string(REPLACE "#ifdef USE_MBEDTLS\n" "#if 1\n" _contents "${_contents}")
    file(WRITE "${HEADER}" "${_contents}")
endforeach()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-openvpn3)
# Transitional
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-openvpnConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-openvpn")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.rst" "${SOURCE_PATH}/COPYRIGHT.AGPLV3")
