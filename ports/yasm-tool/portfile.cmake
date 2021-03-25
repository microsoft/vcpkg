vcpkg_fail_port_install(MESSAGE "The yasm-tool port is only intended to be built for x86 Windows" ON_TARGET "Linux" "OSX" ON_ARCH "x64" "arm")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yasm/yasm
    REF 009450c7ad4d425fa5a10ac4bd6efbd25248d823 # 7.0.3 plus bugfixes for https://github.com/yasm/yasm/issues/153
    SHA512 a542577558676d11b52981925ea6219bffe699faa1682c033b33b7534f5a0dfe9f29c56b32076b68c48f65e0aef7c451be3a3af804c52caa4d4357de4caad83c
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_NLS=OFF
        -DYASM_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES yasm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
foreach(LICENSE Artistic.txt BSD.txt GNU_GPL-2.0 GNU_LGPL-2.0)
    file(COPY "${SOURCE_PATH}/${LICENSE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endforeach()
