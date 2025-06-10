vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO basiliscos/cpp-rotor
    REF "v${VERSION}"
    SHA512 3a1ccf29101bc6b5942382e5e7164ef7e9b8f4696ef1ac819a28391a98b366cf46a90f737b08c573a741148ef944b319469f50c0aa6ed4ada87222284653a5f9
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asio    ROTOR_BUILD_ASIO
        ev      ROTOR_BUILD_EV
        fltk    ROTOR_BUILD_FLTK
        thread  ROTOR_BUILD_THREAD
        wx      ROTOR_BUILD_WX
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DROTOR_BUILD_EXAMPLES=OFF
        -DROTOR_BUILD_TESTS=OFF
        -DROTOR_BUILD_DOC=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rotor)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")