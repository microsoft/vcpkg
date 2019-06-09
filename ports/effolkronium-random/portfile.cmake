include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effolkronium/random
    REF v1.3.0
    SHA512 68bd42e696a784832376950df7df9ddc8fc52ad073f44eddc7bcc2547278096ad3ec6463ce3a0e2e60a223e0852e68be4c2e9bcec4b237b9017ac2b03d5be812
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
