vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO brainboxdotcc/DPP
        REF v9.0.9
        SHA512 5baac3dadb9685c325baea2af41e85d15233dddf35122c85f658a3e19094aab7709c1bdec87e47edf0331178ab508f0f84072bf266ac1e3a483debccbf3d8d66
        HEAD_REF 235cd5a
)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/dpp RENAME copyright)