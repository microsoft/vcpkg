# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/indicators
    REF b85eadb47c1d0f0edbb4da9c3b6384ec6486b24a # v2.0
    SHA512 e9674440fa8643284a593b9e93345dc849301f42fe644b485e5dad1e12a20ef6687a2bf1eaeb2aec542d74544b7193c9b76b0166d7570781bc11604c71e8132a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINDICATORS_BUILD_TESTS=OFF
        -DINDICATORS_SAMPLES=OFF
        -DINDICATORS_DEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/indicators)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
