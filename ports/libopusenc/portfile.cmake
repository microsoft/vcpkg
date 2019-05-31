if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/libopusenc
    REF b19e1b14dee3e5245f2e37bfb193bde72fa70a2d
    SHA512 50e7df3b2937b99e51b9d24d9b6e44a63b38945bf7f45cef8199c30c3ed18dfcf06bd306cdffdb16c367da49465f93261e0396c1c4298ad4f9cc9f1737221a06
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
