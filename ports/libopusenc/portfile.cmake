if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/libopusenc
    REF v0.1
    SHA512 6abc5cd9e87ad41409f844d350cf43ee0067ad05a768aa9ef1d726a7e98ef9b006cbc42a6601d05a51dba6386a1361751a9a367a902c52eff8b4e56c3bf8a04b
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DOPUSENC_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# make includes work with MSBuild integration
file(READ ${CURRENT_PACKAGES_DIR}/include/opus/opusenc.h OPUSENC_H)
    string(REPLACE "#include <opus.h>" "#include \"opus.h\"" OPUSENC_H "${OPUSENC_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/opus/opusenc.h "${OPUSENC_H}")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libopusenc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libopusenc/COPYING ${CURRENT_PACKAGES_DIR}/share/libopusenc/copyright)
