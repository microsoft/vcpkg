include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zstd-1.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/facebook/zstd/archive/v1.1.1.zip"
    FILENAME "zstd-1.1.1.zip"
    SHA512 c96a97519202a759c62f661c7bbaeaa0d48e4e78588a8232ad23fd78fe7c3440f1f07d996dcf07daa652569e1c5e39cb7b93103b9ec7845db05b161ec29a8dde
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
    OPTIONS -DZSTD_LEGACY_SUPPORT=1
)
vcpkg_build_cmake()

# Manual install
message(STATUS "Installing")

file(COPY ${SOURCE_PATH}/lib/zstd.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/lib/common/zbuff.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/lib/dictBuilder/zdict.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

set(RELDIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/Release)
set(DEBDIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/Debug)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL ${RELDIR}/zstdlib.1.1.1024_${TRIPLET_SYSTEM_ARCH}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib RENAME zstdlib.lib)
    file(INSTALL ${DEBDIR}/zstdlib.1.1.1024_${TRIPLET_SYSTEM_ARCH}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib RENAME zstdlib.lib)
    file(INSTALL ${RELDIR}/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dll")
    file(INSTALL ${DEBDIR}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin FILES_MATCHING PATTERN "*.dll")
    vcpkg_copy_pdbs()
else()
    file(INSTALL ${RELDIR}/zstdlib_${TRIPLET_SYSTEM_ARCH}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib RENAME zstdlib.lib)
    file(INSTALL ${DEBDIR}/zstdlib_${TRIPLET_SYSTEM_ARCH}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib RENAME zstdlib.lib)
endif()


# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zstd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zstd/LICENSE ${CURRENT_PACKAGES_DIR}/share/zstd/copyright)

message(STATUS "Installing done")
