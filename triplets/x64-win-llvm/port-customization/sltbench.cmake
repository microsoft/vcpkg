set(ENV{CMAKE_WINDOWS_KITS_10_DIR} "$ENV{WindowsSdkDir}")
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_POLICY_DEFAULT_CMP0149=NEW")
