include(vcpkg_common_functions)

IF (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF v0.1.2
    SHA512 fedfc50e3498320600247920360db38977f5be4aa9067146a5a0db13dc789b8fa39fa9315b19f56555915bcb818cd0f77ccf0b8cb40ed48e2b193b083d16b242
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