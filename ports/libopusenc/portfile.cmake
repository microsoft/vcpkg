if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/libopusenc
    REF  v0.2.1
    SHA512 9681421a967b93770796dd3503c00e1418de86438d2bfe77011dc68f6db5d666508d33c0df7308db3b7ea18f5e1b14a3115fd63837987e16347ec801c3771d26
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
