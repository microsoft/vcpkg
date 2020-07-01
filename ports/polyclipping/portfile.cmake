vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polyclipping
    FILENAME "clipper_ver6.4.2.zip"
    NO_REMOVE_ONE_LEVEL
    SHA512 ffc88818c44a38aa278d5010db6cfd505796f39664919f1e48c7fa9267563f62135868993e88f7246dcd688241d1172878e4a008a390648acb99738452e3e5dd
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cpp
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
