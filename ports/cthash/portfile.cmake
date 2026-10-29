vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/cthash
    REF cb62928766c9623bf86072e412220d59a65407d4
    SHA512 9ce214eff8772fcbdeac147ffdb7dadb8755bf101ed8b5fd5961ed57bfe314392dc42d40699ad1ff41d823cc132488ae936b2cb17615a1ce6740cba655e89498
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/include/cthash" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
