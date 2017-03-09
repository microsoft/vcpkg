include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bullet3-2.86.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/bulletphysics/bullet3/archive/2.86.1.zip"
    FILENAME "bullet3-2.86.1.zip"
    SHA512 96c67bed63db4b7d46196cebda57b80543ea37bd19f013adcfe19ee6c2c3319ed007bcd1ebbe345d8c75b7e80588f4a7d85cb6a07e1a5eea759d97ce4d94f972
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
