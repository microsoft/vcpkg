vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AviSynth/AviSynthPlus
    REF e17f4f80055009bf45b37e1b6d1790bd1c1a93b2 # 3.5.0
    SHA512 40d2f63416e0e812dd6c7db9b17c09c51295d192bdc4dc46daa063e20731a3451a2b797dab351d31dbb43842eb2c2cdb148da16e5b92816423e3cbf40fff23b0
    HEAD_REF master
    PATCHES
        generate-version-3.5.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_PLUGINS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/distrib/gpl.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/avisynthplus RENAME copyright)
