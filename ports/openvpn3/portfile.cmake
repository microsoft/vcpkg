if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenVPN/openvpn3
    REF "release/${VERSION}"
    SHA512 ff763703eb7d292c768b569cff3c575993d1f304221dcc423c869b84aa13d07bfd3c572977792fed8eb8c24f6fce9a462d6190468d1ce071fcc41ed7aba62603
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
