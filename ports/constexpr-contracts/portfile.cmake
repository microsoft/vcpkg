vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjdb/constexpr-contracts
    REF 58154e9010cb80aad4e95ef6f1835ebd7db3780a # commit 2020-05-25
    SHA512 b634267a4044cd712c8e52f65cd305f437864cab591f2b22104581f70b305ba52889dd46724e6047386463a010ee78fdd951411ea3691b5725d52d13f7adda76
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/constexpr-contracts)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib
                    ${CURRENT_PACKAGES_DIR}/debug)
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
