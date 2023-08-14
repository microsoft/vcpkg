vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REGEX REPLACE "^(v[0-9]+)[.]([0-9])[.]([0-9]+)\$" "\\1.0\\2.\\3" git_ref "v${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/eve
    REF "${git_ref}"
    SHA512 20b55996465fa5016d43cee95541510b6470b2358635b0e269965d3fb43731e83b92bc2df0502fcdfadd31de47f877f22b1c6ae84638f1f3db92c70315cc1b29
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
