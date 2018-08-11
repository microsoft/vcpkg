include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/embree-3.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/embree/embree/archive/v3.2.0.zip"
    FILENAME "embree-3.2.0.zip"
    SHA512 75a969f5bb452986c3123543623a315172b7e1dac1d1017559d3d202ccf028d216337952e2b0b1df73975ac8d3928f06028d4a2f1a5d1a4210e80f818c416958
)
vcpkg_extract_source_archive(${ARCHIVE})

file(REMOVE ${SOURCE_PATH}/common/cmake/FindTBB.cmake)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(EMBREE_STATIC_RUNTIME ON)
else()
    set(EMBREE_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        "-DTBB_LIBRARIES=TBB::tbb"
        "-DTBB_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include"
)

# just wait, the release build of embree is insanely slow in MSVC
# a single file will took about 2-10 min
vcpkg_install_cmake()
vcpkg_copy_pdbs()

# these cmake files do not seem to contain helpful configuration for find libs, just remove them
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/embree-config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/embree-config-version.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/embree-config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/embree-config-version.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/models)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/models)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/embree)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc ${CURRENT_PACKAGES_DIR}/share/embree/doc)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/embree)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/embree/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/embree/copyright)
