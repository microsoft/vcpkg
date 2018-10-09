set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/asyncplusplus-1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Amanieu/asyncplusplus/archive/v1.0.tar.gz"
    FILENAME "asyncplusplus-1.0.zip"
    SHA512 bb1fc032d2d8de49b4505e0629d48e5cfa99edfcafbf17848f160ceb320bcd993f1549095248d1a0ef8fc1ec07ecbaad6b634a770ddc1974092d373a508a5fe3
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)


vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/asyncplusplus-1.0/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/asyncplusplus)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/asyncplusplus/LICENSE ${CURRENT_PACKAGES_DIR}/share/asyncplusplus/copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/cmake/Async++-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Async++-debug.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/cmake/Async++-release.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Async++-release.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/cmake/Async++.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Async++.cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/cmake/Async++Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Async++Config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(COPY ${CURRENT_PORT_DIR}/CONTROL DESTINATION ${CURRENT_PACKAGES_DIR})
