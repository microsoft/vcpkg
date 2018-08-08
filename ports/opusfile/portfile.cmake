if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opusfile
    REF v0.9
    SHA512 8bada67cf12511fd914813fe782a5bf40a5d1ecadbe77e2e8d7bf40bf09bf0e6af3dfbc9b7987496dea813d3b120897cb9117f06521eeb098105e1a795ab702b
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
