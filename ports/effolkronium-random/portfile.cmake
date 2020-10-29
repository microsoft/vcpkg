vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effolkronium/random
    REF ead633a312d1a41baae72c22f0b2fd28b1853558 # v1.3.1
    SHA512 598e6edfc124f4619ea37292ea01c67ce87181476957137175cf9e9ca3c9cf44dfde3c2cebc0e57b4c8497058a320f8ce535f66bad5f8db5ceacc0cedd40936e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
		-DRandom_BuildTests=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/ TARGET_PATH /share/effolkronium_random)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/effolkronium-random RENAME copyright)
