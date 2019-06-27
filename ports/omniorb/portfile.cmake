# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaeruleusAqua/omniORB-cmake
    HEAD_REF vcpkg-fixes
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DPython_ROOT_DIR=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/tools/python3
    OPTIONS -DPython_EXECUTABLE=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/tools/python3/python.exe
    OPTIONS_RELEASE -DPython_LIBRARIES=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/python37.lib
    OPTIONS_DEBUG -DPython_LIBRARIES=${VCPKG_ROOT_DIR}/installed//${TARGET_TRIPLET}/debug/lib/python37_d.lib
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/omniorb RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# move executables to tools

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniNames.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniMapper.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniidl.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omnicpp.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniORB4.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omnithread.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)


file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omniNames.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omniMapper.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omniidl.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omnicpp.exe)


file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omniNames.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omniMapper.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omniidl.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omnicpp.exe)


vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/OmniORB" TARGET_PATH "lib/cmake/OmniORB")

file(GLOB CMAKE_FILES ${CURRENT_PACKAGES_DIR}/lib/cmake/OmniORB/*.cmake)
    foreach(CMAKE_FILE IN LISTS CMAKE_FILES)
        file(COPY ${CMAKE_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/OmniORB/)
endforeach()

file(COPY ${CURRENT_PACKAGES_DIR}/Lib/site-packages/ DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})


file(READ ${CURRENT_PACKAGES_DIR}/share/OmniORB/OmniORBConfig.cmake _contents)
    string(REPLACE
        "set_and_check(OMNI_PYTHON_RESOURCES"
        "#set_and_check(OMNI_PYTHON_RESOURCES"
        _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/OmniORB/OmniORBConfig.cmake "${_contents}")


vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/Lib/site-packages/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/Lib/site-packages/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl_be/__pycache__)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl_be/cxx/__pycache__)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl_be/cxx/skel/__pycache__)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl_be/cxx/impl/__pycache__)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl_be/cxx/header/__pycache__)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl_be/cxx/dynskel/__pycache__)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/omniorb/omniidl/__pycache__)



