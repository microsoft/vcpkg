include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF c35d29bf873744d2e74f20444eb6dbef6acfe21c # 1.16.1
    SHA512 e21780283666224f2e5b8e70ff9dee7f6a43468fa4ed295301d5a97f6ecbf56870a07a3fe509a816dc5c1453e6532d27d27a46a1c2381c30770d0ebf45222ee9
    HEAD_REF master
	PATCHES
        Fix-error-C2169.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/mupdf DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
