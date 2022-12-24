vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/tts
    REF 2.2
    SHA512 d3c17a4490f483bee724578301be17f042df7aa996c9309347875b54b25c868f5af6dcd72c15839f48f16973a564d578590f1ae517045053fbdb5b244860db67
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure( SOURCE_PATH "${SOURCE_PATH}"
                       OPTIONS -DTTS_BUILD_TEST=OFF
                     )

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/tts")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
