include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse/mosquitto
    REF v1.6.7
    SHA512 bc10a70815a8962e0ead06c36b312ea84e43db4e7c05ad940db91cacea92387a3b4f59f7de1606c4df56cd8c829433957733aa4007111d62bc0134e9cbb9ff3f
    HEAD_REF master
    PATCHES
        archive-dest.patch
        win64-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_SRV=OFF
        -DWITH_WEBSOCKETS=ON
        -DWITH_TLS=ON
        -DWITH_TLS_PSK=ON
        -DWITH_THREADING=ON
        -DDOCUMENTATION=OFF
    OPTIONS_RELEASE
        -DENABLE_DEBUG=OFF
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(CMAKE_HOST_WIN32)
  set(EXECUTABLE_SUFFIX ".exe")
else()
  set(EXECUTABLE_SUFFIX "")
endif()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_passwd${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/mosquitto_passwd${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_pub${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/mosquitto_pub${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_rr${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/mosquitto_rr${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_sub${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/mosquitto_sub${EXECUTABLE_SUFFIX})

#if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
#endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mosquitto RENAME copyright)
