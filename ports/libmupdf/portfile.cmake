vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF f39eee48564274635e231e2ab652221cce2ec1bd # 1.21.1
    SHA512 aa16d0939739f96c66ee802032c321adcebc86c9fa5bfe7ec64f20614377a4f61c358270216b57a1e4b1929337c4cc856d9ec4666ed8f0edaeaa7f2336a84ac3
    HEAD_REF master
    PATCHES
        dont-generate-extract-3rd-party-things.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(COPY "${SOURCE_PATH}/include/mupdf" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
