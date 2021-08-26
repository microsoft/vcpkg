vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ybainier/Hypodermic
    REF 3e86a5a1fd5e8279d6ca461f9f398fa3f3c2eddc # v2.5.2
    SHA512 1af2a94037aa5bf8c65aceb4a2e941f7f6d016422d345f86280085115e9bb871387370158b1a83891be8efdadd4eea0a1f8905225ebee64c000ec9023a9f212e
    HEAD_REF master
    PATCHES
        "disable_hypodermic_tests.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug
)


# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hypodermic/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hypodermic/LICENSE ${CURRENT_PACKAGES_DIR}/share/hypodermic/copyright)
