include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bullet3-2.83.7)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/bulletphysics/bullet3/archive/2.83.7.zip"
    FILENAME "2.83.7.zip"
    SHA512 70f849ce8f08e9c096051cc2da18f3c64a8f7965db0be4b1f7e6e6b4590cad9594b3475e9bcb655bb5159a1f8c4f42f4bd684a43322940deae2f70cd2e6ef9de
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
    -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
    -DBUILD_DEMOS=OFF
    -DBUILD_CPU_DEMOS=OFF
    -DBUILD_BULLET2_DEMOS=OFF
    -DBUILD_BULLET3=OFF
    -DBUILD_EXTRAS=OFF
    -DBUILD_UNIT_TESTS=OFF
	-DINSTALL_LIBS=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/bullet3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bullet3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/bullet3/copyright)

vcpkg_copy_pdbs()
