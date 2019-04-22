include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF 1.0.17
    SHA512 faf6ab57d113b6b1614b51390823a646f059018327b6f493e9e918a908652d0932a75a1a6683032b7a3869f516f387d67acdf944568387feddff7b2f5b6e77d6
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/sodium TARGET_PATH share/sodium)

file(COPY
    ${SOURCE_PATH}/src/libsodium/include/sodium.h
    ${SOURCE_PATH}/src/libsodium/include/sodium
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(COPY
    ${SOURCE_PATH}/builds/msvc/version.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/sodium
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ ${CURRENT_PACKAGES_DIR}/include/sodium/export.h _contents)
    string(REPLACE "#ifdef SODIUM_STATIC" "#if 1 //#ifdef SODIUM_STATIC" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/sodium/export.h "${_contents}")
endif ()

vcpkg_copy_pdbs()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsodium
    RENAME copyright
)
