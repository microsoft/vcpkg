include(vcpkg_common_functions)

IF (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF e2c093cb7857fa8dc5716470613c46bad508007a # v0.3.2
    SHA512 1506fe5e571a9194a12ee4b8d874db95c75243bd4181c4e67d896a60f38489ba0765d898c84cb3bc8dabe87974bba31a66ee1effe886edd304e4eaaa686cd65e
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(USE_OPENSSL OFF)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DCMAKE_USE_OPENSSL=${USE_OPENSSL}
        -DLIBUS_USE_LIBUV=${USE_LIBUV}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/usockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/usockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/usockets/copyright)

vcpkg_copy_pdbs()