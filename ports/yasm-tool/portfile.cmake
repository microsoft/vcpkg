vcpkg_fail_port_install(MESSAGE "The yasm-tool port currently only supports Windows" ON_TARGET "Linux" "OSX")
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_LIBRARY_LINKAGE dynamic)

if(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(yasm_DO_BUILD OFF)
elseif(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_IS_MINGW AND NOT (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP))
    set(yasm_DO_BUILD OFF)
else()
    set(yasm_DO_BUILD ON)
endif()

if(NOT yasm_DO_BUILD AND NOT EXISTS "${CURRENT_INSTALLED_DIR}/../x86-windows/tools/yasm-tool")
    message(FATAL_ERROR "Cross-targetting and x64 ports requiring yasm (e.g. gmp, nettle) require the x86-windows yasm-tool to be available. Please install yasm-tool:x86-windows first.")
endif()

set(EXECUTABLES yasm.exe yasm.dll yasmstd.dll)
set(LICENSES Artistic.txt BSD.txt GNU_GPL-2.0 GNU_LGPL-2.0)

if (yasm_DO_BUILD)
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

    set(EXECUTABLES_ROOT "${CURRENT_PACKAGES_DIR}/bin")
    set(LICENSES_ROOT "${SOURCE_PATH}")

    file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
else()
    set(EXECUTABLES_ROOT "${CURRENT_INSTALLED_DIR}/../x86-windows/tools/${PORT}")
    set(LICENSES_ROOT "${CURRENT_INSTALLED_DIR}/../x86-windows/share/${PORT}")
    file(INSTALL "${LICENSES_ROOT}/copyright" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

foreach(EXECUTABLE IN LISTS EXECUTABLES)
    file(COPY "${EXECUTABLES_ROOT}/${EXECUTABLE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endforeach()

foreach(LICENSE IN LISTS LICENSES)
    file(COPY "${LICENSES_ROOT}/${LICENSE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endforeach()

if (yasm_DO_BUILD)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
endif()
