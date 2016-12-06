 # libFLAC uses winapi functons not avalible in WindowsStore
if (VCPKG_TARGET_ARCHITECTURE STREQUAL arm OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/flac-1.3.1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.xiph.org/releases/flac/flac-1.3.1.tar.xz"
    FILENAME "flac-1.3.1.tar.xz"
    SHA512 923cd0ffe2155636febf2b4633791bc83370d57080461b97ebb69ea21a4b1be7c0ff376c7fc8ca3979af4714e761112114a24b49ff6c80228b58b929db6e96d5)
	
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DLIBFLAC_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}
            -DLIBFLAC_OGG_LIB=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/ogg.lib
            -DLIBFLAC_OGG_INCLUDES=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include
        OPTIONS_DEBUG
            -DLIBFLAC_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/FLAC/export.h "#undef FLAC_API\n#define FLAC_API\n")
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/FLAC++/export.h "#undef FLAC_API\n#define FLAC_API\n")
endif()

# This license (BSD) is relevant only for library - if someone would want to install
# FLAC cmd line tools as well additional license (GPL) should be included
file(COPY ${SOURCE_PATH}/COPYING.Xiph DESTINATION ${CURRENT_PACKAGES_DIR}/share/libflac)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libflac/COPYING.Xiph ${CURRENT_PACKAGES_DIR}/share/libflac/copyright)
