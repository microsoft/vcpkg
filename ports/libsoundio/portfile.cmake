
vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrewrk/libsoundio
    REF 2.0.0
    SHA512 347a9be1789a41e778ea8d0efa1d00e03e725a4ab65e3aaf6c71e49138643f08a50a81bd60087d86a3b4d63beaeec617e47ba6b81f829ece8a3ac17418eb5309
    HEAD_REF master
    PATCHES
        fix_cmakelists.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

if("alsa" IN_LIST FEATURES)
    set(ENABLE_ALSA ON)
else()
    set(ENABLE_ALSA OFF)
endif()

if("jack" IN_LIST FEATURES)
    set(ENABLE_JACK ON)
else()
    set(ENABLE_JACK OFF)
endif()

if("pulseaudio" IN_LIST FEATURES)
    set(ENABLE_PULSEAUDIO ON)
else()
    set(ENABLE_PULSEAUDIO OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_DYNAMIC_LIBS=${BUILD_DYNAMIC_LIBS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_EXAMPLE_PROGRAMS=OFF
        -DBUILD_TESTS=OFF
        -DENABLE_JACK=${ENABLE_JACK}
        -DENABLE_PULSEAUDIO=${ENABLE_PULSEAUDIO}
        -DENABLE_ALSA=${ENABLE_ALSA}
        -DENABLE_COREAUDIO=${VCPKG_TARGET_IS_OSX}
        -DENABLE_WASAPI=${VCPKG_TARGET_IS_WINDOWS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsoundio RENAME copyright)
