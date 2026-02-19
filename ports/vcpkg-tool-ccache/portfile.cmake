set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# This is a helper port that doesn't install binaries directly
# The actual tool acquisition happens in vcpkg-port-config.cmake

# Install default ccache.conf configuration file
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/ccache.conf" [[# CCCache configuration for vcpkg
# This file will be copied to CCACHE_DIR on first use

# Maximum cache size
max_size = 100.0G

# Enable compression to save disk space
compression = true
compression_level = 1

# Disable hash_dir when using base_dir for relative path matching
hash_dir = false

# Sloppiness settings for better cache hits with generated files
# - pch_defines: Ignore precompiled header defines
# - time_macros: Ignore __DATE__, __TIME__ macros
# - include_file_mtime: Ignore modification time of include files
# - include_file_ctime: Ignore inode change time (important for generated files)
# - system_headers: Ignore system header mtimes
sloppiness = pch_defines, time_macros, include_file_mtime, include_file_ctime, system_headers

# Enable statistics
stats = true

# Compiler check by modification time (faster than hash)
compiler_check = mtime
]])

# Install license placeholder (will be replaced when tool is acquired)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "CCCache - See https://github.com/ccache/ccache for license information (GPL-3.0-or-later)\n")

# Install vcpkg-port-config.cmake
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" 
               "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" 
               @ONLY)

