if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/libopusenc
    REF 6b80503f263ebbc6479fb346c0e31dc4619b6f8c
    SHA512 bda6e4402e65a99a718984eebad9b0d4f598efedf5a3217322ce72188596893500f6288f513a5cdea132cd5796bb5d4583715f149996c968ab1edc004704f213
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
