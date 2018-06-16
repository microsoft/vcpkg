include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF 4ea6cabdee6312d069ceb55195818e1daa331eb3
    SHA512 25bb3192037e01a3d2732a4b4941a9a67a6ddd7c218e8477202b16ff3ffaf399e0b2c15bebb2245765a0ef3c7c35bcf23c2525c4fad0cfd745118e3f82c8b90c
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DUNICORN_LIB_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/unicorn-lib RENAME copyright)