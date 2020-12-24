vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opusfile
    REF a55c164e9891a9326188b7d4d216ec9a88373739 # v0.12
    SHA512 cfe90b63b8ec027caf6d472167aba863e62f02650245cf0e4d9a543bb565c9088d38b45f7dc2d42cdfcdac5397c3757f4377c24afee73cac52437c125830c411
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
