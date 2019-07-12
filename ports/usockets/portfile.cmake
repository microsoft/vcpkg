include(vcpkg_common_functions)

IF (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF c026a7eff731ec15b37f4886c775c51c24ce5434
    SHA512 c2209880b1db788c14362bfdb8c35badcd2ada2ab75ce79b831707c269ac537008dd42a2f25239985d88014079294dda957a28e581f2b0240f4e624d62677440
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