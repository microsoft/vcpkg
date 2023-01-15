vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REGEX REPLACE "^(v[0-9]+)[.]([0-9])[.]([0-9]+)\$" "\\1.0\\2.\\3" git_ref "v${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/eve
    REF "${git_ref}"
    SHA512 5623587de77c3e321555ca99326829928f69c5ac499d2abedfb18860e8c2a4c7dd5b408afef3ae2f8681cb363ffbfbc869dbf28c90e62e2b0abca62e03d08d12
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/eve-${VERSION}")
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/eve/eve-config.cmake")
    message(FATAL_ERROR "CMake config is missing")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
