# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/iostreams
    REF boost-1.69.0
    SHA512 263d06f2533a345eb4fe3926742c6606b486d9f7d024a001f00b09592201ee987854036174b44c39c6d9a47b52262a96f9a8ebf2af215ef217fa11aa1209fe86
    HEAD_REF master
    PATCHES Removeseekpos.patch
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/boostorg/boost/boost-1.67.0/LICENSE_1_0.txt"
    FILENAME "boost_LICENSE_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-iostreams RENAME copyright)
