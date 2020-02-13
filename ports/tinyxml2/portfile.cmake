include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 9c740e8d2341bd46dbe8e87053cdb4d931971967 # 7.1.0
    SHA512 a0e9634875f4c5f426f41510040b9f078af24adf176d2daf3cb3343d629b8068f3a1841df80a06d977bd19e3acaaa3736719a900754c1fe675631f3337820130
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/tinyxml2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY
  ${SOURCE_PATH}/readme.md
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyxml2
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyxml2/readme.md ${CURRENT_PACKAGES_DIR}/share/tinyxml2/copyright)
