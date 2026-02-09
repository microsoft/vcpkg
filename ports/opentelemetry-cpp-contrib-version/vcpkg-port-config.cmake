include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 36fd15952da761312b7d75d9a934e09584249257
        HEAD_REF main
        SHA512 4b60086d25c61efe9b5713a561ecc4a0d8fed8629dbbaee07578a6af5e785c1bd69edce230cf709c82dbd7a3e9740f3fe5831dbbd4326e3090af2832b210359c
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
