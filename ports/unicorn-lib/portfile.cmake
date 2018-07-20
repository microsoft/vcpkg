include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF 10e940d50daeb63464f1000e688304b6d48761cd
    SHA512 752df8f09a9512b9775f2ac652e98449767b446413c4340d2ffefd9524aabc3d0ecb9e7a16f91a8aff0c4a540f16d084f9c52dd0894c8bbaecdc748f1eb60bd2
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