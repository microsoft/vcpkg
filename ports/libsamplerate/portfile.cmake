vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsndfile/libsamplerate
    REF f6730d03c3e7660bb6ecad8816f1b09c5825142a # v0.1.9
    SHA512 6a349c9144d024212fc78dc0d9e39bdc1a43abaf590fcfbf84396af22834545962d5ef10176b48b21fcae2ce62d12277b682059383805d059f4dd2b9f6708478
    HEAD_REF master
    PATCHES Use-the-lrintf-intrinsic.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/src)
file(COPY ${SOURCE_PATH}/Win32/config.h DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsamplerate RENAME copyright)

vcpkg_copy_pdbs()
