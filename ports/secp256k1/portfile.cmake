include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bitcoin-core/secp256k1"
    REF "0b7024185045a49a1a6a4c5615bf31c94f63d9c4"
    SHA512 befced86481f5619722431e7348a189385efce4f9ff6573f9e44eae502ba19f586c51c196e48bd29807a27fe96315e219c72a12463e57340b4022543d3846750
)

file(COPY ${CURRENT_PORT_DIR}/libsecp256k1-config.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/secp256k1 RENAME copyright)
