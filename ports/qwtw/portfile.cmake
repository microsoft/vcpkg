vcpkg_fail_port_install(ON_TARGET "LINUX" "OSX" "UWP" "ANDROID" ON_ARCH "arm" "x86" ON_LIBRARY_LINKAGE "static")

vcpkg_from_github(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO ig-or/qwtw
   REF 54bedcce743991f2f274bebda0ee399683a9e9bb
   SHA512 defd7f199c8bf490f5ac69deade4a4a45581c0fa5b79cf2aa1fbec8c46bbbe1d9c9cf0f7ba383e8e92f5e6145b42a837b7dc555017893797f72dab1ce490e57a
   HEAD_REF master
)

 
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
