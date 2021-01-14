vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF jan2021b
    SHA512 6ed43dbe4ea33857ed96a2c05a4618ae935eb9bc0778118af6c791f794c2ad843fe1b52a2aa484914f8aaf3534a282ab80af95350eab2c340bb6b401dc9743b0
    HEAD_REF master
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

if(VCPKG_TARGET_IS_UWP)
  set(EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  set(EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))
  vcpkg_copy_tools(
        TOOL_NAMES uvatlastool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

elseif((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64))
  vcpkg_download_distfile(
    UVATLASTOOL_EXE
    URLS "https://github.com/Microsoft/UVAtlas/releases/download/jan2021/uvatlastool.exe"
    FILENAME "uvatlastool-jan2021.exe"
    SHA512 8727510f3ec41c2fa7ed75100b8c0f4daa41e93a1b812e5ec3c265dc87c3f48651da37a18af5d8b57a0aa096c42232b58a50a00c036ec7c04dcae4767a2691f9
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  file(INSTALL
    ${UVATLASTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/uvatlas/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-jan2021.exe ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
