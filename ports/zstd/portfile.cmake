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

# Manual install since zstd guarded all their installation functions behind an if (UNIX)
message(STATUS "Installing")

file(COPY ${SOURCE_PATH}/lib/zstd.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/lib/common/zbuff.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/lib/dictBuilder/zdict.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Copy the command-line zstd exe
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/programs/Release/
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools
    FILES_MATCHING PATTERN "zstd.exe")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # Dynamic libs of zstd appear to start with "zstdlib."
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/Release/
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        FILES_MATCHING PATTERN "zstdlib.*.lib")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/Release/
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
        FILES_MATCHING PATTERN "zstdlib.*.dll")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/Debug/
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        FILES_MATCHING PATTERN "zstdlib.*.lib")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/Debug/
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
        FILES_MATCHING PATTERN "zstdlib.*.dll")
else()
    # Static libs of zstd appear to start with "zstdlib_"
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/Release/
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        FILES_MATCHING PATTERN "zstdlib_*.lib")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/Debug/
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        FILES_MATCHING PATTERN "zstdlib_*.lib")
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zstd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zstd/LICENSE ${CURRENT_PACKAGES_DIR}/share/zstd/copyright)

vcpkg_copy_pdbs()
message(STATUS "Installing done")
