set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_BUILD_TYPE release) # Debug build failing isctype.cpp assertion (c >= -1 && c <= 255) while running geocoding_data.exe program
