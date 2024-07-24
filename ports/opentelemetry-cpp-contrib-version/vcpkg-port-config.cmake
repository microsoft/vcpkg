include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 93733bb2e52273474f4298d10645bf7d1157fc55
        HEAD_REF main
        SHA512 bfe297e313b8e960a4557dd8750c814af2f9b574dd248f8c30b452160f5b7aba53af85b2c5b87a423ea3878e8a852022e3ff3d08a983db073c68418e64f671b2
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
