include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF d1c0918397ce2e5b1631686ff85a475eface027a
    SHA512 1a2d2cf9bf34210068de4dfb70c0511dd661f2dd1ee574ed5d7b9f8f94bb6f0bf455b1a78633ad776357e1d7ef179231089d6936fd00ad11a3b073a5ba1bed2b
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