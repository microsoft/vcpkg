vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vectorclass/version2
    REF v2.02.00
    SHA512 758cf12309ba9d5b1cc22db197d024880f62778de939af80f575dad9a3a2c3f256bc3228ee3dbd41a9da6e88835318f362b8255ff32bc8cadfe12bd2be4c36b5
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
