include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LibRaw-0.17.2)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.libraw.org/data/LibRaw-0.17.2.zip"
    FILENAME "LibRaw-0.17.2"
    SHA512 97d34c84dafdcad300d607fbd4df7b120aea1ecdbc2783a8616bc423fa6a7a15adfbeb975f8dab021be09d08ef466c401a3b65bfd1abcfa49d31d4ab91873e60
)
set(LIBRAW_CMAKE_COMMIT "ffebb680e7457dad27fb74b5a52d6d2960121303")
set(LIBRAW_CMAKE_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LibRaw-cmake-${LIBRAW_CMAKE_COMMIT})
vcpkg_download_distfile(CMAKE_BUILD_ARCHIVE
    URLS "https://github.com/LibRaw/LibRaw-cmake/archive/${LIBRAW_CMAKE_COMMIT}.zip"
    FILENAME "LibRaw-cmake-${LIBRAW_CMAKE_COMMIT}"
    SHA512 5f4ce4aa9da7d27c19466882a1e118e7890db767d46765efb80d97a1f2817315864d063dd4316b12f9363a64434e2b7af5a7ef804313f5c6ca23d50d6c1a75aa
)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_extract_source_archive(${CMAKE_BUILD_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src)

# Copy the CMake build system from the external repo
file(COPY ${LIBRAW_CMAKE_SOURCE_PATH}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${LIBRAW_CMAKE_SOURCE_PATH}/cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB RELEASE_EXECUTABLES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(REMOVE ${RELEASE_EXECUTABLES})
file(GLOB DEBUG_EXECUTABLES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${DEBUG_EXECUTABLES})

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libraw)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libraw/COPYRIGHT ${CURRENT_PACKAGES_DIR}/share/libraw/copyright)

vcpkg_copy_pdbs()