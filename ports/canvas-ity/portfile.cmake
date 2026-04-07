#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO a-e-k/canvas_ity
    REF fc5c115d8ca8be0cf81c2247270cc955f78b6138
    SHA512 19560fa09e8a8eeb09c05b26cf562dc506e6c88e1e66767a2214d2310188cb52ffe03294bd6448531703bd972e2a1995446a3cc20684c9d617ebe65ac93dd37a
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/canvas_ity.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
