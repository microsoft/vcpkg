include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bullet3-98d47809b4273d97ea06c9b2137ada10af581bb9)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/bulletphysics/bullet3/archive/98d47809b4273d97ea06c9b2137ada10af581bb9.zip"
    FILENAME "bullet3-98d47809b4273d97ea06c9b2137ada10af581bb9.zip"
    SHA512 eaa3aa5ff124c87f153a9faeabe00955aaa2d87ed5d2297a96e02531eb7fd1286f2b654bd45401690747ca4391dd7c18486f4cbac0da7e835d52874345b9811d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
        -DBUILD_DEMOS=OFF
        -DBUILD_CPU_DEMOS=OFF
        -DBUILD_BULLET2_DEMOS=OFF
        -DBUILD_BULLET3=OFF
        -DBUILD_EXTRAS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_SHARED_LIBS=ON
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
