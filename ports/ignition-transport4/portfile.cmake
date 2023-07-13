ignition_modular_library(NAME transport
                         VERSION "4.0.0"
                         SHA512 581dd4700aebc455f6d7c01d8be17c6c4c802fd74b1504b2bd6544a0246b161231305fd318352904e230c986dfe072fa0608fccea9066b076e7216dc507a8510
                         # This can  be removed when the pc file of libuuid on Windows is fixed
                         DISABLE_PKGCONFIG_INSTALL
                         PATCHES
                            uuid-osx.patch
                         )
