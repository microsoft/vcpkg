set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

vcpkg_download_distfile(
    llvm_installer
    URLS "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/LLVM-${VERSION}-win64.exe"
    FILENAME "LLVM-${VERSION}-win64.exe"
    SHA512 97bd78cc710ad9f076673a816bf89766caee352474400bbcbcc564959b8620a46d01292121a054a92a0c889e21b6df994e0a0962b526e679f537b48f8822ae2b
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

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/" DESTINATION "${CURRENT_PACKAGES_DIR}/compiler-llvm")

configure_file("${CMAKE_CURRENT_LIST_DIR}/llvm-env.cmake" "${CURRENT_PACKAGES_DIR}/env-setup/llvm-env.cmake" @ONLY)
