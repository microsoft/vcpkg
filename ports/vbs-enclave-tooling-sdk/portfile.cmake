vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/VbsEnclaveTooling
    REF "sdk-v${VERSION}"
    SHA512 "c0ce7d15f5fd4e1a273d61cc1d254304a64a5f633eefc3d32effb5f5b99e2b9488c3cda7e080d02bf5cbfd8c47e7302132b6ed93184fd622fd303ee247c96411"
    HEAD_REF main
)

set(VBS_ENCLAVE_SDK_SOURCE_PATH "${SOURCE_PATH}/src/VbsEnclaveSDK")

# All the projects in the repo require some nuget packages to be installed so we need
# to run nuget restore prior to running the msbuild function.
vcpkg_find_acquire_program(NUGET)
vcpkg_execute_required_process(
    COMMAND ${NUGET} restore "${VBS_ENCLAVE_SDK_SOURCE_PATH}/vbs_enclave_implementation_library.sln"
    WORKING_DIRECTORY "${VBS_ENCLAVE_SDK_SOURCE_PATH}"
    LOGNAME nuget-restore
)

vcpkg_msbuild_install(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH "/src/VbsEnclaveSDK/vbs_enclave_implementation_library.sln"
  NO_INSTALL # Make sure libs, exes and dlls from consumed nuget packages don't get added
  NO_TOOLCHAIN_PROPS
)

function(install_headers SRC_DIR DST_SUBDIR)
    file(GLOB_RECURSE HEADERS "${SRC_DIR}/*.h")
    foreach(header IN LISTS HEADERS)
        if(NOT header MATCHES ".*/Generated Files/.*")
            file(INSTALL DESTINATION "${CURRENT_PACKAGES_DIR}/include/${DST_SUBDIR}" TYPE FILE FILES "${header}")
        endif()
    endforeach()
endfunction()

install_headers("${VBS_ENCLAVE_SDK_SOURCE_PATH}/src/veil_enclave_lib" "veil/enclave")
install_headers("${VBS_ENCLAVE_SDK_SOURCE_PATH}/src/veil_host_lib" "veil/host")
install_headers("${VBS_ENCLAVE_SDK_SOURCE_PATH}/src/veil_any_inc" "veil/veil_any_inc")
install_headers("${SOURCE_PATH}/Common/veil_enclave_wil_inc/wil" "wil/enclave")

foreach(CFG IN ITEMS Release Debug)
    if(CFG STREQUAL "Release")
        set(CFG_SUFFIX "rel")
        set(PACKAGE_LIB_DIR "${CURRENT_PACKAGES_DIR}/lib")
        set(CPP_SUPPORT_DIR "${CURRENT_PACKAGES_DIR}/lib/manual-link/vbs-enclave-tooling-sdk")
    else()
        set(CFG_SUFFIX "dbg")
        set(PACKAGE_LIB_DIR "${CURRENT_PACKAGES_DIR}/debug/lib")
        set(CPP_SUPPORT_DIR "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/vbs-enclave-tooling-sdk")
    endif()

    set(BASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${CFG_SUFFIX}/src/VbsEnclaveSDK")
    set(BUILD_DIR "${BASE_DIR}/_build/${VCPKG_TARGET_ARCHITECTURE}/${CFG}")

    if(EXISTS "${BUILD_DIR}")
        set(LIB_SUFFIX "${CFG}_lib.lib")

        file(INSTALL DESTINATION "${PACKAGE_LIB_DIR}" TYPE FILE FILES
            "${BUILD_DIR}/veil_enclave_${VCPKG_TARGET_ARCHITECTURE}_${LIB_SUFFIX}"
            "${BUILD_DIR}/veil_host_lib/veil_host_${VCPKG_TARGET_ARCHITECTURE}_${LIB_SUFFIX}"
        )

        file(INSTALL DESTINATION "${CURRENT_PACKAGES_DIR}/src/veil" TYPE FILE FILES
            "${BASE_DIR}/src/veil_enclave_lib/Generated Files/VbsEnclave/Enclave/Abi/LinkerPragmas.veil_abi.cpp"
        )

        file(GLOB CPP_SUPPORT_LIB_FILE
            "${BUILD_DIR}/veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_${LIB_SUFFIX}"
        )
        file(MAKE_DIRECTORY "${CPP_SUPPORT_DIR}")
        file(INSTALL DESTINATION "${CPP_SUPPORT_DIR}" TYPE FILE FILES "${CPP_SUPPORT_LIB_FILE}")
    endif()
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")