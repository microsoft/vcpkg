vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/yojimbo
    REF "v${VERSION}"
    SHA512 437fcd8b4fcd8369eb1a3e153361720bab2cdd99882d6400a7066d6f32185d2d9f480e37c370a749be4fac37c6b357af79b18815919860d2987112857d302165
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYOJIMBO_SYSTEM_DEPS=ON
        -DYOJIMBO_BUILD_TESTS=OFF
        -DYOJIMBO_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# tlsf (tlsf/tlsf.h, tlsf/tlsf.c) is compiled into libyojimbo and carries its own
# BSD-style license by Matthew Conte; bundle it alongside yojimbo's own LICENCE.
file(WRITE "${CURRENT_BUILDTREES_DIR}/tlsf-copyright" [[Two Level Segregated Fit memory allocator, version 3.1.
Written by Matthew Conte
	http://tlsf.baisoku.org

Based on the original documentation by Miguel Masmano:
	http://www.gii.upv.es/tlsf/main/docs

This implementation was written to the specification
of the document, therefore no GPL restrictions apply.

Copyright (c) 2006-2016, Matthew Conte
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL MATTHEW CONTE BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]])

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENCE"
    "${CURRENT_BUILDTREES_DIR}/tlsf-copyright"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
