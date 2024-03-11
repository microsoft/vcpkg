vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DigitalInBlue/iowahills_dsp
    REF "v${VERSION}"
    SHA512 0047d8f8f2962b082d14b0a93c30b0a9d5a8be106a71053d15c5743dc4a1ad2744e0261989a42d190536fb8fb203c8ab2d50bac1fcdad309e75d07fd0dfadfa6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/iowa_hills_dsp.lib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/iowa_hills_dsp" RENAME copyright)
