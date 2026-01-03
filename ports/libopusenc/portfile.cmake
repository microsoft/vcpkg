if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/libopusenc
    REF  v${VERSION}
    SHA512 4fd2fd7d0516bcf71511d09de8ec2f59fc150575308edc13adb0b7b05e95d63e92c03c05efba502bc5152ea5b198f394e8811edc4c1675c0429f6a00deae3f7b
    HEAD_REF master)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DOPUSENC_SKIP_HEADERS=ON)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# make includes work with MSBuild integration
file(READ "${CURRENT_PACKAGES_DIR}/include/opus/opusenc.h" OPUSENC_H)
    string(REPLACE "#include <opus.h>" "#include \"opus.h\"" OPUSENC_H "${OPUSENC_H}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/opus/opusenc.h" "${OPUSENC_H}")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
