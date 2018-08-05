include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 0.8.0
        SHA512 dee0e50050fbd98f666fbee17ed13de0da07f8a746fcfd493978caa8ed422fc49b33447ea8f47fec384ec2f098e4b0c420954cbfa576282f1e9b2d901fde0664
        HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSHIVA_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shiva)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shiva)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shiva/LICENSE ${CURRENT_PACKAGES_DIR}/share/shiva/copyright)
