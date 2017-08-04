if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opusfile
    REF v0.8
    SHA512 82fcb09c0b77bffb5877c660a268e0c166a1ac314b270799fe5cb4e0fa2cd10fd909b380761031f7dfb60d8b7561e5fe54d93b74d37bb0e6f629bdf9a6384ae1
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} 
    PREFER_NINJA 
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
