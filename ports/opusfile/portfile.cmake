include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opusfile
    REF v0.11
    SHA512 b67976176ffacbeecacd00815877d1b332e149430b49f68d41d6a2f95e6d291e979214903314e14b4cc3f20e07ec8975b906f12f12aef8c786f74f6160d8791d
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if("opusurl" IN_LIST FEATURES)
    set(BUILD_OPUSURL ON)
else()
    set(BUILD_OPUSURL OFF)
endif()

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_OPUSURL=${BUILD_OPUSURL}
    OPTIONS_DEBUG
        -DOPUSFILE_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# make includes work with MSBuild integration
file(READ ${CURRENT_PACKAGES_DIR}/include/opus/opusfile.h OPUSFILE_H)
    string(REPLACE "# include <opus_multistream.h>" "# include \"opus_multistream.h\"" OPUSFILE_H "${OPUSFILE_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/opus/opusfile.h "${OPUSFILE_H}")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/opusfile)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opusfile/COPYING ${CURRENT_PACKAGES_DIR}/share/opusfile/copyright)
