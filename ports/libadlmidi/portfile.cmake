vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Wohlstand/libADLMIDI
    REF "v${VERSION}"
    SHA512 780fd35fbe2b2f84fb5642e74bd327496a5eb74f1068a74bb6a0bc58f7d5f43b88bc0d14d72ff7fb4354b2f7de11e93410202af44b6c9488659fa407fb449927
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_NUKED_OPL2_LLE_EMULATOR=ON
        -DUSE_NUKED_OPL3_LLE_EMULATOR=ON
        -DUSE_HW_SERIAL=ON
        -DWITH_HQ_RESAMPLER=OFF # requires zita-resampler
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libADLMIDI)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    COMMENT [[
Linking against libADLMIDI produces a work covered by GPL-3.0-or-later: the core
library and the public header are GPL v3+, and the other licenses below apply to
individual components. The License section of the project's README, in the source
distribution, says which component is under which.

No license is granted for the embedded instrument banks under fm_banks_new/greyzone/.
Upstream's statement of their status is reproduced below as README.txt. Configure
with -DBUILD_NO_GREY_BANKS=ON to exclude those banks.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.GPL-3.txt"
        "${SOURCE_PATH}/LICENSE.LGPL-2.1.txt"
        "${SOURCE_PATH}/src/chips/ymf262_lle/LICENSE"
        "${SOURCE_PATH}/src/chips/ymfm/LICENSE"
        "${SOURCE_PATH}/src/chips/opal/LICENSE.txt"
        "${SOURCE_PATH}/src/midiseq/LICENSE.txt"
        "${SOURCE_PATH}/src/models/LICENSE.txt"
        "${SOURCE_PATH}/src/wopl/LICENSE.txt"
        "${SOURCE_PATH}/src/structures/LICENSE"
        "${SOURCE_PATH}/fm_banks_new/LICENSE-AIL2.txt"
        "${SOURCE_PATH}/fm_banks_new/LICENSE-DMXOPL.txt"
        "${SOURCE_PATH}/fm_banks_new/LICENSE-FMSynth.txt"
        "${SOURCE_PATH}/fm_banks_new/LICENSE-IMF90.txt"
        "${SOURCE_PATH}/fm_banks_new/LICENSE-TheFatMan.txt"
        "${SOURCE_PATH}/fm_banks_new/greyzone/README.txt"
)
