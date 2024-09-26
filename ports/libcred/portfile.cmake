vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Shadowrom2020/libcred
    REF baca5ae1f19d644ccb3b994f0a6530290cbb2fb2 #v0.1.0
    SHA512 d63a51a790e3888f01efa9185e52f02ac0b49a14b15a75815b571216f1f7e825ae0e175dff41f0997595f7cbe6c6e76dc6ed357ddd58f58dc07531aba0404b05
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
)

vcpkg_install_cmake()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libcred" RENAME copyright)