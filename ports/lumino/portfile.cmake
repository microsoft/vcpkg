vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuminoEngine/Lumino
    REF vcpkg
    SHA512 403a8284426b6d2f769636d90332d91f364ce824cc728895e6c7ce95a0677101f0f52b1bc7689d04f9605aabcc7124e19c2d728439b3b4ef0080ee8b17bbf91f
    HEAD_REF vcpkg
    #HEAD_REF main
)



vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    #OPTIONS -DINSTALL_DOCS=0 -DINSTALL_PKG_CONFIG_MODULE=1
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

#file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libogg" RENAME copyright)

# wget  -L 
# certutil -hashfile ./Lumino-main.zip SHA512

# wget --content-disposition https://github.com/LuminoEngine/Lumino/archive/refs/heads/vcpkg.tar.gz
# certutil -hashfile ./Lumino-vcpkg.tar.gz SHA512
# rm ./Lumino-vcpkg.tar.gz

