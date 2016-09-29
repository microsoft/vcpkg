include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cocos2d-x-cocos2d-x-3.10)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/cocos2d/cocos2d-x/archive/cocos2d-x-3.10.tar.gz"
    FILENAME "cocos2d-x-3.10.tar.gz"
    MD5 7c67068675ad28374448e844b0e463ff
)
vcpkg_download_distfile(DEPS_ARCHIVE_FILE
    URLS "https://github.com/cocos2d/cocos2d-x-3rd-party-libs-bin/archive/v3-deps-79.zip"
    FILENAME "cocos2d-x-v3-deps-79.zip"
    MD5 5d88ff867205080b9ee8da532437e891
)

vcpkg_extract_source_archive(${ARCHIVE_FILE})

if(NOT EXISTS ${SOURCE_PATH}/external/unzip)
    message(STATUS "Extracting dependencies ${DEPS_ARCHIVE_FILE}")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/deps)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} -E tar xjf ${DEPS_ARCHIVE_FILE}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/deps
        LOGNAME extract-deps
    )
    file(REMOVE_RECURSE ${SOURCE_PATH}/external)
    file(RENAME ${CURRENT_BUILDTREES_DIR}/deps/cocos2d-x-3rd-party-libs-bin-3-deps-79 ${SOURCE_PATH}/external)
endif()
message(STATUS "Extracting dependencies done")

file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindGLFW3.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_CHIPMUNK=OFF
        -DUSE_BOX2D=OFF
        -DUSE_BULLET=OFF
        -DUSE_RECAST=OFF
        -DUSE_WEBP=OFF
        -DBUILD_SHARED_LIBS=ON
        -DUSE_PREBUILT_LIBS=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/licenses/LICENSE_cocos2d-x.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cocos2d-x RENAME copyright)
vcpkg_copy_pdbs()

