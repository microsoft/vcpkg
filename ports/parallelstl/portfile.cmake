include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/parallelstl
    REF  20190522
    SHA512 ad1b820ff4c2ce45ea3d6069dc8d5219449baca44d0bce86482aca247db7a4191e2bce10ab8365056ca278322809fdbb096519436e850cf95f2bb98fa7bc1ab1
    HEAD_REF master
    PATCHES fix-install-header.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DPARALLELSTL_USE_PARALLEL_POLICIES=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)