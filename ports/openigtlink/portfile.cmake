include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openigtlink/OpenIGTLink
    REF  v3.0
    SHA512 3f62ef1c4ca349f653712cecd43af8b5afce642cc3950256498905999861d68143ba3003f6b0899f5f5c3c5c755eb282c63488ac59b4793b3622a47571452739
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
         -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/igtl/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)