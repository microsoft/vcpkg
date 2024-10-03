# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zserge/fenster
    REF 92aa0ecd30f1c1c8175d72042c319268568434fb
    SHA512 2909afe3d5cab88c4353e2632d05b2ff196fb21ebb9789ccb851e328961836b4b5d5eca80843c38e7924ef48ff02106fc4f06ebe5ffe71f71b5bbbb4dad229b9
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/fenster.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/fenster_audio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
