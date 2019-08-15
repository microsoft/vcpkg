include(vcpkg_common_functions)

IF (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF v0.3.1
    SHA512 f02b72844fb87acbf435d86a89e55244e45e047b049f36bda8e89c9ddeba8d7e6432008d33d33771faec60dcca60a3e3bfa3918c3af08ba80741e09df62c91fd
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