if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxfont
    REF 3a4f68284c5aeea77789af1fe395cac35efc8562 # 2.0.5
    SHA512  d9731b50a55c3bceadb0abb4530a673940432467402829559229cfa946105270970db0b7663b72e64279b4b6f8a82b594549d8987205e581de19e55710fec15f
    HEAD_REF master
    PATCHES build.patch
            build2.patch
            configure.patch
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_CXX_FLAGS " /D_WILLWINSOCK_") # /showIncludes are not passed on so I cannot figure out which header is responsible for this
    string(APPEND VCPKG_C_FLAGS " /D_WILLWINSOCK_")
endif()
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS ${OPTIONS}
      --with-bzip2=yes
    OPTIONS_DEBUG ${DEPS_DEBUG}
    OPTIONS_RELEASE ${DEPS_RELEASE}
)

vcpkg_install_make()
if(VCPKG_TARGET_IS_WINDOWS)
    set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xfont2.pc")
    file(READ "${_file}" _contents)
    string(REPLACE "-lm" "" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xfont2.pc")
    file(READ "${_file}" _contents)
    string(REPLACE "-lm" "" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
