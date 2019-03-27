include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ariya/FastLZ
    REF f1217348a868bdb9ee0730244475aee05ab329c5
    SHA512 edfefbf4151e7ea6451a6fbb6d464a2a0f48ab50622f936634ec3ea4542ad3e1f075892a422e0fc5a23f2092be4ec890e6f91c4622bcd0d195fed84d4044d5df
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fastlz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fastlz/LICENSE ${CURRENT_PACKAGES_DIR}/share/fastlz/copyright)
vcpkg_copy_pdbs()
