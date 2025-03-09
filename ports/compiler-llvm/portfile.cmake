set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

vcpkg_download_distfile(
    llvm_installer
    URLS "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/LLVM-${VERSION}-win64.exe"
    FILENAME "LLVM-${VERSION}-win64.exe"
    SHA512 d90ab2990d787b681b91ca11ae8ac118d28967105790945674c07a1cbd4d7fa608677c199f8538a54387866edde40814e031bd8c9551f6aa7c80620a3ee0515f
)

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

vcpkg_find_acquire_program(7Z)

vcpkg_execute_required_process(
    COMMAND "${7Z}" x "${llvm_installer}" "-o${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}" "-y" "-bso0" "-bsp0"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "extract-${PORT}-${TARGET_TRIPLET}"
)

file(REMOVE_RECURSE 
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/$PLUGINSDIR"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/Uninstall.exe"
)

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/" DESTINATION "${CURRENT_PACKAGES_DIR}/compiler/llvm")
vcpkg_apply_patches(
  SOURCE_PATH "${CURRENT_PACKAGES_DIR}/compiler/llvm"
  PATCHES remove-types.patch
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/llvm-env.cmake" "${CURRENT_PACKAGES_DIR}/env-setup/llvm-env.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/llvm-env.ps1" "${CURRENT_PACKAGES_DIR}/env-setup/llvm-env.ps1" @ONLY)
