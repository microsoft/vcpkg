pkg_fail_port_install(ON_TARGET "linux" "osx" "uwp" "ios" "android" "freebsd")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GameTechDev/PresentMon
    REF 6ddc9e15d2ef169cdce954b589c1ba190b3a25bd # 1.6.0
    SHA512 2522b0e3218d4a6588531a09bc82631f14ad05c20f4560fe0574f00f2f5eece114ae04320f920eb52ba64173cea5cdf15bb223b7395c3782e4a6465afb5d9bec
    HEAD_REF main
)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
# A bit silly - this is not honored, but we make it dynamic so that vcpkg_install_msbuild does not disable whole program optimization (which it does if static)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(PLATFORM ${VCPKG_TARGET_ARCHITECTURE})
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM x86)
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH PresentMon.sln
    PLATFORM ${PLATFORM}
)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(GLOB PRESENTMON_EXE ${CURRENT_PACKAGES_DIR}/tools/${PORT}/PresentMon-*.exe)
file(GLOB PRESENTMONTESTS_EXE ${CURRENT_PACKAGES_DIR}/tools/${PORT}/PresentMonTests-*.exe)
file(RENAME ${PRESENTMON_EXE} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/PresentMon.exe)
file(REMOVE ${PRESENTMONTESTS_EXE})
