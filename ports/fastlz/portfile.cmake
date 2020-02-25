include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ariya/FastLZ
    REF f1217348a868bdb9ee0730244475aee05ab329c5
    SHA512 444465aa5d830f54b86112cbd0431099d8e1a11d46bd02e1dc5dc0b3d772736624287e6bc328159195197d0d08cb659d39c59c5336ffa432032f3798e04f4440
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fastlz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fastlz/LICENSE ${CURRENT_PACKAGES_DIR}/share/fastlz/copyright)
vcpkg_copy_pdbs()
