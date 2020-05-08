vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF v9.5.8
    SHA512 dd5e4a2bae54aaadf6c1f41c2d3d46ae636f31432e2492bfaca125b9f349e50b177320ea9636998f1fd8c9671afb3eaed8606aee8b47395b563d73dadd09d222
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DUSE_TLS=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
