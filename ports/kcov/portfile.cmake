vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SimonKagstrom/kcov
    REF "v${VERSION}"
    SHA512 d28535cf5565c9b4205a2c1f28c703b45488e619d13582f75a97219a27b39339fd5ff3803fdf61e0520c39788226d1e20dafc10282465cc130aa21467d1f6c20
    HEAD_REF master
)

# Apply patch to disable ASLR
file(READ ${SOURCE_PATH}/src/engines/ptrace.cc PTRACE_CC_CONTENT)
string(REPLACE "ptrace_sys::disable_aslr()" "true" PTRACE_CC_CONTENT "${PTRACE_CC_CONTENT}")
file(WRITE ${SOURCE_PATH}/src/engines/ptrace.cc "${PTRACE_CC_CONTENT}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${SOURCE_PATH}/build)