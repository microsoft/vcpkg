vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tplgy/cppcodec
    REF v0.2
    SHA512 50c9c81cdb12560c87e513e1fd22c1ad24ea37b7d20a0e3044d43fb887f4c6494c69468e4d0811cd2fc1ae8fdb01b01cfb9f3cfdd8611d4bb0221cbd38cbead3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
       -DBUILD_TESTING=OFF
    
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
    

vcpkg_fixup_pkgconfig()
