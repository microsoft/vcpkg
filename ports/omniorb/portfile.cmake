include(vcpkg_common_functions)
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaeruleusAqua/omniORB-cmake
    REF 7bd95e32d16c72eb24521aee071895e8d7cffd91
    HEAD_REF master
    SHA512 9fa56364696f91e2bf4287954d26f0c35b3f8aad241df3fbd3c9fc617235d8c83b28ddcac88436383b2eb273f690322e6f349e2f9c64d02f0058a4b76fa55035
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DPython_RUNTIME_LIBRARY_DIRS=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/bin/
    OPTIONS -DPython_LIBRARY_DEBUG=${VCPKG_ROOT_DIR}/installed//${TARGET_TRIPLET}/debug/lib/python37_d.lib
    OPTIONS -DPYTHON_SITE=Lib/site-packages
)

vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/bin)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/omniorb RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniNames.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniMapper.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omniidl.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/omnicpp.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omniNames.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omniMapper.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omniidl.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/omnicpp.exe)

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omniNames.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omniMapper.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omniidl.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/omnicpp.exe)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/OmniORB" TARGET_PATH "share/omniorb")

file(COPY ${CURRENT_PACKAGES_DIR}/Lib/site-packages/ DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})


file(READ ${CURRENT_PACKAGES_DIR}/share/omniorb/OmniORBConfig.cmake _contents)
    string(REPLACE
        "set_and_check(OMNI_PYTHON_RESOURCES"
        "#set_and_check(OMNI_PYTHON_RESOURCES"
        _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/omniorb/OmniORBConfig.cmake "${_contents}")


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



