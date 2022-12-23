vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/kumi
    REF v3.0
    SHA512 e64d3bccf8672d7aa24a2544d151c77cc4880c40aaf14a6969559bc7cd621774134986fa46b1f8a710faeb5cddad1fec69a77aef193e340ceea81db448024cbd
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure( SOURCE_PATH "${SOURCE_PATH}"
                       OPTIONS -DKUMI_BUILD_TEST=OFF
                       -DCMAKE_DISABLE_FIND_PACKAGE_Python=ON
                     )

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/kumi")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
