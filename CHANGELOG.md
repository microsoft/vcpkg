vcpkg (2020.04.20 - 2020.06.15)
---
#### Total port count: 1402
#### Total port count per triplet (tested): 
|triplet|ports available|
|---|---|
|**x64-windows**|1282|
|**x64-osx**|1109|
|**x64-linux**|1181|
|x64-windows-static|1187|
|x86-windows|1261|
|x64-uwp|693|
|arm64-windows|903|
|arm-uwp|656|

#### The following documentation has been updated:
- [Testing](docs/tool-maintainers/testing.md)
    - [(#11007)](https://github.com/microsoft/vcpkg/pull/11007) [vcpkg] Fix Catch2 include path in documentation (by @horenmar)
- [Maintainer Guidelines and Policies](docs/maintainers/maintainer-guide.md)
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools (by @myd7349)
- [Portfile helper functions](docs/maintainers/portfile-functions.md)
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools (by @myd7349)
    - [(#10505)](https://github.com/microsoft/vcpkg/pull/10505) [gn, crashpad] Add GN build support and crashpad port (by @myd7349)
- [vcpkg_clean_executables_in_bin](docs/maintainers/vcpkg_clean_executables_in_bin.md)***[NEW]***
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools (by @myd7349)
- [vcpkg_copy_tools](docs/maintainers/vcpkg_copy_tools.md)***[NEW]***
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools (by @myd7349)
- [vcpkg_build_gn](docs/maintainers/vcpkg_build_gn.md)***[NEW]***
    - [(#10505)](https://github.com/microsoft/vcpkg/pull/10505) [gn, crashpad] Add GN build support and crashpad port (by @vejmartin)
- [vcpkg_build_ninja](docs/maintainers/vcpkg_build_ninja.md)***[NEW]***
    - [(#10505)](https://github.com/microsoft/vcpkg/pull/10505) [gn, crashpad] Add GN build support and crashpad port (by @vejmartin)
- [vcpkg_configure_gn](docs/maintainers/vcpkg_configure_gn.md)***[NEW]***
    - [(#10505)](https://github.com/microsoft/vcpkg/pull/10505) [gn, crashpad] Add GN build support and crashpad port (by @vejmartin)
- [vcpkg_find_acquire_program](docs/maintainers/vcpkg_find_acquire_program.md)
    - [(#10505)](https://github.com/microsoft/vcpkg/pull/10505) [gn, crashpad] Add GN build support and crashpad port (by @vejmartin)
- [vcpkg_install_gn](docs/maintainers/vcpkg_install_gn.md)***[NEW]***
    - [(#10505)](https://github.com/microsoft/vcpkg/pull/10505) [gn, crashpad] Add GN build support and crashpad port (by @vejmartin)
- [vcpkg and Android](docs/examples/vcpkg_android_example_cmake_script/cmake/vcpkg_android.cmake)***[NEW]***
    - [(#11264)](https://github.com/microsoft/vcpkg/pull/11264) Improve Android doc (triplets, usage with cmake and prefab) (by @pthom)
- [vcpkg telemetry and privacy](docs/about/privacy.md)
    - [(#11542)](https://github.com/microsoft/vcpkg/pull/11542) [vcpkg metrics] Allow someone to opt out after build (by @strega-nil)
- [Manifests](docs/specifications/manifests.md)***[NEW]***
    - [(#11203)](https://github.com/microsoft/vcpkg/pull/11203) [vcpkg] RFC: Manifests (by @strega-nil)
- [CONTROL files](docs/maintainers/control-files.md)
    - [(#11323)](https://github.com/microsoft/vcpkg/pull/11323) [vcpkg] add x86-wasm.cmake to community triplets (by @MoAlyousef)
    - [(#11365)](https://github.com/microsoft/vcpkg/pull/11365) [vcpkg] [cudnn] [msmpi] [openmpi] Update VMSS (by @MoAlyousef)
- [Installing and Using Packagese Example: SQLite](docs/examples/installing-and-using-packages.md)
    - [(#11763)](https://github.com/microsoft/vcpkg/pull/11763) docs: fix CMakeLists example for SQLite3 (by @disposedtrolley)

#### The following changes have been made to the vcpkg tool and infrastructure:
- [(#10828)](https://github.com/microsoft/vcpkg/pull/10828) Onboard Windows PR tests to Azure Pipelines YAML and Scale Sets (by @BillyONeal)
- [(#10932)](https://github.com/microsoft/vcpkg/pull/10932) [vcpkg] Update git to 2.26.2 (by @Cheney-W)
- [(#10973)](https://github.com/microsoft/vcpkg/pull/10973) [vcpkg] Fix toolsrc CMake build error (by @NancyLi1013)
- [(#11009)](https://github.com/microsoft/vcpkg/pull/11009) Fix slack link to current, correct, location. (by @grafikrobot)
- [(#9861)](https://github.com/microsoft/vcpkg/pull/9861) [scripts] add new function vcpkg_fixup_pkgconfig (by @Neumann-A)
- [(#11064)](https://github.com/microsoft/vcpkg/pull/11064) [vcpkg] Copy macos pipelines into azure-pipelines.yml (by @BillyONeal)
- [(#10476)](https://github.com/microsoft/vcpkg/pull/10476) [vcpkg] Add support for VCPKG_BINARY_SOURCES and --x-binarysource=<> (by @ras0219-msft)
- [(#11068)](https://github.com/microsoft/vcpkg/pull/11068) [vcpkg] Small touchups for vcpkg unit tests (by @horenmar)
- [(#11085)](https://github.com/microsoft/vcpkg/pull/11085) [vcpkg] Correctly record default feature list in BinaryParagraphs. Fixes #10678. (by @ras0219-msft)
- [(#11090)](https://github.com/microsoft/vcpkg/pull/11090) [vcpkg] Bump macos build timeouts to 1 day (by @BillyONeal)
- [(#11091)](https://github.com/microsoft/vcpkg/pull/11091) [vcpkg baseline] Ignore mlpack on macOS (by @strega-nil)
- [(#11083)](https://github.com/microsoft/vcpkg/pull/11083) [vcpkg] Warn on unmatched removal with reasonable alternative (by @ras0219-msft)
- [(#11102)](https://github.com/microsoft/vcpkg/pull/11102) [vcpkg] fix undefined working dir in vcpkg_acquire_msys (by @Neumann-A)
- [(#11058)](https://github.com/microsoft/vcpkg/pull/11058) [msbuild]fix use UseEnv-True (by @Voskrese)
- [(#10980)](https://github.com/microsoft/vcpkg/pull/10980) [vcpkg] Onboard Linux to VMSS, open 'git' port, and switch back to Azure Spot (by @BillyONeal)
- [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools (by @myd7349)
- [(#11166)](https://github.com/microsoft/vcpkg/pull/11166) [vcpkg] Add disk space report on Linux. (by @BillyONeal)
- [(#11170)](https://github.com/microsoft/vcpkg/pull/11170) [vcpkg] fix bug in Filesystem::absolute (by @strega-nil)
- [(#11175)](https://github.com/microsoft/vcpkg/pull/11175) [vcpkg] Point README.md to the correct status badge. (by @BillyONeal)
- [(#11171)](https://github.com/microsoft/vcpkg/pull/11171) [vcpkg] Add telemetry notice to `README.md`. (by @BillyONeal)
- [(#11189)](https://github.com/microsoft/vcpkg/pull/11189) [vcpkg] Add tombstone deletion scripts. (by @BillyONeal)
- [(#11105)](https://github.com/microsoft/vcpkg/pull/11105) [vcpkg/scripts] Fix ninja search path on windows and find binaries within vcpkg first (by @Neumann-A)
- [(#11202)](https://github.com/microsoft/vcpkg/pull/11202) [vcpkg] always pass VSCMD_SKIP_SENDTELEMETRY=1 (by @strega-nil)
- [(#8588)](https://github.com/microsoft/vcpkg/pull/8588) [vcpkg] Add x86 support for Linux toolchain (by @zhbanito)
- [(#11213)](https://github.com/microsoft/vcpkg/pull/11213) [vcpkg] Restrict telemetry uploads to TLS 1.2 (by @BillyONeal)
- [(#11234)](https://github.com/microsoft/vcpkg/pull/11234) [vcpkg] Don't build the metrics uploader when metrics are disabled. (by @BillyONeal)
- [(#11233)](https://github.com/microsoft/vcpkg/pull/11233) [vcpkg] Resolve relative overlay ports to the current working directory. (by @ras0219-msft)
- [(#10760)](https://github.com/microsoft/vcpkg/pull/10760) [vcpkg] Adding support for finding VS2019 by environment variable (by @Honeybunch)
- [(#11174)](https://github.com/microsoft/vcpkg/pull/11174) [vcpkg] [llvm] Bump Linux VM memory size and do all operations on the temporary disk. (by @BillyONeal)
- [(#11266)](https://github.com/microsoft/vcpkg/pull/11266) [vcpkg][android] Link C++ runtime according to VCPKG_CRT_LINKAGE (by @huangqinjin)
- [(#11260)](https://github.com/microsoft/vcpkg/pull/11260) [vcpkg] Update pull request template (by @PhoebeHui)
- [(#11302)](https://github.com/microsoft/vcpkg/pull/11302) [vcpkg] Resolve --overlay-ports is only working for relative parths since fix… (by @TobiasFunk)
- [(#11205)](https://github.com/microsoft/vcpkg/pull/11205) [vcpkg] Hopefully fix build on macOS 10.13/10.14 (by @strega-nil)
- [(#11093)](https://github.com/microsoft/vcpkg/pull/11093) [vcpkg] Fix nuget package import failed. (by @shihaonan369)
- [(#11239)](https://github.com/microsoft/vcpkg/pull/11239) [vcpkg] Turn on tests in CI. (by @BillyONeal)
- [(#11339)](https://github.com/microsoft/vcpkg/pull/11339) [vcpkg] Avoid naming Policheck sensitive term 'Virgin Islands' (by @BillyONeal)
- [(#11368)](https://github.com/microsoft/vcpkg/pull/11368) [vcpkg] Do not build the metrics uploader with MSBuild when metrics are disabled (by @rickertm)
- [(#11315)](https://github.com/microsoft/vcpkg/pull/11315) [vcpkg] Harden expand environment strings path with explicit integer overflow checks and resistance to CP_ACP. (by @BillyONeal)
- [(#11450)](https://github.com/microsoft/vcpkg/pull/11450) [vcpkg CI] Clean git directory before clone (by @strega-nil)
- [(#11432)](https://github.com/microsoft/vcpkg/pull/11432) [vcpkg] Harden file removals and clean directory contents in "CI" inside vcpkg itself. (by @BillyONeal)
- [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2 (by @JackBoosY)
- [(#11433)](https://github.com/microsoft/vcpkg/pull/11433) [vcpkg] Optimize string split slightly. (by @BillyONeal)
- [(#11299)](https://github.com/microsoft/vcpkg/pull/11299) [vcpkg] pass -disableMetrics to bootstrap on git bash (by @strega-nil)
- [(#11453)](https://github.com/microsoft/vcpkg/pull/11453) Fix CMake PATH that fails Windows tests. (by @BillyONeal)
- [(#11343)](https://github.com/microsoft/vcpkg/pull/11343) [vcpkg] fix extern C around ctermid (by @strega-nil)
- [(#11380)](https://github.com/microsoft/vcpkg/pull/11380) [tool-meson] Update to 0.54.2 (by @c72578)
- [(#11057)](https://github.com/microsoft/vcpkg/pull/11057) [Vcpkg] Fix macOS applocal.py dependency bundling error (by @kevinhartman)
- [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds (by @Neumann-A)
- [(#11431)](https://github.com/microsoft/vcpkg/pull/11431) [vcpkg] Add static triplet for arm64-windows (by @orudge)
- [(#11466)](https://github.com/microsoft/vcpkg/pull/11466) [vcpkg] Fix cmake architecture detection on windows with ninja generator (by @Chronial)
- [(#11512)](https://github.com/microsoft/vcpkg/pull/11512) [vcpkg] Remove powershell from the 'run vcpkg ci' path to reduce hangs from msys components. (by @BillyONeal)
- [(#11443)](https://github.com/microsoft/vcpkg/pull/11443) [vcpkg-acquire-msys] Update pacman before any other package. (by @emptyVoid)
- [(#11496)](https://github.com/microsoft/vcpkg/pull/11496) [Baseline] Fix boost-*:arm-uwp failure and resolve conflicts in CI (by @PhoebeHui)
- [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports (by @JackBoosY)
- [(#11545)](https://github.com/microsoft/vcpkg/pull/11545) [vcpkg] Move CI cleaning back out of the 'ci' command into a separate command to restore cross-compilation preinstalls. (by @BillyONeal)
- [(#11612)](https://github.com/microsoft/vcpkg/pull/11612) [vcpkg baseline] Fix baseline failures (by @PhoebeHui)
- [(#11542)](https://github.com/microsoft/vcpkg/pull/11542) [vcpkg metrics] Allow someone to opt out after build (by @strega-nil)
- [(#11653)](https://github.com/microsoft/vcpkg/pull/11653) [vcpkg] Rename the msbuild property VcpkgRoot (by @BillyONeal)
- [(#11629)](https://github.com/microsoft/vcpkg/pull/11629) [vcpkg] Use a crypto RNG to generate admin passwords (by @BillyONeal)
- [(#11697)](https://github.com/microsoft/vcpkg/pull/11697) [vcpkg baseline] fix libb2:x64-osx (by @strega-nil)
- [(#11668)](https://github.com/microsoft/vcpkg/pull/11668) [CI|python3] add setuptools (by @Neumann-A)
- [(#11613)](https://github.com/microsoft/vcpkg/pull/11613) [vcpkg-baseline][unixodbc/nanodbc] Fix unixodbc build failure and set it as a dependency on nanodbc (by @JackBoosY)
- [(#11692)](https://github.com/microsoft/vcpkg/pull/11692) [vcpkg baseline] Remove passing port from Ci baseline (by @PhoebeHui)
- [(#11323)](https://github.com/microsoft/vcpkg/pull/11323) [vcpkg] add x86-wasm.cmake to community triplets (by @MoAlyousef)
- [(#11647)](https://github.com/microsoft/vcpkg/pull/11647) [vcpkg baseline][libfabric] Only support dynamic build (by @JackBoosY)
- [(#11483)](https://github.com/microsoft/vcpkg/pull/11483) [vcpkg] Allow CI to pass in all relevant directories and remove use of symbolic links (by @BillyONeal)
- [(#11764)](https://github.com/microsoft/vcpkg/pull/11764) [vcpkg] Add directories to x-ci-clean lost in merge conflict resolution. (by @BillyONeal)
- [(#11742)](https://github.com/microsoft/vcpkg/pull/11742) [vcpkg-baseline][manyport] Fix baseline error (by @JackBoosY)
- [(#11779)](https://github.com/microsoft/vcpkg/pull/11779) [vcpkg] Provide $(VcpkgRoot) and $(VcpkgCurrentInstalledDir) for customers. (by @BillyONeal)
- [(#11750)](https://github.com/microsoft/vcpkg/pull/11750) [vcpkg README] Add #include<C++> channel (by @strega-nil)
- [(#11693)](https://github.com/microsoft/vcpkg/pull/11693) [CI|gfortran] Install gfortran for OSX and Linux CI (by @Neumann-A)
- [(#11839)](https://github.com/microsoft/vcpkg/pull/11839) [vcpkg] Fix OSX CI by ensuring the downloads directory exists (by @BillyONeal
- [(#11810)](https://github.com/microsoft/vcpkg/pull/11810) [vcpkg-acquire-msys] Improvement (by @emptyVoid)
- [(#11365)](https://github.com/microsoft/vcpkg/pull/11365) [vcpkg] [cudnn] [msmpi] [openmpi] Update VMSS (by @BillyONeal)
- [(#11146)](https://github.com/microsoft/vcpkg/pull/11146) [vcpkg] Add nologo to windows toolchain  (by @Neumann-A)
- [(#11891)](https://github.com/microsoft/vcpkg/pull/11891) [vcpkg] Fix bootstrap on VS2015 (by @BillyONeal)
- [(#11858)](https://github.com/microsoft/vcpkg/pull/11858) [vcpkg] Merge unit test pass into x86-windows. (by @BillyONeal)
- [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error (by @JackBoosY)
- [(#4361)](https://github.com/microsoft/vcpkg/pull/4361) Adds vcpkg item to project settings in Visual Studio (by @Neumann-A)
- [(#11958)](https://github.com/microsoft/vcpkg/pull/11958) Delete g_binary_caching global that should be passed as a parameter. (by @BillyONeal)

<details>
<summary><b>The following 79 ports have been added:</b></summary>

|port|version|
|---|---|
|[ryml](https://github.com/microsoft/vcpkg/pull/10793)| 2020-04-12
|[qt5-androidextras](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-canvas3d](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-doc](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-serialbus](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-translations](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-wayland](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-webengine](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) [#11120](https://github.com/microsoft/vcpkg/pull/11120) [#11653](https://github.com/microsoft/vcpkg/pull/11653) </sup>| 5.12.8
|[qt5-webglplugin](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[qt5-x11extras](https://github.com/microsoft/vcpkg/pull/10644)<sup>[#11026](https://github.com/microsoft/vcpkg/pull/11026) </sup>| 5.12.8
|[iniparser](https://github.com/microsoft/vcpkg/pull/10710)| 2020-04-06
|[quill](https://github.com/microsoft/vcpkg/pull/10902)<sup>[#11326](https://github.com/microsoft/vcpkg/pull/11326) </sup>| 1.3.1
|[frozen](https://github.com/microsoft/vcpkg/pull/10766)| 1.0.0
|[cppcoro](https://github.com/microsoft/vcpkg/pull/10693)| 2020-2-28-1
|[libtomcrypt](https://github.com/microsoft/vcpkg/pull/10960)| 1.18.2-1
|[libtommath](https://github.com/microsoft/vcpkg/pull/10960)| 1.2.0-1
|[pe-parse](https://github.com/microsoft/vcpkg/pull/11012)| 1.2.0
|[opencc](https://github.com/microsoft/vcpkg/pull/8474)<sup>[#10767](https://github.com/microsoft/vcpkg/pull/10767) [#11559](https://github.com/microsoft/vcpkg/pull/11559) [#11612](https://github.com/microsoft/vcpkg/pull/11612) </sup>| 2020-04-26-4
|[uchardet](https://github.com/microsoft/vcpkg/pull/8477)| 2020-04-26
|[libqcow](https://github.com/microsoft/vcpkg/pull/11036)<sup>[#11238](https://github.com/microsoft/vcpkg/pull/11238) </sup>| 20191221-1
|[mstch](https://github.com/microsoft/vcpkg/pull/11020)| 1.0.2-2
|[nowide](https://github.com/microsoft/vcpkg/pull/11066)<sup>[#11732](https://github.com/microsoft/vcpkg/pull/11732) [#11859](https://github.com/microsoft/vcpkg/pull/11859) </sup>| alias
|[discord-game-sdk](https://github.com/microsoft/vcpkg/pull/10763)<sup>[#11728](https://github.com/microsoft/vcpkg/pull/11728) </sup>| 2.5.6-1
|[libmpeg2](https://github.com/microsoft/vcpkg/pull/8871)| 0.5.1
|[opencv2](https://github.com/microsoft/vcpkg/pull/7849)<sup>[#11201](https://github.com/microsoft/vcpkg/pull/11201) </sup>| 2.4.13.7-1
|[rtlsdr](https://github.com/microsoft/vcpkg/pull/10901)<sup>[#11575](https://github.com/microsoft/vcpkg/pull/11575) </sup>| 2020-04-16-1
|[gasol](https://github.com/microsoft/vcpkg/pull/9550)| 2018-01-04
|[coin](https://github.com/microsoft/vcpkg/pull/9880)| 4.0.0
|[simage](https://github.com/microsoft/vcpkg/pull/9880)| 1.8.0
|[soqt](https://github.com/microsoft/vcpkg/pull/9880)| 1.6.0
|[gmp](https://github.com/microsoft/vcpkg/pull/10613)<sup>[#11565](https://github.com/microsoft/vcpkg/pull/11565) </sup>| 6.2.0-1
|[nettle](https://github.com/microsoft/vcpkg/pull/10613)<sup>[#11565](https://github.com/microsoft/vcpkg/pull/11565) </sup>| 3.5.1-1
|[vs-yasm](https://github.com/microsoft/vcpkg/pull/10613)| 0.5.0
|[uthenticode](https://github.com/microsoft/vcpkg/pull/11199)<sup>[#11256](https://github.com/microsoft/vcpkg/pull/11256) [#11362](https://github.com/microsoft/vcpkg/pull/11362) </sup>| 1.0.4
|[bitserializer-pugixml](https://github.com/microsoft/vcpkg/pull/11241)<sup>[#11683](https://github.com/microsoft/vcpkg/pull/11683) </sup>| alias
|[ignition-math6](https://github.com/microsoft/vcpkg/pull/11232)| 6.4.0
|[vtk-m](https://github.com/microsoft/vcpkg/pull/11148)| 1.5.0
|[crashpad](https://github.com/microsoft/vcpkg/pull/10505)| 2020-03-18
|[bitserializer-rapidyaml](https://github.com/microsoft/vcpkg/pull/11242)<sup>[#11683](https://github.com/microsoft/vcpkg/pull/11683) </sup>| alias
|[ignition-msgs5](https://github.com/microsoft/vcpkg/pull/11272)<sup>[#11397](https://github.com/microsoft/vcpkg/pull/11397) </sup>| 5.1.0
|[ignition-transport8](https://github.com/microsoft/vcpkg/pull/11272)| 8.0.0
|[sdformat9](https://github.com/microsoft/vcpkg/pull/11265)<sup>[#11742](https://github.com/microsoft/vcpkg/pull/11742) </sup>| 9.2.0-1
|[kissfft](https://github.com/microsoft/vcpkg/pull/9237)| 2020-03-30
|[jaeger-client-cpp](https://github.com/microsoft/vcpkg/pull/9126)<sup>[#11583](https://github.com/microsoft/vcpkg/pull/11583) </sup>| 0.5.1-1
|[libmediainfo](https://github.com/microsoft/vcpkg/pull/7005)| 20.03
|[h5py-lzf](https://github.com/microsoft/vcpkg/pull/10871)| 2019-12-04
|[microsoft-signalr](https://github.com/microsoft/vcpkg/pull/10833)<sup>[#11496](https://github.com/microsoft/vcpkg/pull/11496) </sup>| 0.1.0-alpha1-1
|[oatpp-consul](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[oatpp-curl](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[oatpp-libressl](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[oatpp-mbedtls](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[oatpp-swagger](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[oatpp-websocket](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[oatpp](https://github.com/microsoft/vcpkg/pull/9402)| 1.0.0
|[gperftools](https://github.com/microsoft/vcpkg/pull/8750)| 2019-09-02
|[libvmdk](https://github.com/microsoft/vcpkg/pull/11010)| 2019-12-21
|[ctp](https://github.com/microsoft/vcpkg/pull/10717)| 6.3.15_20190220_se
|[munit](https://github.com/microsoft/vcpkg/pull/6780)| 2019-04-06
|[mmloader](https://github.com/microsoft/vcpkg/pull/11381)| 2020-05-15
|[absent](https://github.com/microsoft/vcpkg/pull/11447)| 0.3.0
|[ocilib](https://github.com/microsoft/vcpkg/pull/11549)<sup>[#11646](https://github.com/microsoft/vcpkg/pull/11646) </sup>| 4.6.4-1
|[tinyply](https://github.com/microsoft/vcpkg/pull/11534)| 2020-05-22
|[symengine](https://github.com/microsoft/vcpkg/pull/8752)| 2020-05-25
|[nanoprintf](https://github.com/microsoft/vcpkg/pull/11605)| 2020-05-27
|[wavelib](https://github.com/microsoft/vcpkg/pull/11611)| 2020-05-29
|[refl-cpp](https://github.com/microsoft/vcpkg/pull/11622)| 0.9.1
|[trantor](https://github.com/microsoft/vcpkg/pull/11533)| v1.0.0-rc13
|[sockpp](https://github.com/microsoft/vcpkg/pull/11562)| 0.7
|[protozero](https://github.com/microsoft/vcpkg/pull/11652)| 1.6.8
|[p-ranav-csv2](https://github.com/microsoft/vcpkg/pull/11725)| 2020-06-02
|[cr](https://github.com/microsoft/vcpkg/pull/11841)| 2020-04-26
|[json-schema-validator](https://github.com/microsoft/vcpkg/pull/11599)| 2.1.0
|[log4cxx](https://github.com/microsoft/vcpkg/pull/11659)| 0.10.0-2
|[xbyak](https://github.com/microsoft/vcpkg/pull/11689)| 5.911
|[licensepp](https://github.com/microsoft/vcpkg/pull/11711)| 2020-05-19
|[v-hacd](https://github.com/microsoft/vcpkg/pull/11606)| 3.2.0
|[libosmium](https://github.com/microsoft/vcpkg/pull/11863)| 2.15.5
|[gzip-hpp](https://github.com/microsoft/vcpkg/pull/11735)| 0.1.0
|[infoware](https://github.com/microsoft/vcpkg/pull/11410)| 0.5.3
</details>

<details>
<summary><b>The following 375 ports have been updated:</b></summary>

- otl `4.0.451` -> `4.0.455`
    - [(#10922)](https://github.com/microsoft/vcpkg/pull/10922) [vcpkg baseline] Update hash for otl
    - [(#11300)](https://github.com/microsoft/vcpkg/pull/11300) [otl] Update to 4.0.455

- vtk `8.2.0-12` -> `9.0-2`
    - [(#10925)](https://github.com/microsoft/vcpkg/pull/10925) [VTK] Check if VTKTarget files exist
    - [(#11148)](https://github.com/microsoft/vcpkg/pull/11148) [VTK/vtk-m]  Update VTK to 9.0 and add vtk-m
    - [(#11643)](https://github.com/microsoft/vcpkg/pull/11643) [vtk] Fix single configuration builds
    - [(#11708)](https://github.com/microsoft/vcpkg/pull/11708) [python3] Update to Python 3.8

- winreg `1.2.1-1` -> `3.1.0`
    - [(#10926)](https://github.com/microsoft/vcpkg/pull/10926) [winreg] Update to 2.2.0
    - [(#10976)](https://github.com/microsoft/vcpkg/pull/10976) [WinReg] update to v2.2.2
    - [(#11034)](https://github.com/microsoft/vcpkg/pull/11034) [winreg] Update to 2.2.3
    - [(#11766)](https://github.com/microsoft/vcpkg/pull/11766) [winreg] Update to 2.4.0
    - [(#11883)](https://github.com/microsoft/vcpkg/pull/11883) [WinReg] Update to 3.0.1
    - [(#11888)](https://github.com/microsoft/vcpkg/pull/11888) [WinReg] Update to 3.1.0

- libyaml `0.2.2-2` -> `0.2.2-3`
    - [(#10908)](https://github.com/microsoft/vcpkg/pull/10908) [libyaml] Fix linkage in non-Windows systems

- libzippp `2019-07-22` -> `3.1-1.6.1`
    - [(#10893)](https://github.com/microsoft/vcpkg/pull/10893) [libzippp] Update to libzippp-v3.1-1.6.1

- blend2d `beta_2020-04-15` -> `beta_2020-06-01`
    - [(#10891)](https://github.com/microsoft/vcpkg/pull/10891) [blend2d] Update to beta_2020-04-19
    - [(#11155)](https://github.com/microsoft/vcpkg/pull/11155) [blend2d] Update to beta_2020-05-04
    - [(#11778)](https://github.com/microsoft/vcpkg/pull/11778) [blend2d] Update to beta_2020-06-01

- pegtl `3.0.0-pre-9d58962` -> `3.0.0-pre-83b6cdc`
    - [(#10870)](https://github.com/microsoft/vcpkg/pull/10870) [pegtl] Update to latest commit from 4/5/2020
    - [(#11148)](https://github.com/microsoft/vcpkg/pull/11148) [VTK/vtk-m]  Update VTK to 9.0 and add vtk-m
    - [(#11531)](https://github.com/microsoft/vcpkg/pull/11531) [pegtl/cppgraphqlgen] matching updates for dependency

- skyr-url `1.5.1` -> `1.9.0`
    - [(#10868)](https://github.com/microsoft/vcpkg/pull/10868) [skyr-url] Bump version to 1.7.0
    - [(#10954)](https://github.com/microsoft/vcpkg/pull/10954) [skyr-url] Updated port to use version 1.7.3
    - [(#11153)](https://github.com/microsoft/vcpkg/pull/11153) [skyr-url] Changed skyr-url version number to 1.7.5
    - [(#11568)](https://github.com/microsoft/vcpkg/pull/11568) [skyr-url] Changed version number to 1.9.0
    - [(#11774)](https://github.com/microsoft/vcpkg/pull/11774) [skyr-url] Changed version number for skyr-url

- protobuf `3.11.3` -> `3.12.0-2`
    - [(#10863)](https://github.com/microsoft/vcpkg/pull/10863) [protobuf] Update to 3.11.4
    - [(#11228)](https://github.com/microsoft/vcpkg/pull/11228) [protobuf] Correct protobuf under android (Fix issue #8218)
    - [(#11397)](https://github.com/microsoft/vcpkg/pull/11397) [protobuf] protobuf v3.12.0
    - [(#11504)](https://github.com/microsoft/vcpkg/pull/11504) [protobuf] Fix RPATH error for static build
    - [(#11516)](https://github.com/microsoft/vcpkg/pull/11516) [protobuf] Don't redefine PROTOBUF_USE_DLLS

- sdformat6 `6.2.0` -> `6.2.0-1`
    - [(#10859)](https://github.com/microsoft/vcpkg/pull/10859) [sdformat6] Migrate from Bitbucket to GitHub 🤖

- ompl `1.4.2-2` -> `1.4.2-4`
    - [(#10854)](https://github.com/microsoft/vcpkg/pull/10854) [ompl] Fix ompl[app] build error
    - [(#10972)](https://github.com/microsoft/vcpkg/pull/10972) [ompl] Fix patch apply error

- dlib `19.17-1` -> `19.19-1`
    - [(#10826)](https://github.com/microsoft/vcpkg/pull/10826) [dlib] Updated dlib to v19.19
    - [(#11195)](https://github.com/microsoft/vcpkg/pull/11195) [dlib] add more granularity in features

- arrow `0.17.0` -> `0.17.1`
    - [(#10800)](https://github.com/microsoft/vcpkg/pull/10800) [Arrow] Explicitly enable CSV and JSON
    - [(#11016)](https://github.com/microsoft/vcpkg/pull/11016) [Arrow] Add filesystem feature
    - [(#11472)](https://github.com/microsoft/vcpkg/pull/11472) [Arrow] Update to 0.17.1

- ace `6.5.8` -> `6.5.9-5`
    - [(#10984)](https://github.com/microsoft/vcpkg/pull/10984) [ace] Add support for MacOSX
    - [(#11112)](https://github.com/microsoft/vcpkg/pull/11112) [ace] Update to 6.5.9
    - [(#11369)](https://github.com/microsoft/vcpkg/pull/11369) [ace] Add patch to fix Visual Studio 2019 16.5 internal compiler error
    - [(#11441)](https://github.com/microsoft/vcpkg/pull/11441) [ace] Add support for uwp
    - [(#11464)](https://github.com/microsoft/vcpkg/pull/11464) [ace] Simplified port file
    - [(#11713)](https://github.com/microsoft/vcpkg/pull/11713) [ace] Fix missing cpp files
    - [(#11473)](https://github.com/microsoft/vcpkg/pull/11473) [ace] tao as feature

- libaaplus `2.12` -> `2.12-1`
    - [(#10981)](https://github.com/microsoft/vcpkg/pull/10981) [libaaplus] Use versioned download link

- spscqueue `2019-07-26` -> `1.0`
    - [(#10874)](https://github.com/microsoft/vcpkg/pull/10874) [spscqueue] Update to version 1.0

- googleapis `0.8.0` -> `alias`
    - [(#10994)](https://github.com/microsoft/vcpkg/pull/10994) [googleapis] update to v0.9.0
    - [(#11698)](https://github.com/microsoft/vcpkg/pull/11698) [google-cloud-cpp] Consolidate all google-cloud* packages

- ms-gsl `3.0.0` -> `3.0.1`
    - [(#10993)](https://github.com/microsoft/vcpkg/pull/10993) [ms-gsl] Update to 3.0.1

- ryu `2.0-1` -> `2.0-2`
    - [(#10989)](https://github.com/microsoft/vcpkg/pull/10989) [ryu]Ryu include fix

- glm `0.9.9.7` -> `0.9.9.8`
    - [(#10977)](https://github.com/microsoft/vcpkg/pull/10977) [glm, sqlitecpp] update to new version

- sqlitecpp `2.3.0-1` -> `3.0.0`
    - [(#10977)](https://github.com/microsoft/vcpkg/pull/10977) [glm, sqlitecpp] update to new version

- nngpp `1.2.4` -> `1.3.0`
    - [(#10975)](https://github.com/microsoft/vcpkg/pull/10975) [nngpp] Update to 1.3.0

- libvpx `1.8.1-1` -> `1.8.1-5`
    - [(#10952)](https://github.com/microsoft/vcpkg/pull/10952) [libvpx][mpg123] Fix use of YASM in MSBuild (via path)
    - [(#11058)](https://github.com/microsoft/vcpkg/pull/11058) [msbuild]fix use UseEnv-True
    - [(#11022)](https://github.com/microsoft/vcpkg/pull/11022) [libvpx] Added support for build on MacOS and Linux
    - [(#11500)](https://github.com/microsoft/vcpkg/pull/11500) [libvpx] Change default target on Unix
    - [(#11795)](https://github.com/microsoft/vcpkg/pull/11795) [libvpx] Add cmake config file

- mpg123 `1.25.8-6` -> `1.25.8-9`
    - [(#10952)](https://github.com/microsoft/vcpkg/pull/10952) [libvpx][mpg123] Fix use of YASM in MSBuild (via path)
    - [(#11058)](https://github.com/microsoft/vcpkg/pull/11058) [msbuild]fix use UseEnv-True
    - [(#11287)](https://github.com/microsoft/vcpkg/pull/11287) [mpg123] Enable UWP support
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- qt5-3d `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-activeqt `5.12.5-1` -> `5.12.8-1`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8
    - [(#11045)](https://github.com/microsoft/vcpkg/pull/11045) [qt5] reactivate qt5-activeqt for CI coverage

- qt5-base `5.12.5-13` -> `5.12.8-4`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8
    - [(#11111)](https://github.com/microsoft/vcpkg/pull/11111) [qt5] Add -j to make to parallelize on Linux and MacOS
    - [(#11371)](https://github.com/microsoft/vcpkg/pull/11371) [qt5-base] Add Xorg dependency libx11-xcb-dev
    - [(#11416)](https://github.com/microsoft/vcpkg/pull/11416) [harfbuzz,skia] Update and replace Skia dependencies with vcpkg
    - [(#11483)](https://github.com/microsoft/vcpkg/pull/11483) [vcpkg] Allow CI to pass in all relevant directories and remove use of symbolic links

- qt5-charts `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-connectivity `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-datavis3d `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-declarative `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-gamepad `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-graphicaleffects `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-imageformats `5.12.5-3` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-location `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-macextras `5.12.5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-mqtt `5.12.5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-multimedia `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-networkauth `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-purchasing `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-quickcontrols `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-quickcontrols2 `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-remoteobjects `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-script `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-scxml `5.12.5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-sensors `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-serialport `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-speech `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-svg `5.12.5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-tools `5.12.5-5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-virtualkeyboard `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-webchannel `5.12.5-2` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-websockets `5.12.5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-webview `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-winextras `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5-xmlpatterns `5.12.5-1` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- qt5 `5.12.5` -> `5.12.8`
    - [(#10644)](https://github.com/microsoft/vcpkg/pull/10644) [Qt[latest]] Update to 5.14.2
    - [(#10749)](https://github.com/microsoft/vcpkg/pull/10749) [Qt5] Update qt to 5.12.8

- libzip `rel-1-5-2--1` -> `rel-1-6-1`
    - [(#10784)](https://github.com/microsoft/vcpkg/pull/10784) [libzip] update to rel-1-6-1

- nng `1.2.5` -> `1.3.0`
    - [(#10974)](https://github.com/microsoft/vcpkg/pull/10974) [nng] Update to 1.3.0

- libmupdf `1.16.1` -> `1.16.1-1`
    - [(#10708)](https://github.com/microsoft/vcpkg/pull/10708) [libmupdf] fix build error on Linux

- catch2 `2.11.3` -> `2.12.1`
    - [(#10996)](https://github.com/microsoft/vcpkg/pull/10996) [catch2] Update to 2.12.1

- websocketpp `0.8.1-1` -> `0.8.2`
    - [(#10969)](https://github.com/microsoft/vcpkg/pull/10969) [websocketpp] Update to 0.8.2

- coroutine `2020-01-13` -> `1.5.0`
    - [(#10692)](https://github.com/microsoft/vcpkg/pull/10692) [coroutine] update to 1.5.0

- boost-modular-build-helper `1.72.0-1` -> `1.73.0-1`
    - [(#10285)](https://github.com/microsoft/vcpkg/pull/10285) [boost-modular-build-helper] Support Clang '--target=<value>' syntax to enable Android builds
    - [(#10814)](https://github.com/microsoft/vcpkg/pull/10814) [boost-modular-build] Fix lack of arm64-linux support
    - [(#11427)](https://github.com/microsoft/vcpkg/pull/11427) [boost] MinGW build fixes

- openssl-unix `1.1.1d-2` -> `1.1.1d-4`
    - [(#10450)](https://github.com/microsoft/vcpkg/pull/10450) [openssl-unix] Update header path for shared library compilation
    - [(#11344)](https://github.com/microsoft/vcpkg/pull/11344) [openssl-unix] Fix openssl-unix android build

- sdl2-gfx `1.0.4-5` -> `1.0.4-6`
    - [(#10575)](https://github.com/microsoft/vcpkg/pull/10575) [sdl2-gfx] Fix build error on non windows

- hwloc `1.11.7-3` -> `1.11.7-4`
    - [(#10615)](https://github.com/microsoft/vcpkg/pull/10615) [hwloc] Support UNIX

- pixel `0.3` -> `0.3-1`
    - [(#10638)](https://github.com/microsoft/vcpkg/pull/10638) [pixel] Add warning message on Linux

- qt-advanced-docking-system `2019-08-14-1` -> `3.2.5-1`
    - [(#10170)](https://github.com/microsoft/vcpkg/pull/10170) [qt-advanced-docking-system] updated qt-advanced-docking-system to 3.2.1
    - [(#10980)](https://github.com/microsoft/vcpkg/pull/10980) [vcpkg] Onboard Linux to VMSS, open 'git' port, and switch back to Azure Spot

- libarchive `3.4.1-1` -> `3.4.1-3`
    - [(#11044)](https://github.com/microsoft/vcpkg/pull/11044) [libarchive] expose zstd as a build feature
    - [(#11570)](https://github.com/microsoft/vcpkg/pull/11570) [libarchive] Disable C4061 which causes build to fail in Visual Studio 2019 16.6

- azure-kinect-sensor-sdk `1.4.0-alpha.0-2` -> `1.4.0-alpha.0-5`
    - [(#11033)](https://github.com/microsoft/vcpkg/pull/11033) [azure-kinect-sensor-sdk] Fix pipeline error
    - [(#10253)](https://github.com/microsoft/vcpkg/pull/10253) [imgui] Add feature bindings and remove feature example
    - [(#11116)](https://github.com/microsoft/vcpkg/pull/11116) [azure-kinect-sensor-sdk] Disable parallel configure due to source directory writes
    - [(#11139)](https://github.com/microsoft/vcpkg/pull/11139) [azure-kinect-sensor-sdk] Fix Deploy Azure Kinect Sensor SDK on Windows

- range-v3 `0.10.0` -> `0.10.0-20200425`
    - [(#11031)](https://github.com/microsoft/vcpkg/pull/11031) [range-v3] Update to new version.

- ode `0.16` -> `0.16.1`
    - [(#11029)](https://github.com/microsoft/vcpkg/pull/11029) [ode] Bump version to 0.16.1

- boost-coroutine `1.72.0` -> `1.73.0`
    - [(#10988)](https://github.com/microsoft/vcpkg/pull/10988) [boost-coroutine] Add patch from boost.org
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- libtorrent `1.2.2-1` -> `1.2.7`
    - [(#10686)](https://github.com/microsoft/vcpkg/pull/10686) [libtorrent] Update to 1.2.6 and add features
    - [(#11257)](https://github.com/microsoft/vcpkg/pull/11257) [libtorrent] add iconv feature on windows and clean up portfile
    - [(#11389)](https://github.com/microsoft/vcpkg/pull/11389) [libtorrent] minor portfile simplification and version bump
    - [(#11709)](https://github.com/microsoft/vcpkg/pull/11709) [libtorrent] Update to 1.2.7

- geos `3.6.3-3` -> `3.6.4`
    - [(#10377)](https://github.com/microsoft/vcpkg/pull/10377) [geos] Upgrade to GEOS 3.6.4

- egl-registry `2020-02-03` -> `2020-02-20`
    - [(#10676)](https://github.com/microsoft/vcpkg/pull/10676) [egl-registry, opengl-registry] Update egl-registry to 2020-02-20 and opengl-registry to 2020-03-25

- opengl-registry `2020-02-03` -> `2020-03-25`
    - [(#10676)](https://github.com/microsoft/vcpkg/pull/10676) [egl-registry, opengl-registry] Update egl-registry to 2020-02-20 and opengl-registry to 2020-03-25

- murmurhash `2016-01-09` -> `2016-01-09-3`
    - [(#11011)](https://github.com/microsoft/vcpkg/pull/11011) [murmurhash] installation fix
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- gts `0.7.6-1` -> `0.7.6-3`
    - [(#10055)](https://github.com/microsoft/vcpkg/pull/10055) [gts] Support for build with cmake in unix
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2
    - [(#11884)](https://github.com/microsoft/vcpkg/pull/11884) [glib/gts] Add pkgconfig files

- icu `65.1-3` -> `67.1`
    - [(#10656)](https://github.com/microsoft/vcpkg/pull/10656) [icu] Fix configure failure due to not finding python
    - [(#11714)](https://github.com/microsoft/vcpkg/pull/11714) [icu] Update to 67.1

- ffmpeg `4.2-7` -> `4.2-9`
    - [(#8797)](https://github.com/microsoft/vcpkg/pull/8797) [ffmpeg] Fix ffmpeg[opencl, openssl, lzma] static build failed
    - [(#11443)](https://github.com/microsoft/vcpkg/pull/11443) [vcpkg-acquire-msys] Update pacman before any other package.
    - [(#11810)](https://github.com/microsoft/vcpkg/pull/11810) [vcpkg-acquire-msys] Improvement

- liblzma `5.2.4-4` -> `5.2.4-5`
    - [(#8797)](https://github.com/microsoft/vcpkg/pull/8797) [ffmpeg] Fix ffmpeg[opencl, openssl, lzma] static build failed

- cpprestsdk `2.10.15-1` -> `2.10.16-2`
    - [(#11018)](https://github.com/microsoft/vcpkg/pull/11018) [cpprestsdk] Update to v2.10.16
    - [(#11694)](https://github.com/microsoft/vcpkg/pull/11694) [cpprestsdk] Avoid using pkg-config to find OpenSSL libraries on Linux
    - [(#11867)](https://github.com/microsoft/vcpkg/pull/11867) [cpprestsdk] Fix find dependency openssl

- harfbuzz `2.5.3` -> `2.6.6`
    - [(#11082)](https://github.com/microsoft/vcpkg/pull/11082) [harfbuzz] Change build depends from freetype to freetype[core]
    - [(#11416)](https://github.com/microsoft/vcpkg/pull/11416) [harfbuzz,skia] Update and replace Skia dependencies with vcpkg

- pcl `1.9.1-11` -> `1.9.1-13`
    - [(#11047)](https://github.com/microsoft/vcpkg/pull/11047) [pcl] Fix link to libpng
    - [(#11148)](https://github.com/microsoft/vcpkg/pull/11148) [VTK/vtk-m]  Update VTK to 9.0 and add vtk-m

- armadillo `2019-04-16-6` -> `2019-04-16-8`
    - [(#11063)](https://github.com/microsoft/vcpkg/pull/11063) [armadillo] Add dependent port superlu on osx

- abseil `2020-03-03-3` -> `2020-03-03-6`
    - [(#11039)](https://github.com/microsoft/vcpkg/pull/11039) [abseil] Configure abseil to use std:: types when feature cxx17 is enabled
    - [(#11630)](https://github.com/microsoft/vcpkg/pull/11630) [abseil] Fix arm build
    - [(#11827)](https://github.com/microsoft/vcpkg/pull/11827) [abseil] Enable dynamic build on Windows

- metrohash `1.1.3` -> `1.1.3-1`
    - [(#10992)](https://github.com/microsoft/vcpkg/pull/10992) [metrohash] installation fix
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- nana `1.7.2-1` -> `1.7.2-3`
    - [(#10936)](https://github.com/microsoft/vcpkg/pull/10936) [nana] Revert 1 darkcacok patch nana
    - [(#11494)](https://github.com/microsoft/vcpkg/pull/11494) [basisu, gppanel, msgpack11, nana, rapidcheck, folly] Add missing header file of STL

- alembic `1.7.12` -> `1.7.12-1`
    - [(#10912)](https://github.com/microsoft/vcpkg/pull/10912) [alembic] linux fixes

- civetweb `2019-07-05-1` -> `1.12`
    - [(#10591)](https://github.com/microsoft/vcpkg/pull/10591) [civetweb] Update to version 1.12

- argh `2018-12-18-1` -> `2018-12-18-2`
    - [(#10980)](https://github.com/microsoft/vcpkg/pull/10980) [vcpkg] Onboard Linux to VMSS, open 'git' port, and switch back to Azure Spot

- ceres `1.14.0-6` -> `1.14.0-7`
    - [(#10980)](https://github.com/microsoft/vcpkg/pull/10980) [vcpkg] Onboard Linux to VMSS, open 'git' port, and switch back to Azure Spot
    - [(#11200)](https://github.com/microsoft/vcpkg/pull/11200) [ceres] Added patch to add find_dependency() for suitesparse targets downstream

- idevicerestore `1.0.12-3` -> `1.0.12-4`
    - [(#10980)](https://github.com/microsoft/vcpkg/pull/10980) [vcpkg] Onboard Linux to VMSS, open 'git' port, and switch back to Azure Spot
    - [(#11074)](https://github.com/microsoft/vcpkg/pull/11074) [idevicerestore] Fix libgen.h cannot be found

- openblas `0.3.7` -> `0.3.9-1`
    - [(#10980)](https://github.com/microsoft/vcpkg/pull/10980) [vcpkg] Onboard Linux to VMSS, open 'git' port, and switch back to Azure Spot

- imgui `1.74` -> `1.76-1`
    - [(#10253)](https://github.com/microsoft/vcpkg/pull/10253) [imgui] Add feature bindings and remove feature example
    - [(#11388)](https://github.com/microsoft/vcpkg/pull/11388) [imgui] Update to 1.76

- libigl `2.1.0-1` -> `2.1.0-2`
    - [(#10253)](https://github.com/microsoft/vcpkg/pull/10253) [imgui] Add feature bindings and remove feature example

- opencv4 `4.1.1-3` -> `4.1.1-6`
    - [(#10886)](https://github.com/microsoft/vcpkg/pull/10886) [opencv4] Add GTK support for opencv4 portfile
    - [(#7849)](https://github.com/microsoft/vcpkg/pull/7849) [OpenCV2] add new "old" port
    - [(#11201)](https://github.com/microsoft/vcpkg/pull/11201) [opencv4] Changed dependency on qt5 to qt5-base, closes microsoft/vcpkg#11138
    - [(#11429)](https://github.com/microsoft/vcpkg/pull/11429) [opencv4] Fix linking halide

- libbson `1.15.1-1` -> `1.16.1`
    - [(#10010)](https://github.com/microsoft/vcpkg/pull/10010) [libbson/mongo-c-driver] Update to 1.16.1

- mongo-c-driver `1.15.1-1` -> `1.16.1-1`
    - [(#10010)](https://github.com/microsoft/vcpkg/pull/10010) [libbson/mongo-c-driver] Update to 1.16.1
    - [(#11217)](https://github.com/microsoft/vcpkg/pull/11217) [mongo-c-driver] Fix find_package error

- mongo-cxx-driver `3.4.0-4` -> `3.4.0-5`
    - [(#10010)](https://github.com/microsoft/vcpkg/pull/10010) [libbson/mongo-c-driver] Update to 1.16.1
    - [(#11584)](https://github.com/microsoft/vcpkg/pull/11584) [mongo-cxx-driver] Patch std::atomic P0883 changes

- cpuinfo `2019-07-28` -> `2019-07-28-1`
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools

- czmq `2019-06-10-3` -> `2019-06-10-4`
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools

- libsvm `323` -> `323-1`
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools

- nanomsg `1.1.5-1` -> `1.1.5-2`
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools

- uriparser `0.9.3-4` -> `0.9.3-5`
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools

- zyre `2019-07-07` -> `2019-07-07-1`
    - [(#8749)](https://github.com/microsoft/vcpkg/pull/8749) [vcpkg] Add new function vcpkg_copy_tools

- halide `release_2019_08_27-2` -> `master_2020_03_07`
    - [(#10295)](https://github.com/microsoft/vcpkg/pull/10295) [llvm] Update to version 10.0.0 and add new features

- llvm `8.0.0-5` -> `10.0.0-3`
    - [(#10295)](https://github.com/microsoft/vcpkg/pull/10295) [llvm] Update to version 10.0.0 and add new features
    - [(#11174)](https://github.com/microsoft/vcpkg/pull/11174) [vcpkg] [llvm] Bump Linux VM memory size and do all operations on the temporary disk.
    - [(#11268)](https://github.com/microsoft/vcpkg/pull/11268) [llvm] add more backend options, fix issues
    - [(#11703)](https://github.com/microsoft/vcpkg/pull/11703) [llvm] fix llvm-tblgen build with MSVC v19.26

- sciter `4.4.1.5` -> `4.4.3.20`
    - [(#11161)](https://github.com/microsoft/vcpkg/pull/11161) [sciter] Update to 4.4.3.15.7771
    - [(#11393)](https://github.com/microsoft/vcpkg/pull/11393) [sciter] Update to 4.4.3.18.7817
    - [(#11723)](https://github.com/microsoft/vcpkg/pull/11723) [sciter] Update to 4.4.3.20.7852

- apr-util `1.6.0-5` -> `1.6.1-1`
    - [(#8579)](https://github.com/microsoft/vcpkg/pull/8579) [apr apr-util] Apr and apr-util for non windows systems
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports

- apr `1.6.5-3` -> `1.7.0`
    - [(#8579)](https://github.com/microsoft/vcpkg/pull/8579) [apr apr-util] Apr and apr-util for non windows systems

- opencv3 `3.4.7-2` -> `3.4.7-3`
    - [(#7849)](https://github.com/microsoft/vcpkg/pull/7849) [OpenCV2] add new "old" port
    - [(#11201)](https://github.com/microsoft/vcpkg/pull/11201) [opencv4] Changed dependency on qt5 to qt5-base, closes microsoft/vcpkg#11138

- gtest `2019-10-09-1` -> `1.10.0`
    - [(#10963)](https://github.com/microsoft/vcpkg/pull/10963) [gtest] Rollback to a release version.

- ignition-cmake0 `0.6.2-1` -> `0.6.2-2`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖

- ignition-cmake2 `2.1.1` -> `2.2.0-1`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖
    - [(#11232)](https://github.com/microsoft/vcpkg/pull/11232) [ignition-math6] Add new port 🤖
    - [(#11270)](https://github.com/microsoft/vcpkg/pull/11270) [eigen3] [ignition-modularscripts] Fix installed pkgconfig files

- ignition-common1 `1.1.1` -> `1.1.1-1`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖

- ignition-fuel-tools1 `1.2.0` -> `1.2.0-2`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖
    - [(#11270)](https://github.com/microsoft/vcpkg/pull/11270) [eigen3] [ignition-modularscripts] Fix installed pkgconfig files

- ignition-math4 `4.0.0` -> `4.0.0-1`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖

- ignition-modularscripts `2020-02-10` -> `2020-05-09`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖
    - [(#11270)](https://github.com/microsoft/vcpkg/pull/11270) [eigen3] [ignition-modularscripts] Fix installed pkgconfig files

- ignition-msgs1 `1.0.0` -> `1.0.0-1`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖

- ignition-transport4 `4.0.0` -> `4.0.0-2`
    - [(#10858)](https://github.com/microsoft/vcpkg/pull/10858) [ignition-modular-scripts] Migrate from Bitbucket to GitHub 🤖
    - [(#11270)](https://github.com/microsoft/vcpkg/pull/11270) [eigen3] [ignition-modularscripts] Fix installed pkgconfig files

- cuda `10.1` -> `10.1-1`
    - [(#10838)](https://github.com/microsoft/vcpkg/pull/10838) [cuda] Fix find cuda in UNIX

- libiconv `1.16-1` -> `1.16-3`
    - [(#9832)](https://github.com/microsoft/vcpkg/pull/9832) libiconv - Fix ICONV_CONST
    - [(#11586)](https://github.com/microsoft/vcpkg/pull/11586) [vcpkg-baseline][zxing-cpp] Fix build failure

- glib `2.52.3-14-5` -> `2.52.3-14-7`
    - [(#10856)](https://github.com/microsoft/vcpkg/pull/10856) [glib] Update the usage of string(TOUPPER ...)
    - [(#11884)](https://github.com/microsoft/vcpkg/pull/11884) [glib/gts] Add pkgconfig files

- freerdp `2.0.0-rc4-7` -> `2.0.0-1`
    - [(#11051)](https://github.com/microsoft/vcpkg/pull/11051) [freerdp] Update to 2.0.0
    - [(#11639)](https://github.com/microsoft/vcpkg/pull/11639) [freerdp] Optional 'urbdrc' feature

- wxwidgets `3.1.3` -> `3.1.3-1`
    - [(#11178)](https://github.com/microsoft/vcpkg/pull/11178) [wxwidgets] Apply fix to wxWidgets for copy and paste macOS

- libsquish `1.15-2` -> `1.15-3`
    - [(#11124)](https://github.com/microsoft/vcpkg/pull/11124) [libsquish] add missing SQUISH_EXPORT

- bitserializer-cpprestjson `0.8` -> `alias`
    - [(#11157)](https://github.com/microsoft/vcpkg/pull/11157) [BitSerializer] Update to version 0.9
    - [(#11683)](https://github.com/microsoft/vcpkg/pull/11683) [bitserializer] Update to new version 0.10

- bitserializer-rapidjson `0.8` -> `alias`
    - [(#11157)](https://github.com/microsoft/vcpkg/pull/11157) [BitSerializer] Update to version 0.9
    - [(#11683)](https://github.com/microsoft/vcpkg/pull/11683) [bitserializer] Update to new version 0.10

- bitserializer `0.8` -> `0.9`
    - [(#11157)](https://github.com/microsoft/vcpkg/pull/11157) [BitSerializer] Update to version 0.9
    - [(#11683)](https://github.com/microsoft/vcpkg/pull/11683) [bitserializer] Update to new version 0.10

- gsoap `2.8.93-2` -> `2.8.93-3`
    - [(#11048)](https://github.com/microsoft/vcpkg/pull/11048) [gsoap] Add supports for gsoap
    - [(#11355)](https://github.com/microsoft/vcpkg/pull/11355) [gSoap] Update to 2.8.102 and re-enable x64 Builds

- lua `5.3.5-3` -> `5.3.5-5`
    - [(#11163)](https://github.com/microsoft/vcpkg/pull/11163) [lua] Compile as position-independent code
    - [(#11870)](https://github.com/microsoft/vcpkg/pull/11870) [lua] Add vcpkg-cmake-wrapper

- gainput `1.0.0-2` -> `1.0.0-3`
    - [(#11000)](https://github.com/microsoft/vcpkg/pull/11000) [gainput] imporve cmake search gainput library

- opencl `2.2-2` -> `2.2-2-1`
    - [(#10567)](https://github.com/microsoft/vcpkg/pull/10567) [opencl] Add build type when installing targets

- azure-iot-sdk-c `2020-02-04.1` -> `2020-02-04.1-1`
    - [(#11017)](https://github.com/microsoft/vcpkg/pull/11017) [azure-iot-sdk-c] Fixed the CMake config export.

- sfml `2.5.1-6` -> `2.5.1-7`
    - [(#11246)](https://github.com/microsoft/vcpkg/pull/11246) [sfml] Remove unnecessary patch

- asmjit `2020-02-08` -> `2020-05-08`
    - [(#11245)](https://github.com/microsoft/vcpkg/pull/11245) [asmjit] Update to the latest commit

- libpq `12.0-1` -> `12.2-2`
    - [(#11223)](https://github.com/microsoft/vcpkg/pull/11223) [libpq] link libdl on linux
    - [(#10915)](https://github.com/microsoft/vcpkg/pull/10915) [libpq] Update to 12.2 and some feature fixes
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds
    - [(#11612)](https://github.com/microsoft/vcpkg/pull/11612) [vcpkg baseline] Fix baseline failures
    - [(#11483)](https://github.com/microsoft/vcpkg/pull/11483) [vcpkg] Allow CI to pass in all relevant directories and remove use of symbolic links

- allegro5 `5.2.5.0` -> `5.2.6.0`
    - [(#11187)](https://github.com/microsoft/vcpkg/pull/11187) [Allegro] Update to 5.2.6.0

- lz4 `1.9.2-1` -> `1.9.2-2`
    - [(#11148)](https://github.com/microsoft/vcpkg/pull/11148) [VTK/vtk-m]  Update VTK to 9.0 and add vtk-m

- pegtl-2 `2.8.1` -> `2.8.1-1`
    - [(#11148)](https://github.com/microsoft/vcpkg/pull/11148) [VTK/vtk-m]  Update VTK to 9.0 and add vtk-m

- vtk-dicom `0.8.12` -> `0.8.12-1`
    - [(#11148)](https://github.com/microsoft/vcpkg/pull/11148) [VTK/vtk-m]  Update VTK to 9.0 and add vtk-m

- libzen `0.4.37` -> `0.4.38`
    - [(#11237)](https://github.com/microsoft/vcpkg/pull/11237) [libzen] Update to 0.4.38

- speexdsp `1.2.0-1` -> `1.2.0-2`
    - [(#11218)](https://github.com/microsoft/vcpkg/pull/11218) [speexdsp] Change repo to github

- restclient-cpp `0.5.1-3` -> `0.5.2`
    - [(#9717)](https://github.com/microsoft/vcpkg/pull/9717) [restclient-cpp] Fix portfile and update version.

- libpng `1.6.37-7` -> `1.6.37-9`
    - [(#11162)](https://github.com/microsoft/vcpkg/pull/11162) [libpng] Fix missing symbols when compiling for ARM
    - [(#11280)](https://github.com/microsoft/vcpkg/pull/11280) [libpng] Fix android build

- capstone `4.0.1-120373dc` -> `4.0.2`
    - [(#11250)](https://github.com/microsoft/vcpkg/pull/11250) [capstone] Update to 4.0.2

- nuspell `3.1.0` -> `3.1.1`
    - [(#11291)](https://github.com/microsoft/vcpkg/pull/11291) [nuspell] update port to v3.1.1

- zydis `3.1.0` -> `3.1.0-1`
    - [(#11173)](https://github.com/microsoft/vcpkg/pull/11173) Update zydis portfile.cmake

- glog `0.4.0-2` -> `0.4.0-3`
    - [(#11288)](https://github.com/microsoft/vcpkg/pull/11288) [glog] Disable tests

- opus `1.3.1-2` -> `1.3.1-3`
    - [(#11279)](https://github.com/microsoft/vcpkg/pull/11279) [opus] Update port to 1.3.1-2

- eigen3 `3.3.7-4` -> `3.3.7-5`
    - [(#11270)](https://github.com/microsoft/vcpkg/pull/11270) [eigen3] [ignition-modularscripts] Fix installed pkgconfig files

- nlopt `2.6.1-1` -> `2.6.2-1`
    - [(#11254)](https://github.com/microsoft/vcpkg/pull/11254) [nlopt] Update to 2.6.2
    - [(#11398)](https://github.com/microsoft/vcpkg/pull/11398) [nlopt] Enable UWP support

- string-theory `3.1` -> `3.2`
    - [(#11310)](https://github.com/microsoft/vcpkg/pull/11310) [string-theory] Update to 3.2

- miniz `2.1.0` -> `2.1.0-1`
    - [(#11316)](https://github.com/microsoft/vcpkg/pull/11316) [miniz] Fix broken cmake config file

- z3 `4.8.6` -> `4.8.8`
    - [(#11314)](https://github.com/microsoft/vcpkg/pull/11314) [z3] update port to 4.8.8

- jsoncons `0.150.0` -> `0.153.0`
    - [(#11311)](https://github.com/microsoft/vcpkg/pull/11311) [jsoncons] Update to v0.151.0
    - [(#11505)](https://github.com/microsoft/vcpkg/pull/11505) [jsoncons] Update to v0.152.0
    - [(#11699)](https://github.com/microsoft/vcpkg/pull/11699) [jsoncons] Update to v0.153.0

- units `2.3.0` -> `2.3.1`
    - [(#11308)](https://github.com/microsoft/vcpkg/pull/11308) [units] Update to 2.3.1

- boost-accumulators `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-algorithm `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-align `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-any `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-array `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-asio `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-assert `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-assign `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-atomic `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-beast `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-bimap `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-bind `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-build `1.72.0` -> `1.73.0-1`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0
    - [(#11427)](https://github.com/microsoft/vcpkg/pull/11427) [boost] MinGW build fixes

- boost-callable-traits `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-chrono `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-circular-buffer `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-compatibility `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-compute `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-concept-check `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-config `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-container-hash `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-container `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-context `1.72.0` -> `1.73.0-1`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0
    - [(#11692)](https://github.com/microsoft/vcpkg/pull/11692) [vcpkg baseline] Remove passing port from Ci baseline

- boost-contract `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-conversion `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-convert `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-core `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-coroutine2 `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-crc `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-date-time `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-detail `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-dll `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-dynamic-bitset `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-endian `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-exception `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-fiber `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-filesystem `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-flyweight `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-foreach `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-format `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-function-types `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-function `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-functional `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-fusion `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-geometry `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-gil `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-graph-parallel `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- boost-graph `1.72.0` -> `1.73.0`
    - [(#11221)](https://github.com/microsoft/vcpkg/pull/11221) [boost] update to 1.73.0

- sobjectizer `5.7.0` -> `5.7.0.1`
    - [(#11276)](https://github.com/microsoft/vcpkg/pull/11276) [sobjectizer] update to v.5.7.0.1.

- imgui-sfml `2.1` -> `2.1-1`
    - [(#10840)](https://github.com/microsoft/vcpkg/pull/10840) [imgui-sfml] Force imgui-sfml to be a static library

- gdcm `3.0.4` -> `3.0.5`
    - [(#11258)](https://github.com/microsoft/vcpkg/pull/11258) [gdcm] Update to version 3.0.5

- opengl `0.0-5` -> `0.0-6`
    - [(#11294)](https://github.com/microsoft/vcpkg/pull/11294) [OpenGL] Fix lib files copy when VCPKG_BUILD_TYPE is set

- libmysql `8.0.4-7` -> `8.0.20`
    - [(#11303)](https://github.com/microsoft/vcpkg/pull/11303) [libmysql] Update to 8.0.20

- libodb-mysql `2.4.0-6` -> `2.4.0-7`
    - [(#11303)](https://github.com/microsoft/vcpkg/pull/11303) [libmysql] Update to 8.0.20

- ogre-next `2019-10-20` -> `2019-10-20-1`
    - [(#11325)](https://github.com/microsoft/vcpkg/pull/11325) [ogre/ogre-next] Add conflict error message

- ogre `1.12.1` -> `1.12.1-1`
    - [(#11325)](https://github.com/microsoft/vcpkg/pull/11325) [ogre/ogre-next] Add conflict error message

- paho-mqttpp3 `1.0.1-3` -> `1.1`
    - [(#11327)](https://github.com/microsoft/vcpkg/pull/11327) [paho-mqttpp3] update to 1.1

- gsl-lite `0.36.0` -> `0.37.0`
    - [(#11351)](https://github.com/microsoft/vcpkg/pull/11351) [gsl-lite] update to 0.37.0

- restinio `0.6.6` -> `0.6.8`
    - [(#11367)](https://github.com/microsoft/vcpkg/pull/11367) [restinio] update to v.0.6.8

- tiff `4.0.10-8` -> `4.0.10-9`
    - [(#11364)](https://github.com/microsoft/vcpkg/pull/11364) [tiff] Install runtime deps for tiff[tool]

- sqlite3 `3.31.1` -> `3.32.1`
    - [(#11267)](https://github.com/microsoft/vcpkg/pull/11267) [sqlite3] Enable build for android
    - [(#11635)](https://github.com/microsoft/vcpkg/pull/11635) [sqlite3] update to 3.32
    - [(#11716)](https://github.com/microsoft/vcpkg/pull/11716) [sqlite] Updated to 3.32.1 to fix a security vulnerability

- aws-sdk-cpp `1.7.270` -> `1.7.333`
    - [(#11332)](https://github.com/microsoft/vcpkg/pull/11332) [aws-sdk-cpp] Update to 1.7.333

- libxml2 `2.9.9-5` -> `2.9.9-6`
    - [(#11072)](https://github.com/microsoft/vcpkg/pull/11072) [libxml2] Add iconv and charset linkage in vcpkg-cmake-wrapper on osx

- libgo `2.8-2` -> `3.1-1`
    - [(#11263)](https://github.com/microsoft/vcpkg/pull/11263) [libgo] Update to 3.1
    - [(#11435)](https://github.com/microsoft/vcpkg/pull/11435) [libgo] Update CONTROL file for typo

- ixwebsocket `9.1.9` -> `9.6.2`
    - [(#11030)](https://github.com/microsoft/vcpkg/pull/11030) [ixwebsocket] update to 9.6.2

- cpuid `0.4.1` -> `0.4.1-1`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- dmlc `2019-08-12-1` -> `2019-08-12-4`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2
    - [(#11612)](https://github.com/microsoft/vcpkg/pull/11612) [vcpkg baseline] Fix baseline failures
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- libnice `0.1.15-2` -> `0.1.15-3`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- magnum `2019.10-1` -> `2019.10-2`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- mlpack `3.2.2-1` -> `3.2.2-3`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2
    - [(#11785)](https://github.com/microsoft/vcpkg/pull/11785) [mlpack] Explicitly depend on stb

- nanodbc `2.12.4-5` -> `2.12.4-8`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2
    - [(#11613)](https://github.com/microsoft/vcpkg/pull/11613) [vcpkg-baseline][unixodbc/nanodbc] Fix unixodbc build failure and set it as a dependency on nanodbc

- osg `3.6.4-2` -> `3.6.4-3`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2
    - [(#11715)](https://github.com/microsoft/vcpkg/pull/11715) [osg] Fix conflict when asio and boost-asio are installed.

- podofo `0.9.6-7` -> `0.9.6-8`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- replxx `0.0.2` -> `0.0.2-2`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2
    - [(#11571)](https://github.com/microsoft/vcpkg/pull/11571) [replxx] Add missing header <stdexcept> needed to name std::runtime_error for replxx.

- stormlib `2019-05-10` -> `2019-05-10-1`
    - [(#10767)](https://github.com/microsoft/vcpkg/pull/10767) [cmake] Update to 3.17.2

- parallelstl `20191218` -> `20200330`
    - [(#11379)](https://github.com/microsoft/vcpkg/pull/11379) [parallelstl] update to 20200330

- angle `2019-12-31-2` -> `2020-05-15`
    - [(#11394)](https://github.com/microsoft/vcpkg/pull/11394) [angle] update for gcc 10 compatibility

- parallel-hashmap `1.30` -> `1.32`
    - [(#11420)](https://github.com/microsoft/vcpkg/pull/11420) [parallel-hashmap] Update parallel-hashmap version

- utfcpp `3.1` -> `3.1.1`
    - [(#11426)](https://github.com/microsoft/vcpkg/pull/11426) [utfcpp] Update to 3.1.1

- realsense2 `2.33.1-1` -> `2.34.0`
    - [(#11437)](https://github.com/microsoft/vcpkg/pull/11437) [realsense2] Update to 2.34.0

- grpc `1.27.3` -> `1.28.1-1`
    - [(#11449)](https://github.com/microsoft/vcpkg/pull/11449) [grpc] upgrade to 1.28.1
    - [(#10307)](https://github.com/microsoft/vcpkg/pull/10307) [grpc] Add feature absl-sync

- skia `2020-02-15-1` -> `2020-05-18-1`
    - [(#11416)](https://github.com/microsoft/vcpkg/pull/11416) [harfbuzz,skia] Update and replace Skia dependencies with vcpkg

- fribidi `1.0.9` -> `1.0.9-1`
    - [(#11380)](https://github.com/microsoft/vcpkg/pull/11380) [tool-meson] Update to 0.54.2

- libepoxy `1.5.3-3` -> `1.5.4`
    - [(#11380)](https://github.com/microsoft/vcpkg/pull/11380) [tool-meson] Update to 0.54.2
    - [(#11448)](https://github.com/microsoft/vcpkg/pull/11448) [libepoxy] Update to 1.5.4

- tool-meson `0.53.2` -> `0.54.2`
    - [(#11380)](https://github.com/microsoft/vcpkg/pull/11380) [tool-meson] Update to 0.54.2

- monkeys-audio `5.24` -> `5.38`
    - [(#11444)](https://github.com/microsoft/vcpkg/pull/11444) [monkeys-audio] Update to 5.38

- clapack `3.2.1-12` -> `3.2.1-13`
    - [(#9957)](https://github.com/microsoft/vcpkg/pull/9957) [clapack] Add uwp support

- fcl `0.6.0` -> `0.6.0-1`
    - [(#11406)](https://github.com/microsoft/vcpkg/pull/11406) [fcl] Explicity handle FCL_USE_X64_SSE CMake option

- farmhash `1.1` -> `1.1-1`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- freexl `1.0.4-8` -> `1.0.4-9`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- healpix `1.12.10` -> `1.12.10-1`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libb2 `0.98.1` -> `0.98.1-2`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds
    - [(#11692)](https://github.com/microsoft/vcpkg/pull/11692) [vcpkg baseline] Remove passing port from Ci baseline

- libcrafter `0.3` -> `0.3-1`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libmagic `5.37` -> `5.37-1`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libmesh `1.5.0` -> `1.5.0-1`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libosip2 `5.1.0-3` -> `5.1.0-4`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libudns `0.4-1` -> `0.4-2`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libwandio `4.2.1` -> `4.2.1-2`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libxslt `1.1.33-6` -> `1.1.33-7`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- pfring `2019-10-17-1` -> `2019-10-17-2`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- sdl1 `1.2.15-10` -> `1.2.15-11`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- tcl `8.6.10-3` -> `core-9-0-a1`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- x264 `157-303c484ec828ed0-7` -> `157-303c484ec828ed0-8`
    - [(#10402)](https://github.com/microsoft/vcpkg/pull/10402) [vcpkg] Improve make builds

- libflac `1.3.3` -> `1.3.3-1`
    - [(#11152)](https://github.com/microsoft/vcpkg/pull/11152) [libflac] Update to 1.3.3-1

- libsndfile `1.0.29-8` -> `1.0.29-9`
    - [(#11152)](https://github.com/microsoft/vcpkg/pull/11152) [libflac] Update to 1.3.3-1

- octomap `2017-03-11-7` -> `2017-03-11-8`
    - [(#11408)](https://github.com/microsoft/vcpkg/pull/11408) [octomap] Cleanup

- freeglut `3.0.0-9` -> `3.2.1-1`
    - [(#11423)](https://github.com/microsoft/vcpkg/pull/11423) [freeglut] updated to 3.2.1
    - [(#11527)](https://github.com/microsoft/vcpkg/pull/11527) [freeglut] fix debug macro patch

- libpqxx `6.4.5-2` -> `6.4.5-3`
    - [(#11442)](https://github.com/microsoft/vcpkg/pull/11442) [libpqxx] linux support

- marl `2019-09-13` -> `2020-05-21`
    - [(#11465)](https://github.com/microsoft/vcpkg/pull/11465) [marl] Update to 2020-05-20

- python3 `3.7.3-2` -> `3.8.3`
    - [(#11489)](https://github.com/microsoft/vcpkg/pull/11489) [python3] Fix dynamic build error on Linux
    - [(#11708)](https://github.com/microsoft/vcpkg/pull/11708) [python3] Update to Python 3.8

- azure-storage-cpp `7.3.0` -> `7.4.0`
    - [(#11510)](https://github.com/microsoft/vcpkg/pull/11510) [azure-storage-cpp] Upgrade to 7.4.0

- entt `3.3.2` -> `3.4.0`
    - [(#11509)](https://github.com/microsoft/vcpkg/pull/11509) [entt] Update to 3.4.0 (#11507)

- wil `2019-11-07` -> `2020-05-19`
    - [(#11506)](https://github.com/microsoft/vcpkg/pull/11506) [wil] Update to 2020-05-19

- signalrclient `1.0.0-beta1-8` -> `1.0.0-beta1-9`
    - [(#11496)](https://github.com/microsoft/vcpkg/pull/11496) [Baseline] Fix boost-*:arm-uwp failure and resolve conflicts in CI

- bond `8.1.0-3` -> `9.0.0`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports
    - [(#11628)](https://github.com/microsoft/vcpkg/pull/11628) [bond] Update to 9.0.0
    - [(#10319)](https://github.com/microsoft/vcpkg/pull/10319) [bond] updated version + added bond-over-grpc integration as feature

- ccfits `2.5-4` -> `2.5-5`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports

- geographiclib `1.47-patch1-10` -> `1.47-patch1-12`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- libaiff `5.0-2` -> `5.0-3`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports

- ois `1.5` -> `1.5-1`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports

- wtl `10.0-4` -> `10.0-5`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports

- xmsh `0.5.2` -> `0.5.2-1`
    - [(#11559)](https://github.com/microsoft/vcpkg/pull/11559) [VCPKG baseline] Fix many ports

- xmlsec `1.2.29-2` -> `1.2.30`
    - [(#11595)](https://github.com/microsoft/vcpkg/pull/11595) [Xmlsec] Update to 1.2.30

- activemq-cpp `3.9.5-1` -> `3.9.5-2`
    - [(#11589)](https://github.com/microsoft/vcpkg/pull/11589) [libusbmuxd berkeleydb cppcms activemq-cpp] Add Supports and failure message

- berkeleydb `4.8.30-3` -> `4.8.30-4`
    - [(#11589)](https://github.com/microsoft/vcpkg/pull/11589) [libusbmuxd berkeleydb cppcms activemq-cpp] Add Supports and failure message

- cppcms `1.2.1` -> `1.2.1-1`
    - [(#11589)](https://github.com/microsoft/vcpkg/pull/11589) [libusbmuxd berkeleydb cppcms activemq-cpp] Add Supports and failure message

- libusbmuxd `1.2.185` -> `1.2.185-1`
    - [(#11589)](https://github.com/microsoft/vcpkg/pull/11589) [libusbmuxd berkeleydb cppcms activemq-cpp] Add Supports and failure message

- seal `3.4.5` -> `3.4.5-1`
    - [(#11588)](https://github.com/microsoft/vcpkg/pull/11588) [seal] Disable SEAL_USE_MSGSL and add default feature zlib

- magic-get `2019-09-02` -> `2019-09-02-1`
    - [(#11581)](https://github.com/microsoft/vcpkg/pull/11581) [magic-get] Fix improper direct reference to the "downloads" directory

- lpeg `1.0.1-4` -> `1.0.2-1`
    - [(#11554)](https://github.com/microsoft/vcpkg/pull/11554) [luafilesystem][lpeg] Bump versions

- luafilesystem `1.7.0.2-1` -> `1.8.0-1`
    - [(#11554)](https://github.com/microsoft/vcpkg/pull/11554) [luafilesystem][lpeg] Bump versions

- scnlib `0.1.2` -> `0.3`
    - [(#11540)](https://github.com/microsoft/vcpkg/pull/11540) [scnlib] Update to version 0.3

- cppgraphqlgen `3.2.1` -> `3.2.2`
    - [(#11531)](https://github.com/microsoft/vcpkg/pull/11531) [pegtl/cppgraphqlgen] matching updates for dependency

- protobuf-c `1.3.2` -> `1.3.2-2`
    - [(#11517)](https://github.com/microsoft/vcpkg/pull/11517) [protobuf-c] Fix tool protoc-gen-c crash
    - [(#11609)](https://github.com/microsoft/vcpkg/pull/11609) [protobuf-c] Fix wrong dependency for feature test

- basisu `1.11-3` -> `1.11-4`
    - [(#11494)](https://github.com/microsoft/vcpkg/pull/11494) [basisu, gppanel, msgpack11, nana, rapidcheck, folly] Add missing header file of STL

- folly `2019.10.21.00-1` -> `2019.10.21.00-2`
    - [(#11494)](https://github.com/microsoft/vcpkg/pull/11494) [basisu, gppanel, msgpack11, nana, rapidcheck, folly] Add missing header file of STL

- gppanel `2018-04-06` -> `2020-05-20`
    - [(#11494)](https://github.com/microsoft/vcpkg/pull/11494) [basisu, gppanel, msgpack11, nana, rapidcheck, folly] Add missing header file of STL

- msgpack11 `0.0.10` -> `0.0.10-1`
    - [(#11494)](https://github.com/microsoft/vcpkg/pull/11494) [basisu, gppanel, msgpack11, nana, rapidcheck, folly] Add missing header file of STL

- rapidcheck `2018-11-05-1` -> `2018-11-05-2`
    - [(#11494)](https://github.com/microsoft/vcpkg/pull/11494) [basisu, gppanel, msgpack11, nana, rapidcheck, folly] Add missing header file of STL

- simdjson `2019-12-27` -> `2020-05-26`
    - [(#11495)](https://github.com/microsoft/vcpkg/pull/11495) [simdjson] Fix error LNK2001 when compile with /fsanitize=address in MSVC
    - [(#10709)](https://github.com/microsoft/vcpkg/pull/10709) [simdjson] Update to 0.3.1

- ponder `3.0.0` -> `3.0.0-1`
    - [(#11582)](https://github.com/microsoft/vcpkg/pull/11582) [ponder] patch missing headers for Visual Studio 2019 16.6

- telnetpp `2.0-3` -> `2.0-4`
    - [(#11573)](https://github.com/microsoft/vcpkg/pull/11573) [telnetpp] Add missing <ostream> for Visual Studio 2019 16.6

- libpopt `1.16-12` -> `1.16-13`
    - [(#11607)](https://github.com/microsoft/vcpkg/pull/11607) [libpopt] Remove invalid URL

- cpputest `2019-9-16` -> `2019-9-16-1`
    - [(#11585)](https://github.com/microsoft/vcpkg/pull/11585) [cpputest] Move library to manual-link

- unixodbc `2.3.7` -> `2.3.7-1`
    - [(#11613)](https://github.com/microsoft/vcpkg/pull/11613) [vcpkg-baseline][unixodbc/nanodbc] Fix unixodbc build failure and set it as a dependency on nanodbc

- nghttp2 `1.39.2-1` -> `1.39.2-2`
    - [(#11638)](https://github.com/microsoft/vcpkg/pull/11638) [nghttp2] Fix to build nghttp2 statically

- gli `dd17acf` -> `dd17acf-1`
    - [(#11634)](https://github.com/microsoft/vcpkg/pull/11634) [gli] Add CMake config support

- mimalloc `1.6.1` -> `1.6.1-1`
    - [(#11632)](https://github.com/microsoft/vcpkg/pull/11632) [mimalloc] Install mimalloc-redirect.dll to CMAKE_INSTALL_BINDIR

- quickfix `1.15.1-3` -> `1.15.1-4`
    - [(#11604)](https://github.com/microsoft/vcpkg/pull/11604) [vcpkg-baseline][quickfix] Fix build failure on arm64-windows

- zxing-cpp `3.3.3-6` -> `3.3.3-7`
    - [(#11586)](https://github.com/microsoft/vcpkg/pull/11586) [vcpkg-baseline][zxing-cpp] Fix build failure

- ppconsul `0.5` -> `0.5-1`
    - [(#11692)](https://github.com/microsoft/vcpkg/pull/11692) [vcpkg baseline] Remove passing port from Ci baseline

- proj4 `6.3.1` -> `6.3.1-1`
    - [(#11692)](https://github.com/microsoft/vcpkg/pull/11692) [vcpkg baseline] Remove passing port from Ci baseline
    - [(#11086)](https://github.com/microsoft/vcpkg/pull/11086) [PROJ4] Add search path for sqlite.exe

- jwt-cpp `2019-05-07-1` -> `0.4.0`
    - [(#11625)](https://github.com/microsoft/vcpkg/pull/11625) [jwt-cpp] Update to v0.4.0

- polyhook2 `2020-02-17` -> `2020-06-02`
    - [(#11561)](https://github.com/microsoft/vcpkg/pull/11561) [polyhook2] Update to 2020-05-25
    - [(#11729)](https://github.com/microsoft/vcpkg/pull/11729) [polyhook2] Update polyhook to latest

- gdk-pixbuf `2.36.9-4` -> `2.36.9-5`
    - [(#11721)](https://github.com/microsoft/vcpkg/pull/11721) [gdk-pixbuf] GdkPixbuf fix for building on macOS

- yaml-cpp `0.6.2-3` -> `0.6.3`
    - [(#11718)](https://github.com/microsoft/vcpkg/pull/11718) [yaml-cpp] Update to 0.6.3 and also fix headers cannot be found

- fmt `6.2.0` -> `6.2.1`
    - [(#11706)](https://github.com/microsoft/vcpkg/pull/11706) [fmt] add vcpkg_fixup_pkgconfig
    - [(#11789)](https://github.com/microsoft/vcpkg/pull/11789) [fmt] Update to 6.2.1

- magic-enum `0.6.4` -> `0.6.6`
    - [(#11704)](https://github.com/microsoft/vcpkg/pull/11704) [magic-enum] Update to v0.6.5
    - [(#11814)](https://github.com/microsoft/vcpkg/pull/11814) [magic-enum] Update to v0.6.6

- enet `1.3.13-1` -> `1.3.15`
    - [(#11702)](https://github.com/microsoft/vcpkg/pull/11702) [enet] Update to 1.3.15

- libfabric `1.8.1` -> `1.8.1-1`
    - [(#11647)](https://github.com/microsoft/vcpkg/pull/11647) [vcpkg baseline][libfabric] Only support dynamic build

- google-cloud-cpp-common `0.25.0` -> `alias`
    - [(#11698)](https://github.com/microsoft/vcpkg/pull/11698) [google-cloud-cpp] Consolidate all google-cloud* packages

- google-cloud-cpp-spanner `1.1.0` -> `alias`
    - [(#11698)](https://github.com/microsoft/vcpkg/pull/11698) [google-cloud-cpp] Consolidate all google-cloud* packages

- google-cloud-cpp `0.21.0` -> `1.14.0`
    - [(#11698)](https://github.com/microsoft/vcpkg/pull/11698) [google-cloud-cpp] Consolidate all google-cloud* packages

- amqpcpp `4.1.5` -> `4.1.7`
    - [(#11608)](https://github.com/microsoft/vcpkg/pull/11608) [amqpcpp] Update to 4.1.7

- shiva-sfml `1.0` -> `1.0-1`
    - [(#11483)](https://github.com/microsoft/vcpkg/pull/11483) [vcpkg] Allow CI to pass in all relevant directories and remove use of symbolic links

- spirv-tools `2020.1` -> `2020.1-1`
    - [(#11483)](https://github.com/microsoft/vcpkg/pull/11483) [vcpkg] Allow CI to pass in all relevant directories and remove use of symbolic links

- cpp-taskflow `2.2.0` -> `2.2.0-1`
    - [(#11742)](https://github.com/microsoft/vcpkg/pull/11742) [vcpkg-baseline][manyport] Fix baseline error

- eabase `2.09.12` -> `2.09.12-1`
    - [(#11742)](https://github.com/microsoft/vcpkg/pull/11742) [vcpkg-baseline][manyport] Fix baseline error

- fastrtps `1.5.0-2` -> `1.5.0-3`
    - [(#11742)](https://github.com/microsoft/vcpkg/pull/11742) [vcpkg-baseline][manyport] Fix baseline error

- librsvg `2.40.20` -> `2.40.20-2`
    - [(#11722)](https://github.com/microsoft/vcpkg/pull/11722) [librsvg] Fix for macOS
    - [(#11865)](https://github.com/microsoft/vcpkg/pull/11865) [vcpkg baseline] Fix baseline

- mozjpeg `3.2-3` -> `2020-06-02`
    - [(#11719)](https://github.com/microsoft/vcpkg/pull/11719) [mozjpeg] Update to latest commit

- pcre `8.44` -> `8.44-1`
    - [(#11564)](https://github.com/microsoft/vcpkg/pull/11564) [pcre] Add pkgconfig files

- tensorflow-cc `1.14-1` -> `1.14-2`
    - [(#11839)](https://github.com/microsoft/vcpkg/pull/11839) [vcpkg] Fix OSX CI by ensuring the downloads directory exists

- sqlpp11-connector-mysql `0.29` -> `0.29-1`
    - [(#11771)](https://github.com/microsoft/vcpkg/pull/11771) [sqlpp11] update to v0.59

- sqlpp11 `0.58-3` -> `0.59`
    - [(#11771)](https://github.com/microsoft/vcpkg/pull/11771) [sqlpp11] update to v0.59

- unicorn-lib `2019-07-11` -> `2020-03-02`
    - [(#11830)](https://github.com/microsoft/vcpkg/pull/11830) [unicorn-lib] Update to 01cc7fc (2020-03-02)

- sol2 `3.2.0` -> `3.2.1`
    - [(#11826)](https://github.com/microsoft/vcpkg/pull/11826) [sol] Update to version 3.2.1

- avisynthplus `3.5.0` -> `3.6.0`
    - [(#11736)](https://github.com/microsoft/vcpkg/pull/11736) [avisynthplus] Upgrade to 3.6.0

- plibsys `0.0.4-2` -> `0.0.4-3`
    - [(#11633)](https://github.com/microsoft/vcpkg/pull/11633) [plibsys] Fix failures on linux and osx

- libxmp-lite `4.4.1-2` -> `4.4.1-3`
    - [(#11865)](https://github.com/microsoft/vcpkg/pull/11865) [vcpkg baseline] Fix baseline

- msix `1.7` -> `1.7-2`
    - [(#11865)](https://github.com/microsoft/vcpkg/pull/11865) [vcpkg baseline] Fix baseline
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- usd `20.02` -> `20.02-1`
    - [(#11440)](https://github.com/microsoft/vcpkg/pull/11440) [usd] Fix build error on Linux

- cryptopp `8.2.0-1` -> `8.2.0-2`
    - [(#11711)](https://github.com/microsoft/vcpkg/pull/11711) [licensepp] Add new port

- libpcap `1.9.1` -> `1.9.1-2`
    - [(#9426)](https://github.com/microsoft/vcpkg/pull/9426) [libpcap] Fix pkgconfig libs and include path
    - [(#10731)](https://github.com/microsoft/vcpkg/pull/10731) [libpcap] Enable compilation of libpcap port on x86-windows and x64-windows

- ms-angle `2018-04-18-2` -> `alias`
    - [(#11458)](https://github.com/microsoft/vcpkg/pull/11458) [ms-angle] Set ms-angle to empty package

- libgit2 `1.0.0` -> `1.0.1`
    - [(#11844)](https://github.com/microsoft/vcpkg/pull/11844) [libgit2] Update to 1.0.1

- uwebsockets `0.17.2` -> `18.1.0`
    - [(#11866)](https://github.com/microsoft/vcpkg/pull/11866) [uWbSockets] Update to 18.1.0

- nameof `0.9.3` -> `0.9.4`
    - [(#11815)](https://github.com/microsoft/vcpkg/pull/11815) [nameof] Update to 0.9.4

- cairo `1.16.0-3` -> `1.16.0-4`
    - [(#11868)](https://github.com/microsoft/vcpkg/pull/11868) [cairo] Install the xlib header file when selecting feature x11

- directxmesh `dec2019-1` -> `jun2020`
    - [(#11794)](https://github.com/microsoft/vcpkg/pull/11794) [directxtk][directxtk12][directxtex][directxmesh] Update to latest version

- directxtex `dec2019` -> `jun2020`
    - [(#11794)](https://github.com/microsoft/vcpkg/pull/11794) [directxtk][directxtk12][directxtex][directxmesh] Update to latest version

- directxtk `2019-12-31` -> `jun2020`
    - [(#11794)](https://github.com/microsoft/vcpkg/pull/11794) [directxtk][directxtk12][directxtex][directxmesh] Update to latest version

- directxtk12 `dec2019` -> `jun2020`
    - [(#11794)](https://github.com/microsoft/vcpkg/pull/11794) [directxtk][directxtk12][directxtex][directxmesh] Update to latest version

- spdlog `1.4.2-1` -> `1.6.1`
    - [(#11793)](https://github.com/microsoft/vcpkg/pull/11793) [spdlog] Update to 1.61

- msmpi `10.0-2` -> `10.1`
    - [(#11365)](https://github.com/microsoft/vcpkg/pull/11365) [vcpkg] [cudnn] [msmpi] [openmpi] Update VMSS

- openmpi `4.0.1` -> `4.0.3`
    - [(#11365)](https://github.com/microsoft/vcpkg/pull/11365) [vcpkg] [cudnn] [msmpi] [openmpi] Update VMSS

- sdl2 `2.0.12` -> `2.0.12-1`
    - [(#11365)](https://github.com/microsoft/vcpkg/pull/11365) [vcpkg] [cudnn] [msmpi] [openmpi] Update VMSS

- gtk `3.22.19-3` -> `3.22.19-4`
    - [(#11892)](https://github.com/microsoft/vcpkg/pull/11892) [gtk] DISABLE_PARALLEL_CONFIGURE

- xalan-c `1.11-11` -> `1.11-12`
    - [(#11869)](https://github.com/microsoft/vcpkg/pull/11869) [xalan-c] Fix import Xalan.exe

- libuuid `1.0.3-3` -> `1.0.3-4`
    - [(#11849)](https://github.com/microsoft/vcpkg/pull/11849) [libuuid] Install uuid.pc file

- lastools `2019-07-10` -> `2020-05-09`
    - [(#11796)](https://github.com/microsoft/vcpkg/pull/11796) [LAStools] Update to 200509

- libpmemobj-cpp `1.8` -> `1.10`
    - [(#11738)](https://github.com/microsoft/vcpkg/pull/11738) [libpmemobj-cpp] Update to 1.10

- librabbitmq `0.10.0` -> `2020-06-03`
    - [(#11733)](https://github.com/microsoft/vcpkg/pull/11733) [librabbitmq] Update to use rabbitmq-config.cmake

- hyperscan `5.2.1` -> `5.2.1-1`
    - [(#11708)](https://github.com/microsoft/vcpkg/pull/11708) [python3] Update to Python 3.8

- tinyxml2 `7.1.0` -> `8.0.0`
    - [(#11616)](https://github.com/microsoft/vcpkg/pull/11616) [tinyxml2] Update to 8.0.0; avoid exporting symbols when building static libraries

- winpcap `4.1.3-2` -> `4.1.3-3`
    - [(#10731)](https://github.com/microsoft/vcpkg/pull/10731) [libpcap] Enable compilation of libpcap port on x86-windows and x64-windows

- ccd `2.1-3` -> `2.1-4`
    - [(#11407)](https://github.com/microsoft/vcpkg/pull/11407) [ccd] Add emscripten support

- itpp `4.3.1-1` -> `4.3.1-2`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- plplot `5.13.0-4` -> `5.13.0-5`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- pthreads `3.0.0-4` -> `3.0.0-5`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- qwt `6.1.3-10` -> `6.1.3-11`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- soundtouch `2.0.0-4` -> `2.0.0-6`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- tclap `1.2.2-1` -> `1.2.2-2`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- tinyfiledialogs `3.4.3-1` -> `3.4.3-2`
    - [(#11896)](https://github.com/microsoft/vcpkg/pull/11896) [vcpkg baseline] Fix baseline error

- mpir `3.0.0-7` -> `3.0.0-8`
    - [(#9205)](https://github.com/microsoft/vcpkg/pull/9205) [mpir] Add mpirxx.lib

- fftw3 `3.3.8-6` -> `3.3.8-7`
    - [(#4361)](https://github.com/microsoft/vcpkg/pull/4361) Adds vcpkg item to project settings in Visual Studio

</details>

-- vcpkg team vcpkg@microsoft.com MON, 16 June 1400:00 -0700

vcpkg (2020.04.01 - 2020.04.20)
---
#### Total port count: 1322

#### Total port count per triplet (tested): 
|triplet|ports available|
|---|---|
|**x64-windows**|1218|
|x86-windows|1202|
|x64-windows-static|1130|
|**x64-linux**|1104|
|**x64-osx**|1041|
|arm64-windows|842|
|x64-uwp|654|
|arm-uwp|625|

#### The following documentation has been updated:
- [vcpkg_from_git](docs/maintainers/vcpkg_from_git.md)
    - [(#9446)](https://github.com/microsoft/vcpkg/pull/9446) vcpkg_from_git: Add support for git over ssh (by @marcrambo)
- [Exporting to Android Archives (AAR files)](docs/specifications/prefab.md) ***[NEW]***
    - [(#10271)](https://github.com/microsoft/vcpkg/pull/10271) Android Support: Exporting to Android Archive (AAR) (by @atkawa7)
- [Triplets](docs/users/triplets.md)
    - [(#6275)](https://github.com/microsoft/vcpkg/pull/6275) Add initial iOS support (by @alcroito)

#### The following *remarkable* changes have been made to vcpkg:
- [(#9446)](https://github.com/microsoft/vcpkg/pull/9446) vcpkg_from_git: Add support for git over ssh (by @marcrambo)
- [(#10271)](https://github.com/microsoft/vcpkg/pull/10271) Android Support: Exporting to Android Archive (AAR) (by @atkawa7)
- [(#10395)](https://github.com/microsoft/vcpkg/pull/10395) [vcpkg] Make configure meson sane and work for all targets.  (by @Neumann-A)
- [(#10398)](https://github.com/microsoft/vcpkg/pull/10398) [vcpkg] New policy: SKIP_ARCHITECTURE_CHECK. (by @Neumann-A)
- [(#6275)](https://github.com/microsoft/vcpkg/pull/6275) Add initial iOS support (by @alcroito)
- [(#10817)](https://github.com/microsoft/vcpkg/pull/10817) [vcpkg] Add x-set-installed command (by @strega-nil)
- [(#10521)](https://github.com/microsoft/vcpkg/pull/10521) [vcpkg] Add initial JSON support (by @strega-nil)

#### The following *additional* changes have been made to vcpkg:
- [(#10637)](https://github.com/microsoft/vcpkg/pull/10637) [vcpkg baseline] Ignore osg-qt (by @PhoebeHui)
- [(#10660)](https://github.com/microsoft/vcpkg/pull/10660) [vcpkg] Fix spec instance name (by @PhoebeHui)
- [(#10703)](https://github.com/microsoft/vcpkg/pull/10703) [vcpkg baseline] Remove replxx:x86-windows=fail (by @strega-nil)
- [(#10655)](https://github.com/microsoft/vcpkg/pull/10655) [vcpkg] Fix nuget/aria2/ninja version/filename inconsistent (by @LilyWangL)
- [(#10583)](https://github.com/microsoft/vcpkg/pull/10583) [vcpkg] Correct UInt128 code 😇 (by @strega-nil)
- [(#10543)](https://github.com/microsoft/vcpkg/pull/10543) [vcpkg-test] Fix the check for ability to make symlinks (by @strega-nil)
- [(#10621)](https://github.com/microsoft/vcpkg/pull/10621) [vcpkg] fix vcpkg_find_acquire_program for scripts (by @Neumann-A)
- [(#10834)](https://github.com/microsoft/vcpkg/pull/10834) [vcpkg] Clean up CMake build system (by @strega-nil)
- [(#10846)](https://github.com/microsoft/vcpkg/pull/10846) [vcpkg] Fix bootstrap from out of directory (by @strega-nil)
- [(#10796)](https://github.com/microsoft/vcpkg/pull/10796) [Ninja] Update to 1.10 (by @Voskrese)
- [(#10867)](https://github.com/microsoft/vcpkg/pull/10867) [vcpkg] Fix build scripts on openSUSE and g++9 (by @strega-nil)

<details>
<summary><b>The following 5 ports have been added:</b></summary>

|port|version|
|---|---|
|[skyr-url](https://github.com/microsoft/vcpkg/pull/10463)<sup>[#10694](https://github.com/microsoft/vcpkg/pull/10694) </sup>| 1.5.1
|[boringssl](https://github.com/microsoft/vcpkg/pull/8455)| 2020-04-07
|[quadtree](https://github.com/microsoft/vcpkg/pull/10787)| 2020-04-13
|[avisynthplus](https://github.com/microsoft/vcpkg/pull/10496)| 3.5.0
|[c4core](https://github.com/microsoft/vcpkg/pull/10791)| 2020-04-12
</details>

<details>
<summary><b>The following 69 ports have been updated:</b></summary>

- cub `1.8.0` -> `1.8.0-1`
    - [(#10660)](https://github.com/microsoft/vcpkg/pull/10660) [vcpkg] Fix spec instance name

- vulkan-hpp `2019-05-11` -> `2019-05-11-1`
    - [(#10660)](https://github.com/microsoft/vcpkg/pull/10660) [vcpkg] Fix spec instance name

- function2 `4.0.0` -> `4.1.0`
    - [(#10666)](https://github.com/microsoft/vcpkg/pull/10666) [function2] Update to version 4.1.0

- libwebsockets `3.2.2-1` -> `4.0.1-1`
    - [(#10658)](https://github.com/microsoft/vcpkg/pull/10658) [libwebsockets] Update to 4.0.1
    - [(#10636)](https://github.com/microsoft/vcpkg/pull/10636) [mosquitto] Add support for static build

- googleapis `0.6.0` -> `0.8.0`
    - [(#10651)](https://github.com/microsoft/vcpkg/pull/10651) [googleapis] upgrade to v0.7.0 release
    - [(#10885)](https://github.com/microsoft/vcpkg/pull/10885) [googleapis] Update to v0.8.0

- ixwebsocket `8.0.5` -> `9.1.9`
    - [(#10633)](https://github.com/microsoft/vcpkg/pull/10633) [ixwebsocket] Update to 9.1.9

- opus `1.3.1` -> `1.3.1-2`
    - [(#10634)](https://github.com/microsoft/vcpkg/pull/10634) [opus] Make AVX an optional feature

- freerdp `2.0.0-rc4-6` -> `2.0.0-rc4-7`
    - [(#10630)](https://github.com/microsoft/vcpkg/pull/10630) [freerdp] Fix include paths and output

- openvr `1.9.16` -> `1.10.30`
    - [(#10629)](https://github.com/microsoft/vcpkg/pull/10629) [openvr] Added Linux support and updated to v1.10.30

- abseil `2020-03-03-1` -> `2020-03-03-3`
    - [(#10620)](https://github.com/microsoft/vcpkg/pull/10620) [abseil] Fix feature name error
    - [(#10721)](https://github.com/microsoft/vcpkg/pull/10721) [abseil] Fix CompressedTuple move constructor on MSVC

- reproc `11.0.1` -> `12.0.0`
    - [(#10594)](https://github.com/microsoft/vcpkg/pull/10594) [reproc] Update to version 12.0.0

- hunspell `1.7.0` -> `1.7.0-1`
    - [(#10574)](https://github.com/microsoft/vcpkg/pull/10574) [hunspell] Disable build tools in non-Windows

- sciter `4.4.0.7` -> `4.4.1.5`
    - [(#10071)](https://github.com/microsoft/vcpkg/pull/10071) [sciter] Update to 4.4.1.5

- qt5-base `5.12.5-11` -> `5.12.5-13`
    - [(#10641)](https://github.com/microsoft/vcpkg/pull/10641) [qt5-base] Fix EGL absolute path on Linux
    - [(#10746)](https://github.com/microsoft/vcpkg/pull/10746) [qt5] fix some remaining absolute paths.
    - [(#9705)](https://github.com/microsoft/vcpkg/pull/9705) [qt5-base, qt5-imageformat] fix issues on osx 

- nana `1.7.2` -> `1.7.2-1`
    - [(#10605)](https://github.com/microsoft/vcpkg/pull/10605) [nana] Add Xorg dependency libxcursor-dev and modify deprecated functions

- blend2d `beta_2019-12-27` -> `beta_2020-04-15`
    - [(#10600)](https://github.com/microsoft/vcpkg/pull/10600) [blend2d] Update to beta_2020-03-29
    - [(#10844)](https://github.com/microsoft/vcpkg/pull/10844) [blend2d] Update to beta_2020-04-15

- libffi `3.3` -> `3.3-2`
    - [(#10485)](https://github.com/microsoft/vcpkg/pull/10485) [libffi] Support arm/arm64
    - [(#10469)](https://github.com/microsoft/vcpkg/pull/10469) [libffi] Check return value of execute_process()

- fribidi `2019-02-04-2` -> `2019-02-04-3`
    - [(#10395)](https://github.com/microsoft/vcpkg/pull/10395) [vcpkg] Make configure meson sane and work for all targets. 
    - [(#10713)](https://github.com/microsoft/vcpkg/pull/10713) [fribidi] Updated to v1.0.9

- libepoxy `1.5.3-2` -> `1.5.3-3`
    - [(#10395)](https://github.com/microsoft/vcpkg/pull/10395) [vcpkg] Make configure meson sane and work for all targets. 

- egl-registry `2019-08-08` -> `2020-02-03`
    - [(#9965)](https://github.com/microsoft/vcpkg/pull/9965) [angle] Improve port

- glad `0.1.33` -> `0.1.33-1`
    - [(#9965)](https://github.com/microsoft/vcpkg/pull/9965) [angle] Improve port

- opengl-registry `2019-08-22` -> `2020-02-03`
    - [(#9965)](https://github.com/microsoft/vcpkg/pull/9965) [angle] Improve port

- mpfr `4.0.2-1` -> `4.0.2-2`
    - [(#10035)](https://github.com/microsoft/vcpkg/pull/10035) [mpfr] Add mirror for mpfr at gnu.org

- google-cloud-cpp-common `0.21.0` -> `0.25.0`
    - [(#10680)](https://github.com/microsoft/vcpkg/pull/10680) [google-cloud-cpp*] update to the latest release

- google-cloud-cpp-spanner `0.9.0` -> `1.1.0`
    - [(#10680)](https://github.com/microsoft/vcpkg/pull/10680) [google-cloud-cpp*] update to the latest release

- google-cloud-cpp `0.20.0` -> `0.21.0`
    - [(#10680)](https://github.com/microsoft/vcpkg/pull/10680) [google-cloud-cpp*] update to the latest release

- jsoncons `0.149.0` -> `0.150.0`
    - [(#10688)](https://github.com/microsoft/vcpkg/pull/10688) [jsoncons] update to v0.150.0

- osg-qt `Qt4` -> `Qt4-1`
    - [(#9705)](https://github.com/microsoft/vcpkg/pull/9705) [qt5-base, qt5-imageformat] fix issues on osx 

- qt5-imageformats `5.12.5-2` -> `5.12.5-3`
    - [(#9705)](https://github.com/microsoft/vcpkg/pull/9705) [qt5-base, qt5-imageformat] fix issues on osx 

- libpng `1.6.37-6` -> `1.6.37-7`
    - [(#6275)](https://github.com/microsoft/vcpkg/pull/6275) Add initial iOS support

- pcre2 `10.30-6` -> `10.30-7`
    - [(#6275)](https://github.com/microsoft/vcpkg/pull/6275) Add initial iOS support

- curlpp `2018-06-15-2` -> `2018-06-15-3`
    - [(#10535)](https://github.com/microsoft/vcpkg/pull/10535) [curlpp] Fix target "curlpp" link "ZLIB::ZLIB" error

- avro-c `1.9.2` -> `1.9.2-1`
    - [(#10514)](https://github.com/microsoft/vcpkg/pull/10514) [avro-c] Fix building avro-c in Linux

- nlohmann-fifo-map `2018.05.07` -> `2018.05.07-1`
    - [(#10850)](https://github.com/microsoft/vcpkg/pull/10850) [nlohmann-fifo-map] Fix could not find a package "nlohmann-fifo-map"

- cppitertools `2019-04-14-3` -> `2.0`
    - [(#10848)](https://github.com/microsoft/vcpkg/pull/10848) [cppitertools] Update to version 2.0

- python3 `3.7.3-1` -> `3.7.3-2`
    - [(#10841)](https://github.com/microsoft/vcpkg/pull/10841) [python3] fix build on macOS and linux

- restinio `0.6.5` -> `0.6.6`
    - [(#10813)](https://github.com/microsoft/vcpkg/pull/10813) [restinio] Updated to v.0.6.6

- libgit2 `0.99.0-1` -> `1.0.0`
    - [(#10807)](https://github.com/microsoft/vcpkg/pull/10807) [libgit2] Upgrade to 1.0.0

- zstd `1.4.4` -> `1.4.4-1`
    - [(#10815)](https://github.com/microsoft/vcpkg/pull/10815) [zstd] export zstd-config.cmake

- blosc `1.17.1` -> `1.18.1-1`
    - [(#10816)](https://github.com/microsoft/vcpkg/pull/10816) [blosc] Update to 1.18.1

- freetype `2.10.1-5` -> `2.10.1-6`
    - [(#10835)](https://github.com/microsoft/vcpkg/pull/10835) [Freetype] Actually prevent linking HarfBuzz on POSIX

- gsl `2.4-5` -> `2.6`
    - [(#10758)](https://github.com/microsoft/vcpkg/pull/10758) [gsl] update to 2.6

- physfs `3.0.2-1` -> `3.0.2-2`
    - [(#10781)](https://github.com/microsoft/vcpkg/pull/10781) [physfs] mirror url

- openssl-windows `1.1.1d-1` -> `1.1.1d-2`
    - [(#10743)](https://github.com/microsoft/vcpkg/pull/10743) [openssl-windows] Avoid to install docs for openssl-windows

- coolprop `6.1.0-4` -> `6.1.0-5`
    - [(#10755)](https://github.com/microsoft/vcpkg/pull/10755) [fmt] update to 6.2.0

- fmt `6.1.2` -> `6.2.0`
    - [(#10755)](https://github.com/microsoft/vcpkg/pull/10755) [fmt] update to 6.2.0

- directxmesh `dec2019` -> `dec2019-1`
    - [(#10739)](https://github.com/microsoft/vcpkg/pull/10739) [DirectXMesh] Add support build for DirectX12

- libvorbis `1.3.6-9eadecc-3` -> `1.3.6-4d963fe`
    - [(#10756)](https://github.com/microsoft/vcpkg/pull/10756) [libvorbis] Update to latest commit

- nuspell `3.0.0` -> `3.1.0`
    - [(#10737)](https://github.com/microsoft/vcpkg/pull/10737) [nuspell] update port to v3.1.0

- raylib `2.6.0` -> `3.0.0`
    - [(#10722)](https://github.com/microsoft/vcpkg/pull/10722) [raylib] Update to 3.0.0

- entt `3.3.0` -> `3.3.2`
    - [(#10672)](https://github.com/microsoft/vcpkg/pull/10672) [entt] Update to version 3.3.2

- indicators `1.5` -> `1.7`
    - [(#10685)](https://github.com/microsoft/vcpkg/pull/10685) [indicators] Updated indicators to 1.7

- realsense2 `2.33.1` -> `2.33.1-1`
    - [(#10673)](https://github.com/microsoft/vcpkg/pull/10673) [realsense2] Add tm2 feature for support T265 devices

- flatbuffers `1.11.0-1` -> `1.12.0`
    - [(#10664)](https://github.com/microsoft/vcpkg/pull/10664) [flatbuffers] Update to 1.12.0

- curl `7.68.0-2` -> `7.68.0-3`
    - [(#10659)](https://github.com/microsoft/vcpkg/pull/10659) [curl] Fix cmake configure error 

- ismrmrd `1.4.1` -> `1.4.2`
    - [(#10618)](https://github.com/microsoft/vcpkg/pull/10618) [ismrmrd] updated to version 1.4.2

- mosquitto `1.6.8` -> `1.6.8-1`
    - [(#10636)](https://github.com/microsoft/vcpkg/pull/10636) [mosquitto] Add support for static build

- lz4 `1.9.2` -> `1.9.2-1`
    - [(#10452)](https://github.com/microsoft/vcpkg/pull/10452) [lz4] Fix for building Linux shared libraries

- sdl2 `2.0.10-3` -> `2.0.12`
    - [(#10500)](https://github.com/microsoft/vcpkg/pull/10500) [sdl2] Update to 2.0.12 version

- osg `3.6.4-1` -> `3.6.4-2`
    - [(#10082)](https://github.com/microsoft/vcpkg/pull/10082) [osg] Add feature examples and plugins, fix configure options

- osgearth `2.10.2` -> `2.10.2-1`
    - [(#10082)](https://github.com/microsoft/vcpkg/pull/10082) [osg] Add feature examples and plugins, fix configure options

- ms-gsl `2.1.0` -> `3.0.0`
    - [(#10872)](https://github.com/microsoft/vcpkg/pull/10872) [ms-gsl] Update version to v3.0.0
    - [(#10831)](https://github.com/microsoft/vcpkg/pull/10831) [ms-gsl] Update to v3.0.0

- cppgraphqlgen `3.2.0` -> `3.2.1`
    - [(#10869)](https://github.com/microsoft/vcpkg/pull/10869) [cppgraphqlgen] Update to v3.2.1

- cgal `5.0.2` -> `5.0.2-1`
    - [(#10879)](https://github.com/microsoft/vcpkg/pull/10879) [cgal] Add dependency boost-interval

- arrow `0.16.0` -> `0.17.0`
    - [(#10883)](https://github.com/microsoft/vcpkg/pull/10883) [Arrow] Update to 0.17

- xerces-c `3.2.2-13` -> `3.2.3`
    - [(#10779)](https://github.com/microsoft/vcpkg/pull/10779) [xerces-c] Update to version 3.2.3

- libarchive `3.4.1` -> `3.4.1-1`
    - [(#10769)](https://github.com/microsoft/vcpkg/pull/10769) [libarchive, libuv]Fix static linkage

- libuv `1.34.2` -> `1.34.2-1`
    - [(#10769)](https://github.com/microsoft/vcpkg/pull/10769) [libarchive, libuv]Fix static linkage

- qscintilla `2.10-11` -> `2.11.4-1`
    - [(#10511)](https://github.com/microsoft/vcpkg/pull/10511) [qscintilla] Update to 2.11.4

</details>

-- vcpkg team vcpkg@microsoft.com MON, 20 April 15:00:00 -0700


vcpkg (2020.01.31)
---
#### Total port count: 1295
#### Total port count per triplet (tested): 
|triplet|ports available|
|---|---|
|**x64-windows**|1195|
|x86-windows|1183|
|x64-windows-static|1104|
|**x64-linux**|1054|
|**x64-osx**|970|
|arm64-windows|814|
|x64-uwp|644|
|arm-uwp|615|

#### The following documentation has been updated:
- [Triplets](docs/users/triplets.md)
    - [(#7976)](https://github.com/microsoft/vcpkg/pull/7976) Community Triplets 🤝 (by @vicroms)

#### The following *remarkable* changes have been made to vcpkg's infrastructure:
- Allow untested triplet configurations as "Community Triplets"
    - [(#7976)](https://github.com/microsoft/vcpkg/pull/7976) Community Triplets 🤝 (by @vicroms)
- Add community support for MinGW
  - [(#9137)](https://github.com/microsoft/vcpkg/pull/9137) Add community support for building with MinGW (by @cristianadam)
  - [(#9807)](https://github.com/microsoft/vcpkg/pull/9807) MinGW: Fix vcpkg common definitions (by @cristianadam)
- Allow ARM/ARM64 toolchains to be selected when building x86 targets, also allow ARM64 to target ARM
  - [(#9578)](https://github.com/microsoft/vcpkg/pull/9578) [vcpkg] Mark ARM and x86 on ARM64 and x86 on ARM as supported architectures when searching for toolchains on Windows (by @cbezault)

#### The following *additional* changes have been made to vcpkg's infrastructure:
- [(#9435)](https://github.com/microsoft/vcpkg/pull/9435) Update CI baseline (by @NancyLi1013)
- [(#9494)](https://github.com/microsoft/vcpkg/pull/9494) [charls] Upgrade to 2.1.0 (by @vbaderks)
- [(#9379)](https://github.com/microsoft/vcpkg/pull/9379) [uvatlas] Upgrade to dec2019 (by @AlvinZhangH)
- [(#9529)](https://github.com/microsoft/vcpkg/pull/9529) [box2d] Update to 2019-12-31 (by @PhoebeHui)
- [(#9513)](https://github.com/microsoft/vcpkg/pull/9513) [wpilib] Update to 2020.1.1 (by @ThadHouse)
- [(#9499)](https://github.com/microsoft/vcpkg/pull/9499) [akali] Add new port (by @winsoft666)
- [(#9301)](https://github.com/microsoft/vcpkg/pull/9301) [sdl1] Add build support for ARM64 Windows 10 (by @shibayan)
- [(#9260)](https://github.com/microsoft/vcpkg/pull/9260) [qt5-base] Fix Qt5 linux build and be a bit less flaky in CI (by @Neumann-A)
- [(#9308)](https://github.com/microsoft/vcpkg/pull/9308) [pdal] Fix static build (by @JackBoosY)
- [(#8701)](https://github.com/microsoft/vcpkg/pull/8701) [nethost] Adding a port for nethost (by @tannergooding)
- [(#8650)](https://github.com/microsoft/vcpkg/pull/8650) [libmagic] Add new port (by @NancyLi1013)
- [(#8386)](https://github.com/microsoft/vcpkg/pull/8386) [tfhe] Add new port (by @NancyLi1013)
- [(#8518)](https://github.com/microsoft/vcpkg/pull/8518) [libb2] Add new port (by @NancyLi1013)
- [(#9605)](https://github.com/microsoft/vcpkg/pull/9605) Add December changelog (by @grdowns)
- [(#9566)](https://github.com/microsoft/vcpkg/pull/9566) [vcpkg] Fix a typo (by @MaherJendoubi)
- [(#9207)](https://github.com/microsoft/vcpkg/pull/9207) [sdl1]Change build method to vcpkg_*_make (by @JackBoosY)
- [(#6393)](https://github.com/microsoft/vcpkg/pull/6393) Map MinSizeRel and RelWithDebInfo correctly (by @Neumann-A)
- [(#9458)](https://github.com/microsoft/vcpkg/pull/9458) [azure-kinect-sensor-sdk] Remove feature test and fix static build in Windows (by @JackBoosY)
- [(#8936)](https://github.com/microsoft/vcpkg/pull/8936) [libplist] Update to 1.2.137 (by @PhoebeHui)
- [(#8888)](https://github.com/microsoft/vcpkg/pull/8888) [caf] Update to 0.17.2 (by @JackBoosY)
- [(#8683)](https://github.com/microsoft/vcpkg/pull/8683) [libwandio] Add new port (by @NancyLi1013)
- [(#8678)](https://github.com/microsoft/vcpkg/pull/8678) [libevhtp] Add new port (by @NancyLi1013)
- [(#9600)](https://github.com/microsoft/vcpkg/pull/9600) Update baseline to fix osx failure (by @JackBoosY)
- [(#9669)](https://github.com/microsoft/vcpkg/pull/9669) [vcpkg] Update baseline for OSX (by @ras0219-msft)
- [(#9649)](https://github.com/microsoft/vcpkg/pull/9649) [tfhe] Fix Mac support (by @SeekingMeaning)
- [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d (by @Neumann-A)
- [(#9642)](https://github.com/microsoft/vcpkg/pull/9642) Introduce new policy to skip post verification of dll exports (by @martin-s)
- [(#9602)](https://github.com/microsoft/vcpkg/pull/9602) [vcpkg] Fix build type in vcpkg_build_make.cmake [x264] Modernize (by @NancyLi1013)
- [(#9536)](https://github.com/microsoft/vcpkg/pull/9536) Minor edit to help message for cli depend-info option. Fix for #9534. (by @dbird137)
- [(#9617)](https://github.com/microsoft/vcpkg/pull/9617) [akali] Update to v1.41 (by @winsoft666)
- [(#9572)](https://github.com/microsoft/vcpkg/pull/9572) [soem] Add new port (by @seanyen)
- [(#9574)](https://github.com/microsoft/vcpkg/pull/9574) [doxygen] Updated to 1.8.17 (by @tagsemb)
- [(#9372)](https://github.com/microsoft/vcpkg/pull/9372) [VCPKG] WinHTTPOption for company Proxy not correctly taken into account (by @xabbudm)
- [(#9720)](https://github.com/microsoft/vcpkg/pull/9720) [toolsrc] Added missing @ to FATAL_ERROR message (by @theriverman)
- [(#9555)](https://github.com/microsoft/vcpkg/pull/9555) [embree3] added cleanup command to embree3 port for static build (by @xelatihy)
- [(#9684)](https://github.com/microsoft/vcpkg/pull/9684) [teemo] new port. (by @winsoft666)
- [(#9591)](https://github.com/microsoft/vcpkg/pull/9591) [scintilla] Update to 4.2.3 (by @SeekingMeaning)
- [(#9767)](https://github.com/microsoft/vcpkg/pull/9767) [open62541] Update to v1.0 (by @yurybura)
- [(#9760)](https://github.com/microsoft/vcpkg/pull/9760) [monkeys-audio] Update to 5.14, add feature tools (by @JackBoosY)
- [(#9770)](https://github.com/microsoft/vcpkg/pull/9770) [asmjit] update to current version (by @jsmolka)
- [(#9708)](https://github.com/microsoft/vcpkg/pull/9708) [doxygen] Add alternative download URL (by @c72578)
- [(#9690)](https://github.com/microsoft/vcpkg/pull/9690) [string_theory] Update to 3.0 (by @zrax)
- [(#9680)](https://github.com/microsoft/vcpkg/pull/9680) [jasper] freeglut is not a dependency in macOS (by @david-antiteum)
- [(#9633)](https://github.com/microsoft/vcpkg/pull/9633) [cryptopp] Fixed build error on ARM32/ARM64 Windows (by @shibayan)
- [(#9281)](https://github.com/microsoft/vcpkg/pull/9281) [pbc] Correct non Windows build (by @decent-dcore)
- [(#9816)](https://github.com/microsoft/vcpkg/pull/9816) Make VS 2019 default to x64 triplet if CMAKE_GENERATOR_PLATFORM is not defined (by @Neumann-A)
- [(#9541)](https://github.com/microsoft/vcpkg/pull/9541) [memorymodule] Add new port (by @myd7349)
- [(#9521)](https://github.com/microsoft/vcpkg/pull/9521) [ftgl] Fix build failure #9520 (by @sma-github)
- [(#9456)](https://github.com/microsoft/vcpkg/pull/9456) [asiosdk] Add new port (by @batlogic)
- [(#9314)](https://github.com/microsoft/vcpkg/pull/9314) [sdl2-gfx] Fixed build error ARM64 Windows 10 (by @shibayan)
- [(#9265)](https://github.com/microsoft/vcpkg/pull/9265) Update the repo for jom 1.1.3 (by @zigguratvertigo)
- [(#8774)](https://github.com/microsoft/vcpkg/pull/8774) [vcpkg_find_acquire_program] Include version in downloaded python MSI… (by @ras0219-msft)
- [(#9698)](https://github.com/microsoft/vcpkg/pull/9698) [seal] Add new port (by @musaprg)
- [(#8832)](https://github.com/microsoft/vcpkg/pull/8832) [aws-*]Update version (by @JackBoosY)

<details>
<summary><b>The following 22 ports have been added:</b></summary>

|port|version|
|---|---|
|[argumentum](https://github.com/microsoft/vcpkg/pull/9478)| 0.2.2
|[tabulate](https://github.com/microsoft/vcpkg/pull/9543)| 2019-01-06
|[akali](https://github.com/microsoft/vcpkg/pull/9499)<sup>[#9617](https://github.com/microsoft/vcpkg/pull/9617) </sup>| 1.41
|[nethost](https://github.com/microsoft/vcpkg/pull/8701)| 2019-12-21
|[libmagic](https://github.com/microsoft/vcpkg/pull/8650)| 5.37
|[yas](https://github.com/microsoft/vcpkg/pull/8891)| 7.0.4
|[tfhe](https://github.com/microsoft/vcpkg/pull/8386)<sup>[#9649](https://github.com/microsoft/vcpkg/pull/9649) </sup>| 1.0.1-1
|[libb2](https://github.com/microsoft/vcpkg/pull/8518)| 0.98.1
|[libaaplus](https://github.com/microsoft/vcpkg/pull/9194)<sup>[#9579](https://github.com/microsoft/vcpkg/pull/9579) [#9664](https://github.com/microsoft/vcpkg/pull/9664) </sup>| 2.12
|[libwandio](https://github.com/microsoft/vcpkg/pull/8683)| 4.2.1
|[libevhtp](https://github.com/microsoft/vcpkg/pull/8678)| 1.2.18
|[soem](https://github.com/microsoft/vcpkg/pull/9572)| 1.4.0
|[glui](https://github.com/microsoft/vcpkg/pull/9155)| 2019-11-30
|[teemo](https://github.com/microsoft/vcpkg/pull/9684)| 1.2
|[mqtt-cpp](https://github.com/microsoft/vcpkg/pull/9787)| 7.0.1
|[msgpack11](https://github.com/microsoft/vcpkg/pull/9524)| 0.0.10
|[mcpp](https://github.com/microsoft/vcpkg/pull/9598)| 2.7.2.14
|[memorymodule](https://github.com/microsoft/vcpkg/pull/9541)| 2019-12-31
|[asiosdk](https://github.com/microsoft/vcpkg/pull/9456)| 2.3.3
|[sfsexp](https://github.com/microsoft/vcpkg/pull/9420)| 1.3
|[quaternions](https://github.com/microsoft/vcpkg/pull/9837)| 1.0.0
|[seal](https://github.com/microsoft/vcpkg/pull/9698)| 3.4.5
</details>

<details>
<summary><b>The following 226 ports have been updated:</b></summary>

- simpleini `2018-08-31-3` -> `2018-08-31-4`
    - [(#9429)](https://github.com/microsoft/vcpkg/pull/9429) [simpleini] Install missing code

- directxtk `dec2019` -> `2019-12-31`
    - [(#9508)](https://github.com/microsoft/vcpkg/pull/9508) [directxtk] Fix invalid solution configuration

- nameof `0.9.2` -> `0.9.3`
    - [(#9503)](https://github.com/microsoft/vcpkg/pull/9503) [nameof] Update to 0.9.3

- charls `2.0.0-3` -> `2.1.0-1`
    - [(#9494)](https://github.com/microsoft/vcpkg/pull/9494) [charls] upgrade to 2.1.0

- ptex `2.3.2` -> `2.3.2-1`
    - [(#9455)](https://github.com/microsoft/vcpkg/pull/9455) [ptext] Fix library cannot be found by find_package()

- fruit `3.4.0-1` -> `3.4.0-2`
    - [(#9445)](https://github.com/microsoft/vcpkg/pull/9445) [fruit] fix wchar.h import issue under Catalina

- libxlsxwriter `0.8.7-1` -> `0.9.4`
    - [(#9410)](https://github.com/microsoft/vcpkg/pull/9410) [libxlsxwriter] upgrade to 0.8.9
    - [(#9775)](https://github.com/microsoft/vcpkg/pull/9775) [libxlsxwriter] upgrade to 0.9.4

- uvatlas `apr2019` -> `dec2019`
    - [(#9379)](https://github.com/microsoft/vcpkg/pull/9379) [uvatlas] Upgrade to dec2019

- grpc `1.23.1-1` -> `1.26.0`
    - [(#9135)](https://github.com/microsoft/vcpkg/pull/9135) [grpc] Update grpc to 1.24.3
    - [(#9363)](https://github.com/microsoft/vcpkg/pull/9363) [grpc] Upgrade to gRPC-1.26.0

- freetype `2.10.1-1` -> `2.10.1-3`
    - [(#9311)](https://github.com/microsoft/vcpkg/pull/9311) [freetype] use config and the correct alias
    - [(#9706)](https://github.com/microsoft/vcpkg/pull/9706) [freetype] Add feature support

- glibmm `2.52.1-10` -> `2.52.1-11`
    - [(#9562)](https://github.com/microsoft/vcpkg/pull/9562) [glibmm] Fix build error on Linux

- libfreenect2 `0.2.0-3` -> `0.2.0-4`
    - [(#9551)](https://github.com/microsoft/vcpkg/pull/9551) [libfreenect2] add opengl and opencl features

- jsoncons `0.140.0` -> `0.143.1`
    - [(#9547)](https://github.com/microsoft/vcpkg/pull/9547) [jsoncons] Update to 0.143.1

- uwebsockets `0.16.5` -> `0.17.0a4`
    - [(#9535)](https://github.com/microsoft/vcpkg/pull/9535) [uwebsockets] Update to 0.17.0 alpha 4

- box2d `2.3.1-374664b-2` -> `2019-12-31`
    - [(#9529)](https://github.com/microsoft/vcpkg/pull/9529) [box2d] Update to 2019-12-31

- parallel-hashmap `1.27` -> `1.30`
    - [(#9519)](https://github.com/microsoft/vcpkg/pull/9519) [parallel-hashmap] Update to 1.30

- wpilib `2019.6.1` -> `2020.1.1`
    - [(#9513)](https://github.com/microsoft/vcpkg/pull/9513) [wpilib] update to 2020.1.1

- check `0.13.0-1` -> `0.13.0-2`
    - [(#9510)](https://github.com/microsoft/vcpkg/pull/9510) [check/gettimeofday] Move static libraries to manual-link

- gettimeofday `2017-10-14-2` -> `2017-10-14-3`
    - [(#9510)](https://github.com/microsoft/vcpkg/pull/9510) [check/gettimeofday] Move static libraries to manual-link

- magic-enum `0.6.3-1` -> `0.6.4`
    - [(#9502)](https://github.com/microsoft/vcpkg/pull/9502) [magic-enum] Update to v0.6.4

- simdjson `2019-08-05` -> `2019-12-27`
    - [(#9484)](https://github.com/microsoft/vcpkg/pull/9484) [simdjson] Update library

- cpp-httplib `0.4.2` -> `0.5.1`
    - [(#9480)](https://github.com/microsoft/vcpkg/pull/9480) [cpp-httplib] Update library to 0.5.1

- blend2d `beta_2019-10-09` -> `beta_2019-12-27`
    - [(#9448)](https://github.com/microsoft/vcpkg/pull/9448) [blend2d] Update to beta_2019-12-27

- parallelstl `20190522-1` -> `20191218`
    - [(#9443)](https://github.com/microsoft/vcpkg/pull/9443) [parallelstl] Update to latest version and fix find_package unable to find ParallelSTLConfig.cmake

- sdl2pp `0.16.0-1` -> `0.16.0-2`
    - [(#9428)](https://github.com/microsoft/vcpkg/pull/9428) [sdl2pp] Fix find dependencies

- basisu `1.11-2` -> `1.11-3`
    - [(#9425)](https://github.com/microsoft/vcpkg/pull/9425) [basisu] update from upstream repository, add support for pvrtc2

- devil `1.8.0-4` -> `1.8.0-5`
    - [(#9341)](https://github.com/microsoft/vcpkg/pull/9341) [devil] fix OpenEXR not found

- sdl1 `1.2.15-8` -> `1.2.15-9`
    - [(#9301)](https://github.com/microsoft/vcpkg/pull/9301) [sdl1] Add build support for ARM64 Windows 10
    - [(#9207)](https://github.com/microsoft/vcpkg/pull/9207) [sdl1]Change build method to vcpkg_*_make

- qt5-base `5.12.5-7` -> `5.12.5-8`
    - [(#9260)](https://github.com/microsoft/vcpkg/pull/9260) [qt5-base] Fix Qt5 linux build and be a bit less flaky in CI
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- qt5-imageformats `5.12.5-1` -> `5.12.5-2`
    - [(#9260)](https://github.com/microsoft/vcpkg/pull/9260) [qt5-base] Fix Qt5 linux build and be a bit less flaky in CI
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- qt5-tools `5.12.5-2` -> `5.12.5-3`
    - [(#9260)](https://github.com/microsoft/vcpkg/pull/9260) [qt5-base] Fix Qt5 linux build and be a bit less flaky in CI

- qt5-xmlpatterns `5.12.5` -> `5.12.5-1`
    - [(#9260)](https://github.com/microsoft/vcpkg/pull/9260) [qt5-base] Fix Qt5 linux build and be a bit less flaky in CI

- vtk `8.2.0-9` -> `8.2.0-10`
    - [(#9260)](https://github.com/microsoft/vcpkg/pull/9260) [qt5-base] Fix Qt5 linux build and be a bit less flaky in CI
    - [(#9219)](https://github.com/microsoft/vcpkg/pull/9219) [vtk] fix VTKConfig.cmake path

- libevent `2.1.11-2` -> `2.1.11-4`
    - [(#9292)](https://github.com/microsoft/vcpkg/pull/9292) [libevent] Fix include headers fails on x64-windows, using CMAKE
    - [(#9232)](https://github.com/microsoft/vcpkg/pull/9232) [libevent] remove dependency of default feature
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- pdal `1.7.1-6` -> `1.7.1-8`
    - [(#9308)](https://github.com/microsoft/vcpkg/pull/9308) [pdal] fix static build
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- xsimd `7.2.5` -> `7.4.5`
    - [(#9158)](https://github.com/microsoft/vcpkg/pull/9158) [xsimd][xtensor][xtl] Update to lastest

- xtensor-blas `0.16.1` -> `0.17.1`
    - [(#9158)](https://github.com/microsoft/vcpkg/pull/9158) [xsimd][xtensor][xtl] Update to lastest

- xtensor-io `0.7.0` -> `0.9.0`
    - [(#9158)](https://github.com/microsoft/vcpkg/pull/9158) [xsimd][xtensor][xtl] Update to lastest

- xtensor `0.20.8` -> `0.21.2`
    - [(#9158)](https://github.com/microsoft/vcpkg/pull/9158) [xsimd][xtensor][xtl] Update to lastest

- xtl `0.6.5` -> `0.6.10`
    - [(#9158)](https://github.com/microsoft/vcpkg/pull/9158) [xsimd][xtensor][xtl] Update to lastest

- freeimage `3.18.0-7` -> `3.18.0-8`
    - [(#8707)](https://github.com/microsoft/vcpkg/pull/8707) [freeimage libraw] Fix case issue on Linux

- libraw `201903-2` -> `201903-3`
    - [(#8707)](https://github.com/microsoft/vcpkg/pull/8707) [freeimage libraw] Fix case issue on Linux

- cgl `0.60.2-1` -> `0.60.2-2`
    - [(#8807)](https://github.com/microsoft/vcpkg/pull/8807) [cgl] Fix cgl cannot be found

- nanovg `2019-8-30-1` -> `2019-8-30-3`
    - [(#8813)](https://github.com/microsoft/vcpkg/pull/8813) [nanovg] Add dependency port stb

- hdf5 `1.10.5-8` -> `1.10.5-9`
    - [(#9043)](https://github.com/microsoft/vcpkg/pull/9043) [hdf5] Fix static builds when building dynamic builds
    - [(#9413)](https://github.com/microsoft/vcpkg/pull/9413) [HDF5] Correct SZIP linkage, modernize portfile 

- cgicc `3.2.19-3` -> `3.2.19-4`
    - [(#9123)](https://github.com/microsoft/vcpkg/pull/9123) [many ports] Add mirror
    - [(#8558)](https://github.com/microsoft/vcpkg/pull/8558) [cgicc]Fix usage error:lnk2019.

- gsl `2.4-4` -> `2.4-5`
    - [(#9123)](https://github.com/microsoft/vcpkg/pull/9123) [many ports] Add mirror

- libidn2 `2.2.0` -> `2.2.0-1`
    - [(#9123)](https://github.com/microsoft/vcpkg/pull/9123) [many ports] Add mirror

- libmicrohttpd `0.9.63-1` -> `0.9.63-2`
    - [(#9123)](https://github.com/microsoft/vcpkg/pull/9123) [many ports] Add mirror

- libosip2 `5.1.0-1` -> `5.1.0-3`
    - [(#9123)](https://github.com/microsoft/vcpkg/pull/9123) [many ports] Add mirror
    - [(#9602)](https://github.com/microsoft/vcpkg/pull/9602) [vcpkg] Fix build type in vcpkg_build_make.cmake [x264] Modernize

- libiconv `1.15-6` -> `1.16-1`
    - [(#9229)](https://github.com/microsoft/vcpkg/pull/9229) [libiconv] Make built libraries relocatable

- bullet3 `2.88-1` -> `2.89`
    - [(#9098)](https://github.com/microsoft/vcpkg/pull/9098) [bullet3] Install CMake toolchain files and targets
    - [(#9663)](https://github.com/microsoft/vcpkg/pull/9663) [bullet3] Update to 2.89

- fmt `6.0.0` -> `6.0.0-1`
    - [(#9121)](https://github.com/microsoft/vcpkg/pull/9121) [fmt] Disable warning C4189 on Visual Studio 2015

- otl `4.0.448` -> `4.0.451`
    - [(#9107)](https://github.com/microsoft/vcpkg/pull/9107) [otl] Fix header file name and version number
    - [(#9579)](https://github.com/microsoft/vcpkg/pull/9579) [otl libaaplus forge] Fix build issues
    - [(#9552)](https://github.com/microsoft/vcpkg/pull/9552) [otl] Update to version 4.0.451

- liblzma `5.2.4-2` -> `5.2.4-3`
    - [(#9192)](https://github.com/microsoft/vcpkg/pull/9192) [liblzma] Stop exporting HAVE_CONFIG_H

- glib `2.52.3-14-4` -> `2.52.3-14-5`
    - [(#9054)](https://github.com/microsoft/vcpkg/pull/9054) [glib] Install msvc_recommended_pragmas.h to <vcpkg>/installed/include

- curl `7.66.0-1` -> `7.68.0`
    - [(#8973)](https://github.com/microsoft/vcpkg/pull/8973) [curl] Disable export of Curl::curl targets when building 'tool' feature
    - [(#9589)](https://github.com/microsoft/vcpkg/pull/9589) [curl] Update to 7.68.0

- forge `1.0.4-1` -> `1.0.4-2`
    - [(#9579)](https://github.com/microsoft/vcpkg/pull/9579) [otl libaaplus forge] Fix build issues

- reproc `9.0.0` -> `10.0.3`
    - [(#9544)](https://github.com/microsoft/vcpkg/pull/9544) [reproc] Update to v10.0.3.

- cpp-netlib `0.13.0-2` -> `0.13.0-3`
    - [(#9537)](https://github.com/microsoft/vcpkg/pull/9537) [cpp-netlib] Fix cmake path, add homepage

- proj4 `6.2.1-1` -> `6.3.0-1`
    - [(#9437)](https://github.com/microsoft/vcpkg/pull/9437) [sqlite3] Rename sqlite3 tool as sqlite3.exe
    - [(#9573)](https://github.com/microsoft/vcpkg/pull/9573) [proj4] Update to version 6.3.0

- sqlite3 `3.30.1-1` -> `3.30.1-2`
    - [(#9437)](https://github.com/microsoft/vcpkg/pull/9437) [sqlite3] Rename sqlite3 tool as sqlite3.exe

- msix `MsixCoreInstaller-preview-1` -> `1.7`
    - [(#8934)](https://github.com/microsoft/vcpkg/pull/8934) [msix] Update to 1.7

- xmsh `0.4.1` -> `0.5.2`
    - [(#7155)](https://github.com/microsoft/vcpkg/pull/7155) [xmsh]Upgrade version to 0.5.2 and fix build failure.

- opencolorio `1.1.1` -> `1.1.1-2`
    - [(#8920)](https://github.com/microsoft/vcpkg/pull/8920) [opencolorio] Modify find python2 to find python3
    - [(#9755)](https://github.com/microsoft/vcpkg/pull/9755) [opencolorio] fix lcms dependency

- graphicsmagick `1.3.33-1` -> `1.3.34`
    - [(#9596)](https://github.com/microsoft/vcpkg/pull/9596) [graphicsmagick] Updated to GraphicsMagick-1.3.34

- openal-soft `1.19.1-2` -> `1.20.0`
    - [(#9583)](https://github.com/microsoft/vcpkg/pull/9583) [openal-soft] Update OpenAL Soft to 1.20.0

- google-cloud-cpp `0.15.0` -> `0.17.0`
    - [(#9576)](https://github.com/microsoft/vcpkg/pull/9576) [google-cloud-cpp] Upgrade to v0.17.0

- openmvs `1.0-3` -> `1.0.1`
    - [(#9563)](https://github.com/microsoft/vcpkg/pull/9563) [openmvs] Update to 1.0.1

- ixwebsocket `7.4.0` -> `7.9.2`
    - [(#9397)](https://github.com/microsoft/vcpkg/pull/9397) [ixwebsocket] update to 7.6.3

- azure-kinect-sensor-sdk `1.4.0-alpha.0` -> `1.4.0-alpha.0-2`
    - [(#9458)](https://github.com/microsoft/vcpkg/pull/9458) [azure-kinect-sensor-sdk] Remove feature test and fix static build in Windows
    - [(#9763)](https://github.com/microsoft/vcpkg/pull/9763) [azure-kinect-sensor-sdk] Fix *.dll install path

- netcdf-c `4.7.0-5` -> `4.7.3-1`
    - [(#9361)](https://github.com/microsoft/vcpkg/pull/9361) [netcdf-c] Update to 4.7.3 and switched to use targets to generate valid targets
    - [(#9721)](https://github.com/microsoft/vcpkg/pull/9721) [netcdf-c] Fix builds with hdf5[parallel]

- realsense2 `2.22.0-2` -> `2.30.0`
    - [(#9220)](https://github.com/microsoft/vcpkg/pull/9220) [realsense2] update to 2.30

- libplist `1.2.77` -> `1.2.137`
    - [(#8936)](https://github.com/microsoft/vcpkg/pull/8936) [libplist] Update to 1.2.137

- ismrmrd `1.4.0-1` -> `1.4.1`
    - [(#8880)](https://github.com/microsoft/vcpkg/pull/8880) [ismrmrd] Update to 1.4.1

- caf `0.16.3` -> `0.17.2`
    - [(#8888)](https://github.com/microsoft/vcpkg/pull/8888) [caf] Update to 0.17.2

- openmvg `1.4-6` -> `1.4-7`
    - [(#8824)](https://github.com/microsoft/vcpkg/pull/8824) [openmvg]Fix path in openmvg-config.cmake.

- qhull `7.3.2-1` -> `7.3.2-2`
    - [(#9651)](https://github.com/microsoft/vcpkg/pull/9651) [qhull] Fix Mac support

- cppmicroservices `4.0.0-pre1` -> `v3.4.0`
    - [(#9600)](https://github.com/microsoft/vcpkg/pull/9600) Update baseline to fix osx failure

- libguarded `2019-08-27` -> `2019-08-27-1`
    - [(#9600)](https://github.com/microsoft/vcpkg/pull/9600) Update baseline to fix osx failure

- sfgui `0.4.0-2` -> `0.4.0-3`
    - [(#9625)](https://github.com/microsoft/vcpkg/pull/9625) [sfgui] fix sfgui on macOS

- azure-storage-cpp `7.0.0` -> `7.1.0-1`
    - [(#9646)](https://github.com/microsoft/vcpkg/pull/9646) [azure-storage-cpp]Upgrade to 7.1.0
    - [(#9852)](https://github.com/microsoft/vcpkg/pull/9852) [azure-storage-cpp] Azure storage only requires gettext on OSX

- ace `6.5.7` -> `6.5.7-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d
    - [(#9016)](https://github.com/microsoft/vcpkg/pull/9016) [ace] Let `ssl` feature able to work on Linux when selected

- freerdp `2.0.0-rc4-3` -> `2.0.0-rc4-4`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- freetds `1.1.6-1` -> `1.1.17`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- libmysql `8.0.4-4` -> `8.0.4-5`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- libpq `9.6.3` -> `12.0`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- librtmp `2019-11-11` -> `2019-11-11_1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- libssh `0.7.6-1` -> `0.9.0`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- libwebsockets `3.2.0` -> `3.2.2`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d
    - [(#9734)](https://github.com/microsoft/vcpkg/pull/9734) [libwebsockets] Update to v3.2.2

- mosquitto `1.6.7` -> `1.6.7-2`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d
    - [(#9754)](https://github.com/microsoft/vcpkg/pull/9754) [mosquitto] Install mosquittopp.lib to dest

- nmap `7.70-1` -> `7.70-4`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE

- openssl-unix `1.0.2s-1` -> `1.1.1d-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- openssl-uwp `1.0.2r-1` -> `1.1.1d-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE

- openssl-windows `1.0.2s-2` -> `1.1.1d-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE

- qt5-graphicaleffects `5.12.5` -> `5.12.5-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- quickfix `1.15.1-1` -> `1.15.1-3`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- slikenet `2019-10-22` -> `2019-10-22_1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- xmlsec `1.2.29` -> `1.2.29-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- yara `3.10.0` -> `3.10.0-1`
    - [(#8566)](https://github.com/microsoft/vcpkg/pull/8566) [libpq, openssl, librtmp] libpq 12 and others with openssl 1.1.1d

- x264 `157-303c484ec828ed0-6` -> `157-303c484ec828ed0-7`
    - [(#9602)](https://github.com/microsoft/vcpkg/pull/9602) [vcpkg] Fix build type in vcpkg_build_make.cmake [x264] Modernize

- glfw3 `3.3-3` -> `3.3.1`
    - [(#9626)](https://github.com/microsoft/vcpkg/pull/9626) [glfw3] Update to 3.3.1

- glad `0.1.31` -> `0.1.33`
    - [(#9627)](https://github.com/microsoft/vcpkg/pull/9627) [glad] Update to 0.1.33

- libxml2 `2.9.9-4` -> `2.9.9-5`
    - [(#9636)](https://github.com/microsoft/vcpkg/pull/9636) [libxml2] Apply fixes also to the target of libxml2.
    - [(#9492)](https://github.com/microsoft/vcpkg/pull/9492) [libxml2] Embed resources in Windows-based shared library (#9474)

- gettext `0.19-11` -> `0.19-13`
    - [(#9610)](https://github.com/microsoft/vcpkg/pull/9610) [gettext] Add dependency on iconv
    - [(#9797)](https://github.com/microsoft/vcpkg/pull/9797) [gettext] fix library placement on macOS

- xlnt `1.3.0-2` -> `1.4.0`
    - [(#9609)](https://github.com/microsoft/vcpkg/pull/9609) [xlnt] Upgrade to v1.4.0

- cpr `1.3.0-7` -> `1.3.0-8`
    - [(#9567)](https://github.com/microsoft/vcpkg/pull/9567) [cpr] Add find_dependency to cprConfig.cmake

- sfml `2.5.1-4` -> `2.5.1-6`
    - [(#9190)](https://github.com/microsoft/vcpkg/pull/9190) [sfml] Declare Windows library export
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures

- libtorrent `1.2.2` -> `1.2.2-1`
    - [(#7345)](https://github.com/microsoft/vcpkg/pull/7345) [libtorrent] Fix linkage issues for dynamic builds

- libffi `3.1-6` -> `3.1-7`
    - [(#8895)](https://github.com/microsoft/vcpkg/pull/8895) [libffi] Add libffiConfigVersion.cmake file

- plplot `5.13.0-3` -> `5.13.0-4`
    - [(#8817)](https://github.com/microsoft/vcpkg/pull/8817) [plplot] Fix static build issue

- libpqxx `6.4.5` -> `6.4.5-1`
    - [(#9051)](https://github.com/microsoft/vcpkg/pull/9051) [libpqxx] Fix lib name on Linux

- freeglut `3.0.0-7` -> `3.0.0-9`
    - [(#9155)](https://github.com/microsoft/vcpkg/pull/9155) [glui] Add new port
    - [(#9725)](https://github.com/microsoft/vcpkg/pull/9725) [freeglut] Patch header correctly
    - [(#9745)](https://github.com/microsoft/vcpkg/pull/9745) [freeglut] check whether debug/release is enabled before moving files

- ffmpeg `4.2-2` -> `4.2-4`
    - [(#9695)](https://github.com/microsoft/vcpkg/pull/9695) [ffmpeg] fix openssl detection
    - [(#9718)](https://github.com/microsoft/vcpkg/pull/9718) [ffmpeg] fix link order

- catch2 `2.11.0` -> `2.11.1`
    - [(#9685)](https://github.com/microsoft/vcpkg/pull/9685) [catch2] Update to 2.11.1

- boost-accumulators `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-algorithm `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-align `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-any `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-array `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-asio `1.71.0-1` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-assert `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-assign `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-atomic `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-beast `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-bimap `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-bind `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-build `1.70.0-1` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-callable-traits `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-chrono `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-circular-buffer `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-compatibility `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-compute `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-concept-check `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-config `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-container-hash `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-container `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-context `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-contract `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-conversion `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-convert `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-core `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-coroutine `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-coroutine2 `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-crc `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-date-time `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-detail `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-disjoint-sets `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-dll `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-dynamic-bitset `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-endian `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-exception `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-fiber `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-filesystem `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-flyweight `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-foreach `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-format `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-function-types `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-function `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-functional `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-fusion `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-geometry `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-gil `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-graph-parallel `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- boost-graph `1.71.0` -> `1.72.0`
    - [(#9317)](https://github.com/microsoft/vcpkg/pull/9317) [boost] Update to 1.72.0

- embree3 `3.6.1` -> `3.6.1-1`
    - [(#9555)](https://github.com/microsoft/vcpkg/pull/9555) [embree3] added cleanup command to embree3 port for static build

- libarchive `3.4.0-2` -> `3.4.1`
    - [(#9676)](https://github.com/microsoft/vcpkg/pull/9676) [libarchive] Update to 3.4.1

- tinyfiledialogs `3.3.8-1` -> `3.4.3`
    - [(#9630)](https://github.com/microsoft/vcpkg/pull/9630) [tinyfiledialogs] Fix tinyfiledialogs not being fetchable from sourceforge

- tesseract `4.1.0-4` -> `4.1.1`
    - [(#9629)](https://github.com/microsoft/vcpkg/pull/9629) [tesseract] port update to 4.1.1 release

- glm `0.9.9.5-3` -> `0.9.9.7`
    - [(#9621)](https://github.com/microsoft/vcpkg/pull/9621) [glm] Updated to 0.9.9.7

- google-cloud-cpp-spanner `0.3.0` -> `0.5.0`
    - [(#9611)](https://github.com/microsoft/vcpkg/pull/9611) [google-cloud-cpp-spanner] Upgrade to the v0.5.0 release.

- scintilla `4.1.2` -> `4.2.3`
    - [(#9591)](https://github.com/microsoft/vcpkg/pull/9591) [scintilla] Update to 4.2.3

- ppconsul `0.4` -> `0.5`
    - [(#9752)](https://github.com/microsoft/vcpkg/pull/9752) [ppconsul] Add missing boost dependencies
    - [(#9713)](https://github.com/microsoft/vcpkg/pull/9713) [ppconsul] Upgrade to latest version

- boost-signals `1.68.0` -> `1.68.0-1`
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures

- gtest `2019-10-09` -> `2019-10-09-1`
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures

- pcl `1.9.1-9` -> `1.9.1-10`
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures

- soil2 `release-1.11` -> `release-1.11-1`
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures

- tmxparser `2.1.0-2` -> `2.1.0-3`
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures

- xerces-c `3.2.2-11` -> `3.2.2-13`
    - [(#9726)](https://github.com/microsoft/vcpkg/pull/9726) Fix osx baseline build failures
    - [(#9702)](https://github.com/microsoft/vcpkg/pull/9702) [xerces-c] fixed issue #9654

- openssl `1` -> `1.1.1d`
    - [(#9777)](https://github.com/microsoft/vcpkg/pull/9777) [openssl] Update the version

- open62541 `0.3.0-4` -> `1.0`
    - [(#9767)](https://github.com/microsoft/vcpkg/pull/9767) [open62541] Update to v1.0

- monkeys-audio `4.8.3-1` -> `5.14`
    - [(#9760)](https://github.com/microsoft/vcpkg/pull/9760) [monkeys-audio] Update to 5.14, add feature tools

- hpx `1.3.0-2` -> `1.4.0-1`
    - [(#9773)](https://github.com/microsoft/vcpkg/pull/9773) Updating HPX to V1.4

- paho-mqtt `1.3.0-1` -> `1.3.0-2`
    - [(#9753)](https://github.com/microsoft/vcpkg/pull/9753) [paho-mqtt] Fix Windows platform predefined macros

- alembic `1.7.11-6` -> `1.7.12`
    - [(#9737)](https://github.com/microsoft/vcpkg/pull/9737) Update Alembic version to 1.7.12

- libudns `0.4` -> `0.4-1`
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE

- luajit `2.0.5-2` -> `2.0.5-3`
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE
    - [(#9782)](https://github.com/microsoft/vcpkg/pull/9782) [luajit] Copy tool dependencies

- pfring `2019-10-17` -> `2019-10-17-1`
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE

- tcl `8.6.10-2` -> `8.6.10-3`
    - [(#9703)](https://github.com/microsoft/vcpkg/pull/9703) Update portfiles to use VCPKG_BUILD_TYPE

- asmjit `2019-07-11` -> `2020-01-20`
    - [(#9770)](https://github.com/microsoft/vcpkg/pull/9770) [asmjit] update to current version

- so5extra `1.3.1.1` -> `1.4.0`
    - [(#9732)](https://github.com/microsoft/vcpkg/pull/9732) [sobjectizer][so5extra] updates to 5.7.0 and 1.4.0

- sobjectizer `5.6.1-1` -> `5.7.0`
    - [(#9732)](https://github.com/microsoft/vcpkg/pull/9732) [sobjectizer][so5extra] updates to 5.7.0 and 1.4.0

- string-theory `2.3` -> `3.1`
    - [(#9690)](https://github.com/microsoft/vcpkg/pull/9690) [string_theory] Update to 3.0
    - [(#9833)](https://github.com/microsoft/vcpkg/pull/9833) [string_theory] Update to 3.1

- anyrpc `2017-12-01-1` -> `2020-01-13-1`
    - [(#9682)](https://github.com/microsoft/vcpkg/pull/9682) [anyrpc] Updated to latest commit

- jasper `2.0.16-2` -> `2.0.16-3`
    - [(#9680)](https://github.com/microsoft/vcpkg/pull/9680) [jasper] freeglut is not a dependency in macOS

- cryptopp `8.2.0` -> `8.2.0-1`
    - [(#9633)](https://github.com/microsoft/vcpkg/pull/9633) [cryptopp] Fixed build error on ARM32/ARM64 Windows

- angle `2019-07-19-4` -> `2019-12-31`
    - [(#9557)](https://github.com/microsoft/vcpkg/pull/9557) [angle] Update to 2019-12-31

- pbc `0.5.14-1` -> `0.5.14-2`
    - [(#9281)](https://github.com/microsoft/vcpkg/pull/9281) [pbc] Correct non Windows build

- fizz `2019.10.28.00` -> `2020.01.20.00`
    - [(#9779)](https://github.com/microsoft/vcpkg/pull/9779) [fizz] Update to latest version

- hyperscan `5.0.1-2` -> `5.1.0-3`
    - [(#9618)](https://github.com/microsoft/vcpkg/pull/9618) [hyperscan] Update the portfile to remove debug/share file

- coroutine `1.4.3` -> `2020-01-13`
    - [(#9624)](https://github.com/microsoft/vcpkg/pull/9624) [ms-gsl] Update to v2.1.0, the "end of 2019 snapshot"

- ms-gsl `2019-07-11` -> `2.1.0`
    - [(#9624)](https://github.com/microsoft/vcpkg/pull/9624) [ms-gsl] Update to v2.1.0, the "end of 2019 snapshot"

- ftgl `2.4.0-1` -> `2.4.0-2`
    - [(#9521)](https://github.com/microsoft/vcpkg/pull/9521) [ftgl] Fix build failure #9520

- sdl2-mixer `2.0.4-7` -> `2.0.4-8`
    - [(#9332)](https://github.com/microsoft/vcpkg/pull/9332) [sdl2-mixer] Fix dynamic loading when building static library

- sdl2-gfx `1.0.4-4` -> `1.0.4-5`
    - [(#9314)](https://github.com/microsoft/vcpkg/pull/9314) [sdl2-gfx] Fixed build error ARM64 Windows 10

- restclient-cpp `0.5.1-2` -> `0.5.1-3`
    - [(#9487)](https://github.com/microsoft/vcpkg/pull/9487) [restclient-cpp]: correct the way to remove debug/include

- jsoncpp `1.9.1` -> `1.9.2`
    - [(#9759)](https://github.com/microsoft/vcpkg/pull/9759) [Jsoncpp] Update to 1.9.2

- loguru `v2.0.0` -> `v2.1.0`
    - [(#8682)](https://github.com/microsoft/vcpkg/pull/8682) [loguru] Update to 2.1.0 and extend to generate proper binary on non-windows

- gsl-lite `0.34.0` -> `0.36.0`
    - [(#9827)](https://github.com/microsoft/vcpkg/pull/9827) [gsl-lite] Update to version 0.36.0

- telnetpp `2.0-2` -> `2.0-3`
    - [(#9827)](https://github.com/microsoft/vcpkg/pull/9827) [gsl-lite] Update to version 0.36.0

- cgal `5.0` -> `5.0.1`
    - [(#9831)](https://github.com/microsoft/vcpkg/pull/9831) [cgal] Upgrade to 5.0.1

- avro-c `1.8.2-3` -> `1.8.2-4`
    - [(#9808)](https://github.com/microsoft/vcpkg/pull/9808) [avro-c] enable Snappy codec

- pango `1.40.11-5` -> `1.40.11-6`
    - [(#9801)](https://github.com/microsoft/vcpkg/pull/9801) [pango] fix macOS dynamic library

- eigen3 `3.3.7-3` -> `3.3.7-4`
    - [(#9821)](https://github.com/microsoft/vcpkg/pull/9821) Update eigen3's portfile to use new gitlab repo

- aws-c-common `0.4.1` -> `0.4.15`
    - [(#8832)](https://github.com/microsoft/vcpkg/pull/8832) [aws-*]Update version

- aws-c-event-stream `0.1.1` -> `0.1.4`
    - [(#8832)](https://github.com/microsoft/vcpkg/pull/8832) [aws-*]Update version

- aws-checksums `0.1.3` -> `0.1.5`
    - [(#8832)](https://github.com/microsoft/vcpkg/pull/8832) [aws-*]Update version

- aws-lambda-cpp `0.1.0-2` -> `0.2.4`
    - [(#8832)](https://github.com/microsoft/vcpkg/pull/8832) [aws-*]Update version

- aws-sdk-cpp `1.7.142-1` -> `1.7.214`
    - [(#8832)](https://github.com/microsoft/vcpkg/pull/8832) [aws-*]Update version

- azure-c-shared-utility `2019-10-07.2-1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

- azure-iot-sdk-c `2019-11-27.1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

- azure-macro-utils-c `2019-11-27.1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

- azure-uamqp-c `2019-11-27.1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

- azure-uhttp-c `2019-11-27.1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

- azure-umqtt-c `2019-11-27.1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

- umock-c `2019-11-27.1` -> `2020-01-22`
    - [(#9805)](https://github.com/microsoft/vcpkg/pull/9805) Azure-IoT-Sdk for C release 2020-01-22

</details>

-- vcpkg team vcpkg@microsoft.com THU, 05 Jan 15:00:00 -0800

vcpkg (2019.12.31)
---
#### Total port count: 1268
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|**x64-windows**|1181|
|x86-windows|1166|
|x64-windows-static|1087|
|**x64-linux**|1000|
|**x64-osx**|920|
|arm64-windows|795|
|x64-uwp|642|
|arm-uwp|615|

#### The following documentation has been updated:
- [PR Review Checklist](docs/maintainers/pr-review-checklist.md) ***[NEW]***
    - [(#9264)](https://github.com/microsoft/vcpkg/pull/9264) [vcpkg] Initialize PR review checklist
- [vcpkg_install_qmake](docs/maintainers/vcpkg_install_qmake.md) ***[NEW]***
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [CONTROL Files](docs/maintainers/control-files.md)
    - [(#9140)](https://github.com/microsoft/vcpkg/pull/9140) [docs] Fix CONTROL file default-features section header
- [Portfile Functions](docs/maintainers/portfile-functions.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_build_nmake](docs/maintainers/vcpkg_build_nmake.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_common_definitions](docs/maintainers/vcpkg_common_definitions.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_configure_make](docs/maintainers/vcpkg_configure_make.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_download_distfile](docs/maintainers/vcpkg_download_distfile.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_extract_source_archive_ex](docs/maintainers/vcpkg_extract_source_archive_ex.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_find_acquire_program](docs/maintainers/vcpkg_find_acquire_program.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [vcpkg_install_nmake](docs/maintainers/vcpkg_install_nmake.md)
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake

#### The following changes have been made to vcpkg's infrastructure:
- [(#9160)](https://github.com/microsoft/vcpkg/pull/9160) [ffmpeg] Fixed build error ARM64 Windows 10
- [(#9199)](https://github.com/microsoft/vcpkg/pull/9199) [vcpkg] Add November changelog
- [(#9203)](https://github.com/microsoft/vcpkg/pull/9203) [vcpkg] Check in baseline results for CI builds
- [(#9191)](https://github.com/microsoft/vcpkg/pull/9191) [vcpkg] Give hints for yasm with brew and apt
- [(#9242)](https://github.com/microsoft/vcpkg/pull/9242) [libxslt] Fix writing to locations outside vcpkg in Windows builds
- [(#9279)](https://github.com/microsoft/vcpkg/pull/9279) Removed umock-c:64-windows-static result in baseline
- [(#9280)](https://github.com/microsoft/vcpkg/pull/9280) [vcpkg] Add pull request template
- [(#9331)](https://github.com/microsoft/vcpkg/pull/9331) Update baseline to skip ogre conflicts
- [(#9349)](https://github.com/microsoft/vcpkg/pull/9349) Update baseline with 'leptonica:arm-uwp=fail'
- [(#9277)](https://github.com/microsoft/vcpkg/pull/9277) [brynet] Update to 1.0.5
- [(#9330)](https://github.com/microsoft/vcpkg/pull/9330) [simpleini] Fix build failure on travis CI
- [(#9313)](https://github.com/microsoft/vcpkg/pull/9313) [opendnp3] Add new port
- [(#9255)](https://github.com/microsoft/vcpkg/pull/9255) [OpenEXR] add missing underscore for OpenEXR_IEXMATH_LIBRARY_DEBUG NAMES
- [(#9252)](https://github.com/microsoft/vcpkg/pull/9252) [rttr] Add dependency rapidjson
- [(#8533)](https://github.com/microsoft/vcpkg/pull/8533) Fix CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
- [(#9382)](https://github.com/microsoft/vcpkg/pull/9382) [directxtk12] Update to dec2019 release
- [(#9383)](https://github.com/microsoft/vcpkg/pull/9383) [directxtex] Update to dec2019 release
- [(#9384)](https://github.com/microsoft/vcpkg/pull/9384) [directxmesh] Update to dec2019 release
- [(#9381)](https://github.com/microsoft/vcpkg/pull/9381) [directxtk] Update to dec2019 release
- [(#9287)](https://github.com/microsoft/vcpkg/pull/9287) Removed unused template function.
- [(#9411)](https://github.com/microsoft/vcpkg/pull/9411) [vcpkg-baseline] Fixes for vtk, libarchive, xalan-c, and openvpn3 on Linux
- [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake
- [(#9388)](https://github.com/microsoft/vcpkg/pull/9388) [hiredis] Support building static
- [(#8624)](https://github.com/microsoft/vcpkg/pull/8624) [protobuf-c]Add new port.
- [(#9389)](https://github.com/microsoft/vcpkg/pull/9389) Remove vtk:x64-linux result in baseline

<details>
<summary><b>The following 8 ports have been added:</b></summary>

|port|version|
|---|---|
|[proxywrapper](https://github.com/microsoft/vcpkg/pull/8916)| 1.0.0
|[opendnp3](https://github.com/microsoft/vcpkg/pull/9313)| 2.3.2
|[function2](https://github.com/microsoft/vcpkg/pull/9246)| 4.0.0
|[protobuf-c](https://github.com/microsoft/vcpkg/pull/8624)| 1.3.2
|[indicators](https://github.com/microsoft/vcpkg/pull/9315)| 1.5
|[proxygen](https://github.com/microsoft/vcpkg/pull/8766)| 2019.10.21.00
|[azure-kinect-sensor-sdk](https://github.com/microsoft/vcpkg/pull/8786)| 1.4.0-alpha.0
|[xtensor-fftw](https://github.com/microsoft/vcpkg/pull/9159)| 2019-11-30
</details>

<details>
<summary><b>The following 72 ports have been updated:</b></summary>

- restinio `0.6.1` -> `0.6.2`
    - [(#9174)](https://github.com/microsoft/vcpkg/pull/9174) [restinio] Update to v.0.6.1.1.
    - [(#9293)](https://github.com/microsoft/vcpkg/pull/9293) [restinio] update to 0.6.2

- pixman `0.38.0-4` -> `0.38.4-1`
    - [(#9170)](https://github.com/microsoft/vcpkg/pull/9170) [pixman] Update to version 0.38.4

- cjson `1.7.12` -> `2019-11-30`
    - [(#9157)](https://github.com/microsoft/vcpkg/pull/9157) [cjson] Update to 2019-11-30

- parallel-hashmap `1.24` -> `1.27`
    - [(#9152)](https://github.com/microsoft/vcpkg/pull/9152) [parallel-hashmap] Update to 1.27

- jsoncons `0.139.0` -> `0.140.0`
    - [(#9124)](https://github.com/microsoft/vcpkg/pull/9124) [jsoncons] Update to v0.140.0

- boost-modular-build-helper `1.71.0` -> `1.71.0-1`
    - [(#9108)](https://github.com/microsoft/vcpkg/pull/9108) [boost-modular-build-helper] put quotes around the directory

- protobuf `3.10.0` -> `3.11.2`
    - [(#9131)](https://github.com/microsoft/vcpkg/pull/9131) [protobuf] Update protobuf to 3.11.0
    - [(#9271)](https://github.com/microsoft/vcpkg/pull/9271) [protobuf] Update to 3.11.2

- ecsutil `1.0.7.3` -> `1.0.7.8`
    - [(#8885)](https://github.com/microsoft/vcpkg/pull/8885) [ecsuti] Update to v1.0.7.8

- libmodman `2.0.1` -> `2.0.1-1`
    - [(#8916)](https://github.com/microsoft/vcpkg/pull/8916) [proxywrapper] Add new port

- libproxy `0.4.15` -> `0.4.15-1`
    - [(#8916)](https://github.com/microsoft/vcpkg/pull/8916) [proxywrapper] Add new port

- xalan-c `1.11-9` -> `1.11-11`
    - [(#9203)](https://github.com/microsoft/vcpkg/pull/9203) [vcpkg] Check in baseline results for CI builds
    - [(#9411)](https://github.com/microsoft/vcpkg/pull/9411) [vcpkg-baseline] Fixes for vtk, libarchive, xalan-c, and openvpn3 on Linux

- libxslt `1.1.33-5` -> `1.1.33-6`
    - [(#9242)](https://github.com/microsoft/vcpkg/pull/9242) [libxslt] Fix writing to locations outside vcpkg in Windows builds

- azure-c-shared-utility `2019-10-07.2` -> `2019-10-07.2-1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- azure-iot-sdk-c `2019-11-21.1` -> `2019-11-27.1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- azure-macro-utils-c `2019-10-07.2` -> `2019-11-27.1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- azure-uamqp-c `2019-10-07.2` -> `2019-11-27.1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- azure-uhttp-c `2019-10-07.2` -> `2019-11-27.1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- azure-umqtt-c `2019-10-07.2` -> `2019-11-27.1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- umock-c `2019-10-07.2` -> `2019-11-27.1`
    - [(#9117)](https://github.com/microsoft/vcpkg/pull/9117) [azure-iot-sdk-c] Update macro-utils and umock-c to differentiate master and public-preview installations

- python3 `3.7.4` -> `3.7.3`
    - [(#9173)](https://github.com/microsoft/vcpkg/pull/9173) [python3] Fix CONTROL Version

- brynet `1.0.3` -> `1.0.5`
    - [(#9277)](https://github.com/microsoft/vcpkg/pull/9277) [brynet] Update to 1.0.5

- cpp-httplib `0.2.5` -> `0.4.2`
    - [(#9360)](https://github.com/microsoft/vcpkg/pull/9360) [cpp-httplib] Update library to 0.4.2

- botan `2.12.1` -> `2.12.1-1`
    - [(#9335)](https://github.com/microsoft/vcpkg/pull/9335) [botan] Fix unrecognized compile flag MT/MD

- simpleini `2018-08-31-2` -> `2018-08-31-3`
    - [(#9330)](https://github.com/microsoft/vcpkg/pull/9330) [simpleini] Fix build failure on travis CI

- libpcap `1.9.0` -> `1.9.1`
    - [(#9329)](https://github.com/microsoft/vcpkg/pull/9329) [libpcap] update portfile for cmake build and bump version to 1.9.1

- live555 `latest` -> `latest-1`
    - [(#9303)](https://github.com/microsoft/vcpkg/pull/9303) [live555] Fix live555:x86-windows-static build failure

- usockets `0.3.1` -> `0.3.4`
    - [(#9278)](https://github.com/microsoft/vcpkg/pull/9278) [usockets] update to 0.3.4

- uwebsockets `0.15.7` -> `0.16.5`
    - [(#9276)](https://github.com/microsoft/vcpkg/pull/9276) [uwebsockets] update to 0.16.5

- check `0.13.0` -> `0.13.0-1`
    - [(#9267)](https://github.com/microsoft/vcpkg/pull/9267) [check] Fix library cannot be found

- tesseract `4.1.0-3` -> `4.1.0-4`
    - [(#9266)](https://github.com/microsoft/vcpkg/pull/9266) [tesseract] Fix feature name and build error

- libharu `2017-08-15-8` -> `2017-08-15-9`
    - [(#9261)](https://github.com/microsoft/vcpkg/pull/9261) [libharu] Remove symbols also exported from tiff (as a default feature)

- alembic `1.7.11-5` -> `1.7.11-6`
    - [(#9255)](https://github.com/microsoft/vcpkg/pull/9255) [OpenEXR] add missing underscore for OpenEXR_IEXMATH_LIBRARY_DEBUG NAMES

- openexr `2.3.0-4` -> `2.3.0-5`
    - [(#9255)](https://github.com/microsoft/vcpkg/pull/9255) [OpenEXR] add missing underscore for OpenEXR_IEXMATH_LIBRARY_DEBUG NAMES

- xeus `0.20.0` -> `0.20.0-1`
    - [(#9254)](https://github.com/microsoft/vcpkg/pull/9254) [xeus] Fix build error with Visual Studio 2019

- libpq `9.6.1-8` -> `9.6.3`
    - [(#9253)](https://github.com/microsoft/vcpkg/pull/9253) [libpq] Fix version mismatch between CONTROL and portfile

- rttr `0.9.6-1` -> `0.9.6-2`
    - [(#9252)](https://github.com/microsoft/vcpkg/pull/9252) [rttr] Add dependency rapidjson

- proj4 `6.2.0-1` -> `6.2.1-1`
    - [(#9227)](https://github.com/microsoft/vcpkg/pull/9227) [proj4] Update to version 6.2.1; disable exporting symbols for static libraries

- geotrans `3.7` -> `3.7-1`
    - [(#9217)](https://github.com/microsoft/vcpkg/pull/9217) [geotrans] Add macro LITTLE_ENDIAN

- mongoose `6.15-1` -> `6.15-2`
    - [(#9209)](https://github.com/microsoft/vcpkg/pull/9209) [mongoose] Add feature ssl

- ecm `5.60.0-1` -> `5.60.0-2`
    - [(#9210)](https://github.com/microsoft/vcpkg/pull/9210) [ecm] Add usage to fix printing error messages

- tbb `2019_U8-2` -> `2019_U8-3`
    - [(#9188)](https://github.com/microsoft/vcpkg/pull/9188) [tbb] Set fatal build tool requirements for UNIX

- libqglviewer `2.7.0-2` -> `2.7.2-2`
    - [(#9186)](https://github.com/microsoft/vcpkg/pull/9186) [libqglviewer] update to 2.7.2
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake

- nanodbc `2.12.4-4` -> `2.12.4-5`
    - [(#9185)](https://github.com/microsoft/vcpkg/pull/9185) [nanodbc] Set NANODBC_ENABLE_UNICODE to OFF

- libevent `2.1.11-1` -> `2.1.11-2`
    - [(#9101)](https://github.com/microsoft/vcpkg/pull/9101) [libevent] Add thread as default feature

- directxtk12 `oct2019` -> `dec2019`
    - [(#9382)](https://github.com/microsoft/vcpkg/pull/9382) [directxtk12] Update to dec2019 release

- directxtex `oct2019` -> `dec2019`
    - [(#9383)](https://github.com/microsoft/vcpkg/pull/9383) [directxtex] Update to dec2019 release

- directxmesh `aug2019` -> `dec2019`
    - [(#9384)](https://github.com/microsoft/vcpkg/pull/9384) [directxmesh] Update to dec2019 release

- directxtk `oct2019` -> `dec2019`
    - [(#9381)](https://github.com/microsoft/vcpkg/pull/9381) [directxtk] Update to dec2019 release

- nano-signal-slot `2018-08-25-1` -> `2.0.1`
    - [(#9376)](https://github.com/microsoft/vcpkg/pull/9376) [nano-signal-slot] Update to latest version

- libarchive `3.4.0-1` -> `3.4.0-2`
    - [(#9411)](https://github.com/microsoft/vcpkg/pull/9411) [vcpkg-baseline] Fixes for vtk, libarchive, xalan-c, and openvpn3 on Linux

- openvpn3 `3.4.1` -> `3.4.1-1`
    - [(#9411)](https://github.com/microsoft/vcpkg/pull/9411) [vcpkg-baseline] Fixes for vtk, libarchive, xalan-c, and openvpn3 on Linux

- ffmpeg `4.2-1` -> `4.2-2`
    - [(#9405)](https://github.com/microsoft/vcpkg/pull/9405) [ffmpeg] portfile: fix typo Relase->Release
    - [(#9090)](https://github.com/microsoft/vcpkg/pull/9090) [ffmpeg] install correct copyright file and enable (L)GPLv3 builds

- entt `3.1.1` -> `3.2.2`
    - [(#9409)](https://github.com/microsoft/vcpkg/pull/9409) [entt] Upgrade library to 3.2.2

- doctest `2.3.5` -> `2.3.6`
    - [(#9403)](https://github.com/microsoft/vcpkg/pull/9403) [doctest] Update library to 2.3.6

- qcustomplot `2.0.1-1` -> `2.0.1-3`
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake

- qscintilla `2.10-9` -> `2.10-11`
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake

- qt5-base `5.12.5-3` -> `5.12.5-7`
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake

- qwt `6.1.3-8` -> `6.1.3-10`
    - [(#9412)](https://github.com/microsoft/vcpkg/pull/9412) [vcpkg_install_qmake] Add vcpkg_install_qmake

- hiredis `2019-11-1` -> `2019-11-2`
    - [(#9388)](https://github.com/microsoft/vcpkg/pull/9388) [hiredis] Support building static

- argparse `2.0.1` -> `2.1`
    - [(#9291)](https://github.com/microsoft/vcpkg/pull/9291) [argparse] Upgrade to v2.1

- angle `2019-07-19-3` -> `2019-07-19-4`
    - [(#7923)](https://github.com/microsoft/vcpkg/pull/7923) [angle]Fix windows build error: cannot find definition far.

- libwebp `1.0.2-7` -> `1.0.2-8`
    - [(#9300)](https://github.com/microsoft/vcpkg/pull/9300) [libwebp] Fixed build error ARM64 Windows 10

- libpng `1.6.37-5` -> `1.6.37-6`
    - [(#9198)](https://github.com/microsoft/vcpkg/pull/9198) [libpng] Strong cleanup of the port

- libgit2 `0.28.3` -> `0.28.4`
    - [(#9270)](https://github.com/microsoft/vcpkg/pull/9270) [libgit2] Update to 0.28.4

- embree3 `3.5.2-3` -> `3.6.1`
    - [(#9073)](https://github.com/microsoft/vcpkg/pull/9073) [embree3] Update to version 3.6.1

- pmdk `1.7` -> `1.7-1`
    - [(#9094)](https://github.com/microsoft/vcpkg/pull/9094) [pmdk] Remove non-ascii charactor

- fftwpp `2.05` -> `2019-12-19`
    - [(#9169)](https://github.com/microsoft/vcpkg/pull/9169) [fftwpp] Update to latest commit

- freerdp `2.0.0-rc4-2` -> `2.0.0-rc4-3`
    - [(#9176)](https://github.com/microsoft/vcpkg/pull/9176) [freerdp] Fix linux build, add dependency port glib

- abseil `2019-05-08-1` -> `2019-12-19`
    - [(#9367)](https://github.com/microsoft/vcpkg/pull/9367) [abseil] Update to the latest and fix link failure error using StrCat

- sdl2-gfx `1.0.4-2` -> `1.0.4-4`
    - [(#9319)](https://github.com/microsoft/vcpkg/pull/9319) [sdl2-gfx] Update CMake build and find_package support

- io2d `2019-07-11-1` -> `2019-07-11-2`
    - [(#8935)](https://github.com/microsoft/vcpkg/pull/8935) [io2d] Fix link to target "Cairo::Cairo" error

- vtk `8.2.0-9` -> `8.2.0-10`
    - [(#9389)](https://github.com/microsoft/vcpkg/pull/9389) Remove vtk:x64-linux result in baseline

</details>

-- vcpkg team vcpkg@microsoft.com TUE, 09 Jan 05:45:00 -0800

vcpkg (2019.11.30)
---
#### Total port count: 1262
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|**x64-windows**|1182|
|x86-windows|1163|
|x64-windows-static|1094|
|**x64-linux**|1021|
|**x64-osx**|984|
|arm64-windows|782|
|x64-uwp|646|
|arm-uwp|614|

#### The following commands and options have been updated:
- `export`
    - `--x-chocolatey` ***[NEW OPTION]*** : Experimental option to export a port as a `chocolatey` package
        - [(#6891)](https://github.com/microsoft/vcpkg/pull/6891) [feature] add `vcpkg export --x-chocolatey` support

#### The following documentation has been updated:
- [vcpkg_from_github](docs/maintainers/vcpkg_from_github.md)
    - [(#5719)](https://github.com/microsoft/vcpkg/pull/5719) [vcpkg_from_github] Allow targeting Github Enterprise instances
- [Privacy and Vcpkg](docs/about/privacy.md)
    - [(#9080)](https://github.com/microsoft/vcpkg/pull/9080) [vcpkg] update telemetry

#### The following additional changes have been made to vcpkg's infrastructure:
- [(#8853)](https://github.com/microsoft/vcpkg/pull/8853) Add October changelog
- [(#8894)](https://github.com/microsoft/vcpkg/pull/8894) Update README.md
- [(#8976)](https://github.com/microsoft/vcpkg/pull/8976) [libusb] upgrade and support arm64-windows
- [(#8924)](https://github.com/microsoft/vcpkg/pull/8924) [vcpkg] Remove libc++fs link dependency for clang/libc++ 9.*
- [(#7598)](https://github.com/microsoft/vcpkg/pull/7598) [vcpkg] QoL: add host specific path separator to common definitions
- [(#8941)](https://github.com/microsoft/vcpkg/pull/8941) [docs] Add the gcc+=7 prerequisite to the README
- [(#5719)](https://github.com/microsoft/vcpkg/pull/5719) [vcpkg_from_github] Allow targeting Github Enterprise instances
- [(#9080)](https://github.com/microsoft/vcpkg/pull/9080) [vcpkg] update telemetry

<details>
<summary><b>The following 12 ports have been added:</b></summary>

|port|version|
|---|---|
|[ogre-next](https://github.com/microsoft/vcpkg/pull/8677)| 2019-10-20
|[hiredis](https://github.com/microsoft/vcpkg/pull/8843)<sup>[#8862](https://github.com/microsoft/vcpkg/pull/8862) </sup>| 2019-11-1
|[cspice](https://github.com/microsoft/vcpkg/pull/8859)| 66-1
|[ecos](https://github.com/microsoft/vcpkg/pull/9019)| 2.0.7
|[redis-plus-plus](https://github.com/microsoft/vcpkg/pull/8846)| 1.1.1
|[nanoflann](https://github.com/microsoft/vcpkg/pull/8962)| 1.3.1
|[wxchartdir](https://github.com/microsoft/vcpkg/pull/7914)| 1.0.0
|[faad2](https://github.com/microsoft/vcpkg/pull/9003)| 2.9.1-1
|[pfring](https://github.com/microsoft/vcpkg/pull/8648)| 2019-10-17
|[libmodman](https://github.com/microsoft/vcpkg/pull/8931)| 2.0.1
|[libproxy](https://github.com/microsoft/vcpkg/pull/8931)| 0.4.15
|[google-cloud-cpp-spanner](https://github.com/microsoft/vcpkg/pull/9096)| 0.3.0
</details>

<details>
<summary><b>The following 67 ports have been updated:</b></summary>

- tbb `2019_U8-1` -> `2019_U8-2`
    - [(#8744)](https://github.com/microsoft/vcpkg/pull/8744) tbb: Fix compilation on OSX

- openvpn3 `2018-03-21-1` -> `3.4.1`
    - [(#8851)](https://github.com/microsoft/vcpkg/pull/8851) openvpn3: bump version

- sqlpp11 `0.58-2` -> `0.58-3`
    - [(#8837)](https://github.com/microsoft/vcpkg/pull/8837) [sqlpp11] fixed ddl2cpp path

- jsonnet `0.13.0` -> `0.14.0`
    - [(#8848)](https://github.com/microsoft/vcpkg/pull/8848) [jsonnet]Upgrade to 0.14.0.

- pango `1.40.11-4` -> `1.40.11-5`
    - [(#8745)](https://github.com/microsoft/vcpkg/pull/8745) [pango] Add missing link library

- opencv3 `3.4.7-2` -> `3.4.8`
    - [(#8623)](https://github.com/microsoft/vcpkg/pull/8623) [opencv3] Upgrade to version 3.4.8
    - [(#8911)](https://github.com/microsoft/vcpkg/pull/8911) Revert "[opencv3] Upgrade to version 3.4.8"

- boost-modular-build-helper `1.70.0-2` -> `1.71.0`
    - [(#8606)](https://github.com/microsoft/vcpkg/pull/8606) [boost-modular-build-helper] Update to 1.71.

- libxslt `1.1.33-4` -> `1.1.33-5`
    - [(#9014)](https://github.com/microsoft/vcpkg/pull/9014) Prevent python3 build failure

- python3 `3.7.3` -> `3.7.4`
    - [(#9014)](https://github.com/microsoft/vcpkg/pull/9014) Prevent python3 build failure

- orc `1.5.6-1` -> `1.5.7`
    - [(#8980)](https://github.com/microsoft/vcpkg/pull/8980) [orc]Upgrade to 1.5.7, disable tzdata test.

- openvdb `6.1.0` -> `6.2.1`
    - [(#8979)](https://github.com/microsoft/vcpkg/pull/8979) [openvdb]Upgrade to 6.2.1

- libusb `1.0.22-4` -> `1.0.23`
    - [(#8976)](https://github.com/microsoft/vcpkg/pull/8976) [libusb] upgrade and support arm64-windows

- libmad `0.15.1-4` -> `0.15.1-5`
    - [(#8959)](https://github.com/microsoft/vcpkg/pull/8959) [libmad] Fix libmad header for non-x86 MSVC targets

- wil `2019-07-16` -> `2019-11-07`
    - [(#8948)](https://github.com/microsoft/vcpkg/pull/8948) Update WIL port

- botan `2.11.0` -> `2.12.1`
    - [(#8844)](https://github.com/microsoft/vcpkg/pull/8844) [botan]Upgrade to 2.12.1

- libbson `1.14.0-3` -> `1.15.1-1`
    - [(#8790)](https://github.com/microsoft/vcpkg/pull/8790) [libbson][mongo-c-driver] Update to 1.15.1. Parse CONTROL file for version number

- mongo-c-driver `1.14.0-5` -> `1.15.1-1`
    - [(#8790)](https://github.com/microsoft/vcpkg/pull/8790) [libbson][mongo-c-driver] Update to 1.15.1. Parse CONTROL file for version number

- libpopt `1.16-11` -> `1.16-12`
    - [(#8652)](https://github.com/microsoft/vcpkg/pull/8652) [libpopt]Fix linux build.

- libpng `1.6.37-4` -> `1.6.37-5`
    - [(#8622)](https://github.com/microsoft/vcpkg/pull/8622) [lipng/libpng-apng]Remove port libpng-apng and add apng as a feature with libpng.
    - [(#8716)](https://github.com/microsoft/vcpkg/pull/8716) [libpng] Fix CMake targets

- evpp `0.7.0-1` -> `0.7.0-2`
    - [(#8349)](https://github.com/microsoft/vcpkg/pull/8349) [libevent] add features

- libevent `2.1.11` -> `2.1.11-1`
    - [(#8349)](https://github.com/microsoft/vcpkg/pull/8349) [libevent] add features

- restinio `0.6.0.1` -> `0.6.1`
    - [(#8993)](https://github.com/microsoft/vcpkg/pull/8993) [restinio] Update to v.0.6.1

- google-cloud-cpp-common `0.15.0` -> `0.16.0-1`
    - [(#8986)](https://github.com/microsoft/vcpkg/pull/8986) [google-cloud-cpp*] Update to 0.16.0
    - [(#9097)](https://github.com/microsoft/vcpkg/pull/9097) [google-cloud-cpp-common] Add test feature

- google-cloud-cpp `0.14.0-1` -> `0.15.0`
    - [(#8986)](https://github.com/microsoft/vcpkg/pull/8986) [google-cloud-cpp*] Update to 0.16.0

- freetype-gl `2019-03-29-2` -> `2019-03-29-3`
    - [(#8992)](https://github.com/microsoft/vcpkg/pull/8992) [freetype-gl] Fix POST_BUILD_CHECKS_FAILED failure on Unix

- tinyobjloader `1.0.7-1` -> `2.0.0-rc2`
    - [(#8955)](https://github.com/microsoft/vcpkg/pull/8955) [tinyobjloader] Update to 2.0.0-rc2; Add feature to enable double precision

- libzip `rel-1-5-2` -> `rel-1-5-2--1`
    - [(#8918)](https://github.com/microsoft/vcpkg/pull/8918) [libzip] Fix patch not applying

- tgui `0.8.5` -> `0.8.6`
    - [(#8877)](https://github.com/microsoft/vcpkg/pull/8877) [tgui]Update to 0.8.6

- jsoncons `0.136.1` -> `0.139.0`
    - [(#9058)](https://github.com/microsoft/vcpkg/pull/9058) [jsoncons] Update to v0.139.0

- azure-iot-sdk-c `2019-10-11.2` -> `2019-11-21.1`
    - [(#9059)](https://github.com/microsoft/vcpkg/pull/9059) [azure-iot-sdk-c] Update public-preview feature to branch with fixed telemetry

- tiff `4.0.10-7` -> `4.0.10-8`
    - [(#9010)](https://github.com/microsoft/vcpkg/pull/9010) [tiff] Make BUILD_TOOLS option a feature

- magic-enum `0.6.3` -> `0.6.3-1`
    - [(#9007)](https://github.com/microsoft/vcpkg/pull/9007) [magic-enum] Fix export config.cmake issue

- libflac `1.3.2-6` -> `1.3.3`
    - [(#8988)](https://github.com/microsoft/vcpkg/pull/8988) [libflac] Update libflac to 1.3.3

- otl `4.0.447` -> `4.0.448`
    - [(#8937)](https://github.com/microsoft/vcpkg/pull/8937) [otl] Upgrade to version 4.0.448

- librtmp `2.4-2` -> `2019-11-11`
    - [(#8958)](https://github.com/microsoft/vcpkg/pull/8958) use latest librtmp

- stlab `1.4.1-1` -> `1.5.1`
    - [(#8901)](https://github.com/microsoft/vcpkg/pull/8901) [stlab] Update to 1.5.1

- bitsery `5.0.0` -> `5.0.1-1`
    - [(#8892)](https://github.com/microsoft/vcpkg/pull/8892) [bitsery] Update to 5.0.1

- cereal `1.2.2-2` -> `1.3.0`
    - [(#8913)](https://github.com/microsoft/vcpkg/pull/8913) [cereal] Update to 1.3.0

- fizz `2019.07.08.00` -> `2019.10.28.00`
    - [(#8765)](https://github.com/microsoft/vcpkg/pull/8765) [folly/fizz]Upgrade version.

- folly `2019.06.17.00` -> `2019.10.21.00`
    - [(#8765)](https://github.com/microsoft/vcpkg/pull/8765) [folly/fizz]Upgrade version.

- qt5-base `5.12.5-1` -> `5.12.5-3`
    - [(#8793)](https://github.com/microsoft/vcpkg/pull/8793) [qt5] Modify qtdeploy to include qtquickshapes
    - [(#8932)](https://github.com/microsoft/vcpkg/pull/8932) [qt5-base] Add option to link to OpenSSL at compile-time

- nlohmann-json `3.7.0` -> `3.7.3`
    - [(#9069)](https://github.com/microsoft/vcpkg/pull/9069) [nlohmann-json] Upgrade to 3.7.3

- json-dto `0.2.8-2` -> `0.2.9.2`
    - [(#9057)](https://github.com/microsoft/vcpkg/pull/9057) [json-dto] Update to v0.2.9; Switch repo; Fix license installation
    - [(#9083)](https://github.com/microsoft/vcpkg/pull/9083) [json_dto] Update to v.0.2.9.2

- prometheus-cpp `0.7.0` -> `0.8.0`
    - [(#9047)](https://github.com/microsoft/vcpkg/pull/9047) [prometheus-cpp] Update to version 0.8.0

- date `2019-09-09` -> `2019-11-08`
    - [(#9006)](https://github.com/microsoft/vcpkg/pull/9006) [date] Update to 2019-11-08

- netcdf-cxx4 `4.3.0-5` -> `4.3.1`
    - [(#8978)](https://github.com/microsoft/vcpkg/pull/8978) [netcdf-cxx4] Update to 4.3.1

- libsodium `1.0.18-1` -> `1.0.18-2`
    - [(#8974)](https://github.com/microsoft/vcpkg/pull/8974) [libsodium] Fix CPU feature not properly detected on Linux

- cgal `4.14-3` -> `5.0`
    - [(#8659)](https://github.com/microsoft/vcpkg/pull/8659) [cgal][openmvs] CGAL: Upgrade to 5.0

- openmvs `1.0-2` -> `1.0-3`
    - [(#8659)](https://github.com/microsoft/vcpkg/pull/8659) [cgal][openmvs] CGAL: Upgrade to 5.0

- ace `6.5.6` -> `6.5.7`
    - [(#9074)](https://github.com/microsoft/vcpkg/pull/9074) [ace] Upgrade to 6.5.7

- libmspack `0.10.1-2` -> `0.10.1-3`
    - [(#8966)](https://github.com/microsoft/vcpkg/pull/8966) [libmspack] Fix several missing imports

- mdnsresponder `765.30.11-1` -> `765.30.11-2`
    - [(#8953)](https://github.com/microsoft/vcpkg/pull/8953) [mdnsresponder] Fix build with dynamic CRT

- detours `4.0.1` -> `4.0.1-1`
    - [(#8854)](https://github.com/microsoft/vcpkg/pull/8854) [detours] Update for vcpkg_build_nmake

- curlpp `2018-06-15-1` -> `2018-06-15-2`
    - [(#9065)](https://github.com/microsoft/vcpkg/pull/9065) [curlpp] Restore installing vcpkg-cmake-wrapper script

- portaudio `2019-09-30` -> `2019-11-5`
    - [(#8944)](https://github.com/microsoft/vcpkg/pull/8944) [portaudio] Fix library cannot be found

- wt `4.0.5-1` -> `4.1.1`
    - [(#8903)](https://github.com/microsoft/vcpkg/pull/8903) [wt] Update to 4.1.1

- z3 `4.8.5-1` -> `4.8.6`
    - [(#8899)](https://github.com/microsoft/vcpkg/pull/8899) [z3] Update to 4.8.6

- pdcurses `3.8-1` -> `3.8-2`
    - [(#9042)](https://github.com/microsoft/vcpkg/pull/9042) [pdcurses] Fix linkage error

- angle `2019-07-19-2` -> `2019-07-19-3`
    - [(#8785)](https://github.com/microsoft/vcpkg/pull/8785) [angle] Add option /bigobj to compiler

- argparse `1.9` -> `2.0.1`
    - [(#9088)](https://github.com/microsoft/vcpkg/pull/9088) [argparse] Update library to 2.0.1

- catch2 `2.10.1-1` -> `2.11.0`
    - [(#9089)](https://github.com/microsoft/vcpkg/pull/9089) [catch2] Update library to 2.11.0

- magnum-plugins `2019.10` -> `2019.10-1`
    - [(#8939)](https://github.com/microsoft/vcpkg/pull/8939)  [magnum-plugins] Fix basisimporter/basisimageconverter features

- spdlog `1.3.1-2` -> `1.4.2`
    - [(#8779)](https://github.com/microsoft/vcpkg/pull/8779) [spdlog]Update  to 1.4.2

- assimp `5.0.0-1` -> `5.0.0-2`
    - [(#9075)](https://github.com/microsoft/vcpkg/pull/9075) [minizip, assimp] Export minizip CMake targets; Add minizip as assimp dependency

- minizip `1.2.11-5` -> `1.2.11-6`
    - [(#9075)](https://github.com/microsoft/vcpkg/pull/9075) [minizip, assimp] Export minizip CMake targets; Add minizip as assimp dependency

- ixwebsocket `6.1.0` -> `7.4.0`
    - [(#9099)](https://github.com/microsoft/vcpkg/pull/9099) [ixwebsocket] Update to 7.4.0

- ppconsul `0.3-1` -> `0.4`
    - [(#9104)](https://github.com/microsoft/vcpkg/pull/9104) [ppconsul] Update to 0.4

</details>

-- vcpkg team vcpkg@microsoft.com TUE, 03 Dec 14:30:00 -0800

vcpkg (2019.10.31)
---
#### Total port count: 1250
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|**x64-windows**|1169|
|x86-windows|1154|
|x64-windows-static|1080|
|**x64-linux**|1014|
|**x64-osx**|976|
|arm64-windows|774|
|x64-uwp|638|
|arm-uwp|608|

#### The following commands and options have been updated:
- `create`
    - Port template updated with best practices, new CMake variables, `CONTROL` homepage field and example feature entries, links to relevant documentation, and maintainer function usage examples
        - [(#8427)](https://github.com/microsoft/vcpkg/pull/8427) Update vcpkg create template
        - [(#8488)](https://github.com/microsoft/vcpkg/pull/8488) update templates.

#### The following documentation has been updated:
- [vcpkg_fixup_cmake_targets](docs/maintainers/cmake_fixup_cmake_targets.md) ***[NEW]***
    - [(#8365)](https://github.com/microsoft/vcpkg/pull/8365) [Documentation] Added documentation page for vcpkg_fixup_cmake_targets.cmake
    - [(#8424)](https://github.com/microsoft/vcpkg/pull/8424) [Documentation] Update and rename cmake_fixup_cmake_targets.md to vcpkg_fixup_cmake_t…
- [vcpkg_build_make](docs/maintainers/vcpkg_build_make.md) ***[NEW]***
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
- [vcpkg_build_nmake](docs/maintainers/vcpkg_build_nmake.md) ***[NEW]***
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
    - [(#8589)](https://github.com/microsoft/vcpkg/pull/8589) [libxslt]Using vcpkg_install_nmake in Windows, support unix.
- [vcpkg_configure_make](docs/maintainers/vcpkg_configure_make.md) ***[NEW]***
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
    - [(#8647)](https://github.com/microsoft/vcpkg/pull/8647) support SKIP_CONFIGURE in vcpkg_configure_make.
- [vcpkg_install_make](docs/maintainers/vcpkg_install_make.md) ***[NEW]***
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
- [vcpkg_install_nmake](docs/maintainers/vcpkg_install_nmake.md) ***[NEW]***
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
    - [(#8589)](https://github.com/microsoft/vcpkg/pull/8589) [libxslt]Using vcpkg_install_nmake in Windows, support unix.
- [Chinese README](README_zh_CN.md) ***[NEW]***
    - [(#8476)](https://github.com/microsoft/vcpkg/pull/8476) Add Chinese readme.
- [Portfile Helper Functions](docs/maintainers/portfile-functions.md)
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
- [Maintainer Guidelines and Policies](docs/maintainers/maintainer-guide.md)
    - [(#8720)](https://github.com/microsoft/vcpkg/pull/8720) maintainer-guide.md - Fix link

#### The following *remarkable* changes have been made to vcpkg's infrastructure:
- New maintainer `portfile.cmake` helper functions for finer control over configuring/building/installing with `make` and `nmake`
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
    - [(#8540)](https://github.com/microsoft/vcpkg/pull/8540) Fix separate make and install execution error issue.
    - [(#8589)](https://github.com/microsoft/vcpkg/pull/8589) [libxslt]Using vcpkg_install_nmake in Windows, support unix.
    - [(#8610)](https://github.com/microsoft/vcpkg/pull/8610) Add AUTOCONF support with vcpkg_configure_make in Windows.
    - [(#8647)](https://github.com/microsoft/vcpkg/pull/8647) support SKIP_CONFIGURE in vcpkg_configure_make.
- Support for the `go` compiler in `vcpkg_find_acquire_program`
    - [(#8440)](https://github.com/microsoft/vcpkg/pull/8440) Add go to vcpkg_find_acquire_program

#### The following *additional* changes have been made to vcpkg's infrastructure:
- [(#8365)](https://github.com/microsoft/vcpkg/pull/8365) [Documentation] Added documentation page for vcpkg_fixup_cmake_targets.cmake
- [(#8418)](https://github.com/microsoft/vcpkg/pull/8418) Add September changelog
- [(#8435)](https://github.com/microsoft/vcpkg/pull/8435) Find default for text/plain on Linux and Windows (#567)
- [(#8489)](https://github.com/microsoft/vcpkg/pull/8489) Fix option -j
- [(#8580)](https://github.com/microsoft/vcpkg/pull/8580) Fix CMake checks for Apple Clang 11.0 on macOS 10.15
- [(#8638)](https://github.com/microsoft/vcpkg/pull/8638) Fix compile error in Visual Studio 2017 15.1
- [(#8669)](https://github.com/microsoft/vcpkg/pull/8669) [vcpkg_download_distfile.cmake] Fix Examples
- [(#8667)](https://github.com/microsoft/vcpkg/pull/8667) vcpkg_configure_meson - Remove compiler flag /Oi
- [(#8639)](https://github.com/microsoft/vcpkg/pull/8639) mesonbuild - Update to 0.52.0

<details>
<summary><b>The following 24 ports have been added:</b></summary>

|port|version|
|---|---|
|[cpp-base64](https://github.com/microsoft/vcpkg/pull/8368)| 2019-06-19
|[mgnlibs](https://github.com/microsoft/vcpkg/pull/8390)| 2019-09-29
|[mmx](https://github.com/microsoft/vcpkg/pull/8384)| 2019-09-29
|[kcp](https://github.com/microsoft/vcpkg/pull/8278)| 2019-09-20
|[dbow3](https://github.com/microsoft/vcpkg/pull/8547)| 1.0.0
|[nlohmann-fifo-map](https://github.com/microsoft/vcpkg/pull/8458)| 2018.05.07
|[libcrafter](https://github.com/microsoft/vcpkg/pull/8568)| 0.3
|[libudns](https://github.com/microsoft/vcpkg/pull/8572)| 0.4
|[ffnvcodec](https://github.com/microsoft/vcpkg/pull/8559)| 9.1.23.0
|[bfgroup-lyra](https://github.com/microsoft/vcpkg/pull/8612)| 1.1
|[google-cloud-cpp-common](https://github.com/microsoft/vcpkg/pull/8735)| 0.15.0
|[libsrt](https://github.com/microsoft/vcpkg/pull/8712)| 1.3.4
|[polyhook2](https://github.com/microsoft/vcpkg/pull/8719)| 2019-10-24
|[tool-meson](https://github.com/microsoft/vcpkg/pull/8639)| 0.52.0
|[slikenet](https://github.com/microsoft/vcpkg/pull/8693)| 2019-10-22
|[libigl](https://github.com/microsoft/vcpkg/pull/8607)| 2.1.0-1
|[libmesh](https://github.com/microsoft/vcpkg/pull/8592)| 1.5.0
|[upb](https://github.com/microsoft/vcpkg/pull/8681)| 2019-10-21
|[opencensus-cpp](https://github.com/microsoft/vcpkg/pull/8740)| 0.4.0
|[openscap](https://github.com/microsoft/vcpkg/pull/8654)| 1.3.1
|[fftwpp](https://github.com/microsoft/vcpkg/pull/8625)| 2.05
|[ois](https://github.com/microsoft/vcpkg/pull/8507)| 1.5
|[libdivide](https://github.com/microsoft/vcpkg/pull/8320)| 3.0
|[wordnet](https://github.com/microsoft/vcpkg/pull/8816)| 3.0
</details>

<details>
<summary><b>The following 151 ports have been updated:</b></summary>

- kangaru `4.2.0` -> `4.2.1`
    - [(#8414)](https://github.com/microsoft/vcpkg/pull/8414) [kangaru] Update library to 4.2.1

- magic-enum `0.6.0` -> `0.6.3`
    - [(#8431)](https://github.com/microsoft/vcpkg/pull/8431) [magic_enum] Update to 0.6.1. Add HEAD_REF
    - [(#8500)](https://github.com/microsoft/vcpkg/pull/8500) [magic-enum] Update to 0.6.2
    - [(#8656)](https://github.com/microsoft/vcpkg/pull/8656) [magic-enum] Update to 0.6.3

- json5-parser `1.0.0` -> `1.0.0-1`
    - [(#8401)](https://github.com/microsoft/vcpkg/pull/8401) [json5-parser] fix find_package issue

- reproc `8.0.1` -> `9.0.0`
    - [(#8411)](https://github.com/microsoft/vcpkg/pull/8411) Update reproc to 9.0.0.

- libfabric `1.8.0` -> `1.8.1`
    - [(#8415)](https://github.com/microsoft/vcpkg/pull/8415) [libfabric] Update library to 1.8.1

- thrift `2019-05-07-3` -> `2019-05-07-4`
    - [(#8410)](https://github.com/microsoft/vcpkg/pull/8410) [thrift]fix-paths

- grpc `1.23.0` -> `1.23.1-1`
    - [(#8438)](https://github.com/microsoft/vcpkg/pull/8438) [grpc] Update grpc to 1.23.1
    - [(#8737)](https://github.com/microsoft/vcpkg/pull/8737) [grpc]Fix build failure in Linux: duplicate function gettid.

- protobuf `3.9.1` -> `3.10.0`
    - [(#8439)](https://github.com/microsoft/vcpkg/pull/8439) [protobuf] Update protobuf to 3.10.0

- google-cloud-cpp `0.13.0` -> `0.14.0`
    - [(#8441)](https://github.com/microsoft/vcpkg/pull/8441) [google-cloud-cpp] Update to v0.14.0

- nrf-ble-driver `4.1.1` -> `4.1.1-1`
    - [(#8437)](https://github.com/microsoft/vcpkg/pull/8437) [nrf-ble-driver] Fix version number

- plplot `5.13.0-2` -> `5.13.0-3`
    - [(#8405)](https://github.com/microsoft/vcpkg/pull/8405) fix find_package(wxWidgets) issue in release build

- freexl `1.0.4-2` -> `1.0.4-8`
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
    - [(#8489)](https://github.com/microsoft/vcpkg/pull/8489) Fix option -j
    - [(#8540)](https://github.com/microsoft/vcpkg/pull/8540) Fix separate make and install execution error issue.

- libosip2 `5.1.0` -> `5.1.0-1`
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake

- x264 `157-303c484ec828ed0-2` -> `157-303c484ec828ed0-6`
    - [(#8267)](https://github.com/microsoft/vcpkg/pull/8267) Add function vcpkg_configure_make/vcpkg_build_make/vcpkg_install_make/vcpkg_build_nmake/vcpkg_install_nmake
    - [(#8489)](https://github.com/microsoft/vcpkg/pull/8489) Fix option -j
    - [(#8540)](https://github.com/microsoft/vcpkg/pull/8540) Fix separate make and install execution error issue.

- qt5-tools `5.12.5-1` -> `5.12.5-2`
    - [(#8373)](https://github.com/microsoft/vcpkg/pull/8373) [qt5-tools] change control file so activeqt isn't a dependency on non windows

- metis `5.1.0-5` -> `5.1.0-6`
    - [(#8376)](https://github.com/microsoft/vcpkg/pull/8376) [metis][suitesparse] add metisConfig.cmake

- suitesparse `5.4.0-3` -> `5.4.0-4`
    - [(#8376)](https://github.com/microsoft/vcpkg/pull/8376) [metis][suitesparse] add metisConfig.cmake

- activemq-cpp `3.9.5` -> `3.9.5-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- alac-decoder `0.2-1` -> `0.2-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- angelscript `2.33.1-1` -> `2.34.0`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply
    - [(#8520)](https://github.com/microsoft/vcpkg/pull/8520) [angelscript] Upgrade to version 2.34.0

- anyrpc `2017-12-01` -> `2017-12-01-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- apr-util `1.6.0-3` -> `1.6.0-5`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- apr `1.6.5-2` -> `1.6.5-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- argtable2 `2.13-2` -> `2.13-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- atk `2.24.0-4` -> `2.24.0-5`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- atkmm `2.24.2-1` -> `2.24.2-2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- aubio `0.4.9` -> `0.4.9-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- azure-c-shared-utility `2019-08-20.1` -> `2019-10-07.2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- berkeleydb `4.8.30-2` -> `4.8.30-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- bigint `2010.04.30-3` -> `2010.04.30-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- blaze `3.6` -> `3.6-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- bond `8.1.0-2` -> `8.1.0-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- boost-di `1.1.0` -> `1.1.0-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- butteraugli `2019-05-08` -> `2019-05-08-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- cairomm `1.15.3-3` -> `1.15.3-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- cartographer `1.0.0-1` -> `1.0.0-2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- ccd `2.1-1` -> `2.1-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- ccfits `2.5-3` -> `2.5-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- cfitsio `3.410-2` -> `3.410-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- charls `2.0.0-2` -> `2.0.0-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- chmlib `0.40-3` -> `0.40-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- clblas `2.12-2` -> `2.12-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- clblast `1.5.0` -> `1.5.0-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- clfft `2.12.2-1` -> `2.12.2-2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- collada-dom `2.5.0-2` -> `2.5.0-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- console-bridge `0.4.3-1` -> `0.4.3-2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- cppkafka `0.3.1-1` -> `0.3.1-2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- cppunit `1.14.0` -> `1.14.0-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- cunit `2.1.3-2` -> `2.1.3-3`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- dlfcn-win32 `1.1.1-3` -> `1.1.1-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- dmlc `2019-08-12` -> `2019-08-12-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- duktape `2.4.0-4` -> `2.4.0-6`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply
    - [(#8767)](https://github.com/microsoft/vcpkg/pull/8767) [duktape] fix pip and pyyaml install issue

- entityx `1.3.0-1` -> `1.3.0-2`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- epsilon `0.9.2` -> `0.9.2-1`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- fcl `0.5.0-6` -> `0.5.0-7`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- flint `2.5.2-3` -> `2.5.2-4`
    - [(#8087)](https://github.com/microsoft/vcpkg/pull/8087) [vcpkg] fatal_error when patch fails to apply

- nameof `2019-07-13` -> `0.9.2`
    - [(#8464)](https://github.com/microsoft/vcpkg/pull/8464) [nameof] Update to 0.9.1
    - [(#8671)](https://github.com/microsoft/vcpkg/pull/8671) [nameof] Update to 0.9.2

- gsl-lite `0.28.0` -> `0.34.0`
    - [(#8465)](https://github.com/microsoft/vcpkg/pull/8465) [gsl-lite] Update to v0.34.0

- libffi `3.1-5` -> `3.1-6`
    - [(#8162)](https://github.com/microsoft/vcpkg/pull/8162) [libffi] Add support for CMake config

- mathgl `2.4.3-2` -> `2.4.3-3`
    - [(#8369)](https://github.com/microsoft/vcpkg/pull/8369) [mathgl]Fix feature glut/hdf5/qt5.

- yoga `1.14.0` -> `1.16.0-1`
    - [(#8495)](https://github.com/microsoft/vcpkg/pull/8495) [yoga] Add project declaration and fix linux installation.
    - [(#8630)](https://github.com/microsoft/vcpkg/pull/8630) [yoga] Update to 1.16.0 and enabled UWP builds

- openssl-windows `1.0.2s-1` -> `1.0.2s-2`
    - [(#8224)](https://github.com/microsoft/vcpkg/pull/8224) Including config file openssl.cnf in installation.

- liblas `1.8.1-2` -> `1.8.1-3`
    - [(#7920)](https://github.com/microsoft/vcpkg/pull/7920) [liblas]Fix ${_IMPORT_PREFIX} in liblas-depends-*.cmake.
    - [(#7917)](https://github.com/microsoft/vcpkg/pull/7917) [proj4]Upgrade version to 6.1.1 and remove useless patches.

- azure-storage-cpp `6.1.0-2` -> `7.0.0`
    - [(#8499)](https://github.com/microsoft/vcpkg/pull/8499) [azure-storage-cpp]Upgrade to 7.0.0

- sdl2-mixer `2.0.4-6` -> `2.0.4-7`
    - [(#8496)](https://github.com/microsoft/vcpkg/pull/8496) [sdl2-mixer]Fix usage issue.

- armadillo `2019-04-16-5` -> `2019-04-16-6`
    - [(#8494)](https://github.com/microsoft/vcpkg/pull/8494) [armadillo]Fix cmake path.

- restinio `0.6.0` -> `0.6.0.1`
    - [(#8493)](https://github.com/microsoft/vcpkg/pull/8493) [restinio] updated to v.0.6.0.1

- ode `0.15.1-3` -> `0.16`
    - [(#8485)](https://github.com/microsoft/vcpkg/pull/8485) [ode] Upgrade to 0.16

- itk `5.0.1-1` -> `5.0.1-2`
    - [(#8501)](https://github.com/microsoft/vcpkg/pull/8501) [itk]Fix use 64 bit ids.

- irrlicht `1.8.4-2` -> `1.8.4-4`
    - [(#8505)](https://github.com/microsoft/vcpkg/pull/8505) [irrlicht] Reorder link libraries
    - [(#8535)](https://github.com/microsoft/vcpkg/pull/8535) [irrlicht] do not build exisiting dependencies

- azure-iot-sdk-c `2019-08-20.1` -> `2019-10-11.2`
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8565)](https://github.com/microsoft/vcpkg/pull/8565) azure-iot-sdk-c for release of 2019-10-10
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- azure-macro-utils-c `2019-08-20.1` -> `2019-10-07.2`
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- azure-uamqp-c `2019-08-20.1` -> `2019-10-07.2`
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- azure-uhttp-c `2019-08-20.1` -> `2019-10-07.2`
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- azure-umqtt-c `2019-08-20.1` -> `2019-10-07.2`
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- umock-c `2019-08-20.1` -> `2019-10-07.2`
    - [(#8513)](https://github.com/microsoft/vcpkg/pull/8513) [azure] Update azure-iot-sdk-c for release of 2019-10-07
    - [(#8686)](https://github.com/microsoft/vcpkg/pull/8686) [azure] Update azure-iot-sdk-c for 07/2019 LTS refresh
    - [(#8731)](https://github.com/microsoft/vcpkg/pull/8731) Revert "[azure] Update azure-iot-sdk-c for 07/2019 LTS refresh (#8686)"

- openxr-loader `2019-09-25` -> `1.0.3.0`
    - [(#8515)](https://github.com/microsoft/vcpkg/pull/8515) [openxr-loader] Update to 1.0.3 release + latest C++ bindings header

- gdcm `3.0.0-5` -> `3.0.3`
    - [(#8522)](https://github.com/microsoft/vcpkg/pull/8522) [gdcm/libtorrent] Upgrade to new version

- libtorrent `1.2.1-bcb26fd6` -> `1.2.2`
    - [(#8522)](https://github.com/microsoft/vcpkg/pull/8522) [gdcm/libtorrent] Upgrade to new version

- sfml `2.5.1-3` -> `2.5.1-4`
    - [(#8523)](https://github.com/microsoft/vcpkg/pull/8523) [sfml]Add usage.

- darknet `0.2.5.1` -> `0.2.5.1-1`
    - [(#8527)](https://github.com/microsoft/vcpkg/pull/8527) [stb] update and add cmake module

- stb `2019-07-11` -> `2019-08-17`
    - [(#8527)](https://github.com/microsoft/vcpkg/pull/8527) [stb] update and add cmake module

- curlpp `2018-06-15` -> `2018-06-15-1`
    - [(#8532)](https://github.com/microsoft/vcpkg/pull/8532) [curlpp] fix regression introduced in #7331

- libjpeg-turbo `2.0.2` -> `2.0.3`
    - [(#8412)](https://github.com/microsoft/vcpkg/pull/8412) [libjpeg-turbo] Update to 2.0.3.

- opencv3 `3.4.7-1` -> `3.4.7-2`
    - [(#8542)](https://github.com/microsoft/vcpkg/pull/8542) [opencv] add tesseract to fix downstream linking

- opencv4 `4.1.1-2` -> `4.1.1-3`
    - [(#8542)](https://github.com/microsoft/vcpkg/pull/8542) [opencv] add tesseract to fix downstream linking

- gtest `2019-08-14-2` -> `2019-10-09`
    - [(#8544)](https://github.com/microsoft/vcpkg/pull/8544) [gtest/pmdk] Upgrade to new version

- pmdk `1.6-3` -> `2019-10-10`
    - [(#8544)](https://github.com/microsoft/vcpkg/pull/8544) [gtest/pmdk] Upgrade to new version
    - [(#8586)](https://github.com/microsoft/vcpkg/pull/8586) [pmdk] Upgrade to version 1.7

- imgui `1.72b` -> `1.73-1`
    - [(#8504)](https://github.com/microsoft/vcpkg/pull/8504) [imgui] Update to 1.73
    - [(#8605)](https://github.com/microsoft/vcpkg/pull/8605) [imgui]Add feature example in windows.

- sqlite3 `3.29.0-1` -> `3.30.1-1`
    - [(#8567)](https://github.com/microsoft/vcpkg/pull/8567) [sqlite3] Update to 3.30.1
    - [(#7917)](https://github.com/microsoft/vcpkg/pull/7917) [proj4]Upgrade version to 6.1.1 and remove useless patches.

- ffmpeg `4.2` -> `4.2-1`
    - [(#8596)](https://github.com/microsoft/vcpkg/pull/8596) [ffmpeg] Pass Vcpkg compiler and linker flags to build script

- libyuv `fec9121` -> `fec9121-1`
    - [(#8576)](https://github.com/microsoft/vcpkg/pull/8576) [libyuv] fix include header installation
    - [(#8709)](https://github.com/microsoft/vcpkg/pull/8709) [libyuv] Add Mac/Linux build support
    - [(#8769)](https://github.com/microsoft/vcpkg/pull/8769) [libyuv]Build corresponding type library according to BUILD_SHARED_LIBS.

- libarchive `3.4.0` -> `3.4.0-1`
    - [(#8564)](https://github.com/microsoft/vcpkg/pull/8564) Mixed release and debug build in libarchive

- aixlog `1.2.1-1` -> `1.2.2`
    - [(#8587)](https://github.com/microsoft/vcpkg/pull/8587) [aixlog] Update library to 1.2.2

- portaudio `19.0.6.00-5` -> `2019-09-30`
    - [(#8399)](https://github.com/microsoft/vcpkg/pull/8399) [portaudio] Update to the latest version

- chakracore `1.11.13` -> `1.11.14`
    - [(#8593)](https://github.com/microsoft/vcpkg/pull/8593) [chakracore] Update library to 1.11.14

- embree3 `3.5.2-2` -> `3.5.2-3`
    - [(#8608)](https://github.com/microsoft/vcpkg/pull/8608) [embree3]Fix generated cmake files path.
    - [(#8591)](https://github.com/microsoft/vcpkg/pull/8591) [embree3]Fix EMBREE_ROOT_DIR path setting,EMBREE_LIBRARY Debug/Release path setting.

- cpp-httplib `0.2.4` -> `0.2.5`
    - [(#8590)](https://github.com/microsoft/vcpkg/pull/8590) [cpp-httplib] Update library to 0.2.5

- range-v3 `0.9.0-20190822` -> `0.9.1`
    - [(#8583)](https://github.com/microsoft/vcpkg/pull/8583) [range-v3] Update to 0.9.1

- otl `4.0.443-2` -> `4.0.447`
    - [(#8581)](https://github.com/microsoft/vcpkg/pull/8581) otl version 447

- directxtex `aug2019` -> `oct2019`
    - [(#8563)](https://github.com/microsoft/vcpkg/pull/8563) [directxtk][directxtk12][directxtex][directxmesh] Fixed missing pdbs
    - [(#8723)](https://github.com/microsoft/vcpkg/pull/8723) [directxtex] Update library to oct2019

- directxtk `aug2019` -> `oct2019`
    - [(#8563)](https://github.com/microsoft/vcpkg/pull/8563) [directxtk][directxtk12][directxtex][directxmesh] Fixed missing pdbs
    - [(#8724)](https://github.com/microsoft/vcpkg/pull/8724) [directxtk] Update library to oct2019

- directxtk12 `aug2019` -> `oct2019`
    - [(#8563)](https://github.com/microsoft/vcpkg/pull/8563) [directxtk][directxtk12][directxtex][directxmesh] Fixed missing pdbs
    - [(#8725)](https://github.com/microsoft/vcpkg/pull/8725) [directxtk12] Update library to oct2019

- vtk `8.2.0-8` -> `8.2.0-9`
    - [(#8554)](https://github.com/microsoft/vcpkg/pull/8554) [vtk] Change atlmfc as feature
    - [(#7917)](https://github.com/microsoft/vcpkg/pull/7917) [proj4]Upgrade version to 6.1.1 and remove useless patches.

- sdl2 `2.0.9-4` -> `2.0.10-2`
    - [(#8643)](https://github.com/microsoft/vcpkg/pull/8643) [sdl2] Update to 2.0.10
    - [(#8760)](https://github.com/microsoft/vcpkg/pull/8760) Fix sdl2 build if there is space in the path

- gdal `2.4.1-8` -> `2.4.1-9`
    - [(#7917)](https://github.com/microsoft/vcpkg/pull/7917) [proj4]Upgrade version to 6.1.1 and remove useless patches.
    - [(#8621)](https://github.com/microsoft/vcpkg/pull/8621) [proj4] Update to version 6.2.0

- libgeotiff `1.4.2-9` -> `1.4.2-10`
    - [(#7917)](https://github.com/microsoft/vcpkg/pull/7917) [proj4]Upgrade version to 6.1.1 and remove useless patches.

- proj4 `4.9.3-5` -> `6.2.0-1`
    - [(#7917)](https://github.com/microsoft/vcpkg/pull/7917) [proj4]Upgrade version to 6.1.1 and remove useless patches.
    - [(#8621)](https://github.com/microsoft/vcpkg/pull/8621) [proj4] Update to version 6.2.0

- tcl `8.6.5` -> `8.6.10-2`
    - [(#8402)](https://github.com/microsoft/vcpkg/pull/8402) [tcl]Upgrade to 8.6.9 and use vcpkg_install_make/vcpkg_install_nmake.

- physx `4.1.1-1` -> `4.1.1-3`
    - [(#8561)](https://github.com/microsoft/vcpkg/pull/8561) [physx] Added a patch to fix missing typeinfo.h header with VS16.3 and missing pdb files
    - [(#8658)](https://github.com/microsoft/vcpkg/pull/8658) [physx] Added UWP support

- celero `2.5.0-1` -> `2.6.0`
    - [(#8646)](https://github.com/microsoft/vcpkg/pull/8646) [celero] Updated to v2.6.0

- assimp `5.0.0` -> `5.0.0-1`
    - [(#8665)](https://github.com/microsoft/vcpkg/pull/8665) [assimp] Fix cmake package config

- mosquitto `1.6.3` -> `1.6.7`
    - [(#8661)](https://github.com/microsoft/vcpkg/pull/8661) [mosquitto] Update to 1.6.7

- plog `1.1.4` -> `1.1.5`
    - [(#8685)](https://github.com/microsoft/vcpkg/pull/8685) [plog] Update to 1.1.5

- catch2 `2.9.2` -> `2.10.1-1`
    - [(#8684)](https://github.com/microsoft/vcpkg/pull/8684) [catch2] Update to 2.10.1

- nano-signal-slot `commit-25aa2aa90d450d3c7550c535c7993a9e2ed0764a` -> `2018-08-25-1`
    - [(#8675)](https://github.com/microsoft/vcpkg/pull/8675) [nano-signal-slot] Enable UWP and dynamic builds

- duckx `2019-08-06` -> `1.0.0`
    - [(#8673)](https://github.com/microsoft/vcpkg/pull/8673) [duckx] update library to 1.0.0

- jsoncons `0.136.0` -> `0.136.1`
    - [(#8689)](https://github.com/microsoft/vcpkg/pull/8689) [jsoncons] Update to v.0.136.1

- libpmemobj-cpp `1.7` -> `1.8`
    - [(#8729)](https://github.com/microsoft/vcpkg/pull/8729) [libpmemobj-cpp] Update library to 1.8

- forest `12.0.3` -> `12.0.4`
    - [(#8727)](https://github.com/microsoft/vcpkg/pull/8727) [forest] Update library to 12.0.4

- check `0.12.0-2` -> `0.13.0`
    - [(#8722)](https://github.com/microsoft/vcpkg/pull/8722) [check] Update library to 0.13.0

- libcopp `1.2.0` -> `1.2.1`
    - [(#8728)](https://github.com/microsoft/vcpkg/pull/8728) [libcopp] Update library to 1.2.1

- corrade `2019.01-1` -> `2019.10`
    - [(#8742)](https://github.com/microsoft/vcpkg/pull/8742) Update magnum ports to new version

- magnum-extras `2019.01-2` -> `2019.10`
    - [(#8742)](https://github.com/microsoft/vcpkg/pull/8742) Update magnum ports to new version

- magnum-integration `2019.01-2` -> `2019.10`
    - [(#8742)](https://github.com/microsoft/vcpkg/pull/8742) Update magnum ports to new version

- magnum-plugins `2019.01-2` -> `2019.10`
    - [(#8742)](https://github.com/microsoft/vcpkg/pull/8742) Update magnum ports to new version

- magnum `2019.01-2` -> `2019.10`
    - [(#8742)](https://github.com/microsoft/vcpkg/pull/8742) Update magnum ports to new version

- curl `7.66.0` -> `7.66.0-1`
    - [(#8739)](https://github.com/microsoft/vcpkg/pull/8739) [curl]Fix tools depends zlib.

- x265 `3.0-2` -> `3.2-1`
    - [(#8738)](https://github.com/microsoft/vcpkg/pull/8738) update x265 to 3.2

- pixman `0.38.0-3` -> `0.38.0-4`
    - [(#8736)](https://github.com/microsoft/vcpkg/pull/8736) [pixman] Improve Arm detection

- xmlsec `1.2.28` -> `1.2.29`
    - [(#8721)](https://github.com/microsoft/vcpkg/pull/8721) [xmlsec] Update to 1.2.29

- string-theory `2.2` -> `2.3`
    - [(#8734)](https://github.com/microsoft/vcpkg/pull/8734) [string-theory] Update library to 2.3

- log4cpp `2.9.1-1` -> `2.9.1-2`
    - [(#8741)](https://github.com/microsoft/vcpkg/pull/8741) [log4cpp] Fix link static library

- so5extra `1.3.1-2` -> `1.3.1.1`
    - [(#8770)](https://github.com/microsoft/vcpkg/pull/8770) [so5extra] updated to 1.3.1.1

- wangle `2019.07.08.00` -> `2019.07.08.00-1`
    - [(#8764)](https://github.com/microsoft/vcpkg/pull/8764) [wangle]Fix config.cmake

- fribidi `2019-02-04-1` -> `2019-02-04-2`
    - [(#8639)](https://github.com/microsoft/vcpkg/pull/8639) mesonbuild - Update to 0.52.0

- libepoxy `1.5.3-1` -> `1.5.3-2`
    - [(#8639)](https://github.com/microsoft/vcpkg/pull/8639) mesonbuild - Update to 0.52.0

- jxrlib `1.1-9` -> `2019.10.9`
    - [(#8525)](https://github.com/microsoft/vcpkg/pull/8525) [jxrlib] Update port

- fltk `1.3.4-8` -> `1.3.5-1`
    - [(#8457)](https://github.com/microsoft/vcpkg/pull/8457) FLTK v1.3.5

- qt5-location `5.12.5-1` -> `5.12.5-2`
    - [(#8777)](https://github.com/microsoft/vcpkg/pull/8777) [qt5-location] Modify clipper library name to avoid conflicts with vxl

- pthreads `3.0.0-3` -> `3.0.0-4`
    - [(#8651)](https://github.com/microsoft/vcpkg/pull/8651) [pthreads]Add usage.

- glib `2.52.3-14-3` -> `2.52.3-14-4`
    - [(#8653)](https://github.com/microsoft/vcpkg/pull/8653) [glib]Fix linux build.

- libxslt `1.1.33-2` -> `1.1.33-4`
    - [(#8589)](https://github.com/microsoft/vcpkg/pull/8589) [libxslt]Using vcpkg_install_nmake in Windows, support unix.

- paho-mqtt `1.3.0` -> `1.3.0-1`
    - [(#8492)](https://github.com/microsoft/vcpkg/pull/8492) Export paho-mqtt cmake targets, fix paho-mqttpp3 dependency.

- paho-mqttpp3 `1.0.1-2` -> `1.0.1-3`
    - [(#8492)](https://github.com/microsoft/vcpkg/pull/8492) Export paho-mqtt cmake targets, fix paho-mqttpp3 dependency.

- pcre2 `10.30-5` -> `10.30-6`
    - [(#8620)](https://github.com/microsoft/vcpkg/pull/8620) [pcre2]Fix uwp build failure.

- arrow `0.14.1-1` -> `0.15.1`
    - [(#8815)](https://github.com/microsoft/vcpkg/pull/8815) [Arrow] Update to Arrow 0.15.1

- netcdf-c `4.7.0-4` -> `4.7.0-5`
    - [(#8398)](https://github.com/microsoft/vcpkg/pull/8398) [netcdf-c] Add usage

- sol2 `3.0.3-1` -> `3.0.3-2`
    - [(#8776)](https://github.com/microsoft/vcpkg/pull/8776) [sol2] Use the single header release

- arb `2.16.0` -> `2.17.0`
    - [(#8831)](https://github.com/microsoft/vcpkg/pull/8831) [arb]Upgrade to 2.17.0

- wxwidgets `3.1.2-2` -> `3.1.3`
    - [(#8808)](https://github.com/microsoft/vcpkg/pull/8808) [wxwidgets] Upgrade to 3.1.3

</details>

-- vcpkg team vcpkg@microsoft.com FRI, 01 Nov 08:30:00 -0800

vcpkg (2019.09.30)
---
#### Total port count: 1225
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|**x64-windows**|1151|
|x86-windows|1136|
|x64-windows-static|1061|
|**x64-linux**|980|
|**x64-osx**|939|
|arm64-windows|766|
|x64-uwp|624|
|arm-uwp|594|

#### The following commands and options have been updated:
- `x-history` ***[NEW COMMAND]***
    - Shows the full history of CONTROL version of a port, including the vcpkg commit hash, CONTROL version, and date of vcpkg commit
        - [(#7377)](https://github.com/microsoft/vcpkg/pull/7377) [x-history] Prints CONTROL    version history of a port 👻
        - [(#8101)](https://github.com/microsoft/vcpkg/pull/8101) fix x-history help desc.
- `depend-info`
    - Constrain argument count to single port name as usage intends
        - [(#8135)](https://github.com/microsoft/vcpkg/pull/8135) [vcpkg] Fix `depend-info` command arguments arity

#### The following documentation has been updated:
- [Frequently Asked Questions](docs/about/faq.md)
    - [(#8258)](https://github.com/microsoft/vcpkg/pull/8258) Add detailed instructions for custom configurations
- [Maintainer Guidelines and Policies](docs/maintainers/maintainer-guide.md)
    - [(#8383)](https://github.com/microsoft/vcpkg/pull/8383) Fix a typo in maintainer-guide.md

#### The following *remarkable* changes have been made to vcpkg's infrastructure:
- Add port features to CI test result XML as the first step in testing them in CI system
    - [(#8342)](https://github.com/microsoft/vcpkg/pull/8342) [CI system] Add features to test result xml

#### The following *additional* changes have been made to vcpkg's infrastructure:
- [(#8048)](https://github.com/microsoft/vcpkg/pull/8048) Add August changelog
- [(#8082)](https://github.com/microsoft/vcpkg/pull/8082) [vcpkg] remove text from license
- [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
- [(#7954)](https://github.com/microsoft/vcpkg/pull/7954) Fix bug in `.vcpkg-root` detection that breaks `--overlay-triplets`
- [(#8131)](https://github.com/microsoft/vcpkg/pull/8131) [vcpkg] add missing implib definitions, fix shared lib extension on mac
- [(#8129)](https://github.com/microsoft/vcpkg/pull/8129) [vcpkg] Continue on malformed paths in PATH
- [(#8200)](https://github.com/microsoft/vcpkg/pull/8200) [vcpkg] Fix missing VCPKG_ROOT_PATH in create command
- [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats
- [(#5180)](https://github.com/microsoft/vcpkg/pull/5180) Use CMAKE_TRY_COMPILE_PLATFORM_VARIABLES to propagate values
- [(#8032)](https://github.com/microsoft/vcpkg/pull/8032) [vcpkg] Avoid RENAME usage to prevent cross-device link problems (#4245)
- [(#8304)](https://github.com/microsoft/vcpkg/pull/8304) [ports.cmake] Fixup capitalization inconsistencies of Windows drive letter

<details>
<summary><b>The following 55 ports have been added:</b></summary>

|port|version|
|---|---|
|[dmlc](https://github.com/microsoft/vcpkg/pull/7549)| 2019-08-12
|[anyrpc](https://github.com/microsoft/vcpkg/pull/7438)| 2017-12-01
|[imgui-sfml](https://github.com/microsoft/vcpkg/pull/7429)<sup>[#8004](https://github.com/microsoft/vcpkg/pull/8004) </sup>| 2.1
|[ignition-cmake0](https://github.com/microsoft/vcpkg/pull/7781)<sup>[#8044](https://github.com/microsoft/vcpkg/pull/8044) [#8136](https://github.com/microsoft/vcpkg/pull/8136) </sup>| 0.6.2-1
|[ignition-math4](https://github.com/microsoft/vcpkg/pull/7781)| 4.0.0
|[ignition-modularscripts](https://github.com/microsoft/vcpkg/pull/7781)<sup>[#8136](https://github.com/microsoft/vcpkg/pull/8136) </sup>| 2019-09-11
|[volk](https://github.com/microsoft/vcpkg/pull/8035)<sup>[#8364](https://github.com/microsoft/vcpkg/pull/8364) </sup>| 2019-09-26
|[cppkafka](https://github.com/microsoft/vcpkg/pull/7987)<sup>[#8073](https://github.com/microsoft/vcpkg/pull/8073) </sup>| 0.3.1-1
|[nativefiledialog](https://github.com/microsoft/vcpkg/pull/7944)| 2019-08-28
|[cello](https://github.com/microsoft/vcpkg/pull/7386)| 2019-07-23
|[libhydrogen](https://github.com/microsoft/vcpkg/pull/7436)| 2019-08-11
|[quantlib](https://github.com/microsoft/vcpkg/pull/7283)| 2019-09-02
|[magic-get](https://github.com/microsoft/vcpkg/pull/8072)| 2019-09-02
|[cityhash](https://github.com/microsoft/vcpkg/pull/7879)| 2013-01-08
|[ignition-common1](https://github.com/microsoft/vcpkg/pull/8111)| 1.1.1
|[wampcc](https://github.com/microsoft/vcpkg/pull/7929)| 2019-09-04
|[hidapi](https://github.com/microsoft/vcpkg/pull/8113)| 2019-08-30
|[sokol](https://github.com/microsoft/vcpkg/pull/8107)| 2019-09-09
|[parallelstl](https://github.com/microsoft/vcpkg/pull/8039)| 20190522-1
|[marl](https://github.com/microsoft/vcpkg/pull/8132)<sup>[#8161](https://github.com/microsoft/vcpkg/pull/8161) </sup>| 2019-09-13
|[vectorclass](https://github.com/microsoft/vcpkg/pull/7573)| 2.00.01
|[wren](https://github.com/microsoft/vcpkg/pull/7242)| 2019-07-01
|[libsrtp](https://github.com/microsoft/vcpkg/pull/8046)| 2.2.0
|[ignition-msgs1](https://github.com/microsoft/vcpkg/pull/8044)| 1.0.0
|[ignition-transport4](https://github.com/microsoft/vcpkg/pull/8044)| 4.0.0
|[argtable3](https://github.com/microsoft/vcpkg/pull/7815)| 2019-08-21
|[llgl](https://github.com/microsoft/vcpkg/pull/7701)| 2019-08-15
|[sdformat6](https://github.com/microsoft/vcpkg/pull/8137)| 6.2.0
|[grppi](https://github.com/microsoft/vcpkg/pull/8125)| 0.4.0
|[opencolorio](https://github.com/microsoft/vcpkg/pull/8006)| 1.1.1
|[cpputest](https://github.com/microsoft/vcpkg/pull/8188)| 2019-9-16
|[winreg](https://github.com/microsoft/vcpkg/pull/8190)<sup>[#8371](https://github.com/microsoft/vcpkg/pull/8371) </sup>| 1.2.1-1
|[zfp](https://github.com/microsoft/vcpkg/pull/7955)| 0.5.5-1
|[libyuv](https://github.com/microsoft/vcpkg/pull/7486)| fec9121
|[foonathan-memory](https://github.com/microsoft/vcpkg/pull/7350)<sup>[#8266](https://github.com/microsoft/vcpkg/pull/8266) </sup>| 2019-07-21-1
|[jinja2cpplight](https://github.com/microsoft/vcpkg/pull/8207)| 2018-05-08
|[liblbfgs](https://github.com/microsoft/vcpkg/pull/8186)| 1.10
|[sigslot](https://github.com/microsoft/vcpkg/pull/8262)| 1.0.0
|[cute-headers](https://github.com/microsoft/vcpkg/pull/8277)| 2019-09-20
|[libsoundio](https://github.com/microsoft/vcpkg/pull/8273)| 2.0.0
|[matplotlib-cpp](https://github.com/microsoft/vcpkg/pull/8313)| 2019-09-24
|[asynch](https://github.com/microsoft/vcpkg/pull/8317)<sup>[#8371](https://github.com/microsoft/vcpkg/pull/8371) </sup>| 2019-09-21-1
|[minimp3](https://github.com/microsoft/vcpkg/pull/8319)<sup>[#8371](https://github.com/microsoft/vcpkg/pull/8371) </sup>| 2019-07-24-1
|[crfsuite](https://github.com/microsoft/vcpkg/pull/8233)| 2019-07-21
|[cudnn](https://github.com/microsoft/vcpkg/pull/7536)| 7.6
|[libosip2](https://github.com/microsoft/vcpkg/pull/8261)| 5.1.0
|[portable-snippets](https://github.com/microsoft/vcpkg/pull/7783)| 2019-09-20
|[ignition-fuel-tools1](https://github.com/microsoft/vcpkg/pull/8136)| 1.2.0
|[clickhouse-cpp](https://github.com/microsoft/vcpkg/pull/7880)| 2019-05-22
|[tweeny](https://github.com/microsoft/vcpkg/pull/8341)| 3.0
|[nanogui](https://github.com/microsoft/vcpkg/pull/8302)| 2019-09-23
|[wepoll](https://github.com/microsoft/vcpkg/pull/8280)| 1.5.5
|[tcl](https://github.com/microsoft/vcpkg/pull/8026)| 8.6.5
|[cpuinfo](https://github.com/microsoft/vcpkg/pull/7449)| 2019-07-28
|[mathc](https://github.com/microsoft/vcpkg/pull/8394)| 2019-09-29
</details>

<details>
<summary><b>The following 220 ports have been updated:</b></summary>

- breakpad `2019-07-11` -> `2019-07-11-1`
    - [(#7938)](https://github.com/microsoft/vcpkg/pull/7938) [breakpad] Fix build failed with Visual Studio 2019

- gtest `2019-08-14-1` -> `2019-08-14-2`
    - [(#7887)](https://github.com/microsoft/vcpkg/pull/7887) [gtest]Re-fix gmock target.

- libxslt `1.1.33` -> `1.1.33-2`
    - [(#7451)](https://github.com/microsoft/vcpkg/pull/7451) [libxslt]Fix dependent ports in static builds.
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- pcre2 `10.30-4` -> `10.30-5`
    - [(#7948)](https://github.com/microsoft/vcpkg/pull/7948) Fix build with Emscripten/WASM

- entt `3.0.0-1` -> `3.1.1`
    - [(#7984)](https://github.com/microsoft/vcpkg/pull/7984) [entt] Update to 3.1.0
    - [(#8098)](https://github.com/microsoft/vcpkg/pull/8098) [entt] Update to 3.1.1

- raylib `2019-04-27-2` -> `2.5.0`
    - [(#7848)](https://github.com/microsoft/vcpkg/pull/7848) [raylib] update to 2.5.0

- jsoncons `0.132.1` -> `0.136.0`
    - [(#8034)](https://github.com/microsoft/vcpkg/pull/8034) [jsoncons] Update to version 0.133.0
    - [(#8221)](https://github.com/microsoft/vcpkg/pull/8221) [jsoncons] Update to v0.134.0
    - [(#8348)](https://github.com/microsoft/vcpkg/pull/8348) [jsoncons] Update jsoncons to v0.135.0
    - [(#8382)](https://github.com/microsoft/vcpkg/pull/8382) [jsoncons] Update jsoncons to v0.136.0

- exiv2 `0.27.1-1` -> `0.27.2-1`
    - [(#7992)](https://github.com/microsoft/vcpkg/pull/7992) [exiv2] Update library to 0.27.2

- gettext `0.19-10` -> `0.19-11`
    - [(#7990)](https://github.com/microsoft/vcpkg/pull/7990) [gettext]Improve gettext on Linux.

- wtl `10.0-2` -> `10.0-3`
    - [(#8005)](https://github.com/microsoft/vcpkg/pull/8005) Update WTL to 10.0.9163.

- aixlog `1.2.1` -> `1.2.1-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- chaiscript `6.1.0` -> `6.1.0-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- dlfcn-win32 `1.1.1-2` -> `1.1.1-3`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- enet `1.3.13` -> `1.3.13-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- fltk `1.3.4-6` -> `1.3.4-7`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- fmi4cpp `0.7.0-1` -> `0.7.0-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- fmilib `2.0.3-1` -> `2.0.3-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- freetds `1.1.6` -> `1.1.6-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- gainput `1.0.0-1` -> `1.0.0-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- geographiclib `1.47-patch1-7` -> `1.47-patch1-9`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports
    - [(#8115)](https://github.com/microsoft/vcpkg/pull/8115) [geographiclib]Fix usage error and cmake path in Linux.

- glog `0.4.0-1` -> `0.4.0-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- irrlicht `1.8.4-1` -> `1.8.4-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- libmikmod `3.3.11.1-4` -> `3.3.11.1-5`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- libodb-mysql `2.4.0-3` -> `2.4.0-4`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- libodb-sqlite `2.4.0-4` -> `2.4.0-5`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- libodb `2.4.0-5` -> `2.4.0-6`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- libsquish `1.15-1` -> `1.15-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- lzo `2.10-2` -> `2.10-3`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- nanovg `master` -> `2019-8-30-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports
    - [(#8302)](https://github.com/microsoft/vcpkg/pull/8302) [nanogui] Add new port

- ode `0.15.1-1` -> `0.15.1-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- opencsg `1.4.2` -> `1.4.2-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- orocos-kdl `1.4-1` -> `1.4-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- pangomm `2.40.1` -> `2.40.1-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- pcre `8.41-2` -> `8.41-3`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- qt5-gamepad `5.12.3-1` -> `5.12.5-1`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- wavpack `5.1.0-00d9a4a-1` -> `5.1.0-2`
    - [(#7986)](https://github.com/microsoft/vcpkg/pull/7986) modernize many ports

- tensorflow-cc `1.14` -> `1.14-1`
    - [(#8023)](https://github.com/microsoft/vcpkg/pull/8023) [tensorflow-cc]Fix build error and add warning message.

- glew `2.1.0-5` -> `2.1.0-6`
    - [(#7967)](https://github.com/microsoft/vcpkg/pull/7967) [VTK/GLEW] Fix Regression of VTK with newer CMake Versions

- libpq `9.6.1-7` -> `9.6.1-8`
    - [(#8076)](https://github.com/microsoft/vcpkg/pull/8076) libpq requires HAVE_CRYPTO_LOCK for thread safety with openssl <1.1.0
    - [(#8080)](https://github.com/microsoft/vcpkg/pull/8080) [libpq] #undef int128 type if compiling for 32 bit architecture
    - [(#8090)](https://github.com/microsoft/vcpkg/pull/8090) [libpq] Bump version number

- sobjectizer `5.6.0.2` -> `5.6.1`
    - [(#8052)](https://github.com/microsoft/vcpkg/pull/8052) [sobjectizer] updated to 5.6.1

- unrar `5.5.8-2` -> `5.8.1`
    - [(#8053)](https://github.com/microsoft/vcpkg/pull/8053) [unrar] Don't use a custom struct member alignment
    - [(#8108)](https://github.com/microsoft/vcpkg/pull/8108) [unrar] Update to 5.8.1

- xalan-c `1.11-7` -> `1.11-8`
    - [(#7795)](https://github.com/microsoft/vcpkg/pull/7795) [xalan-c] fixed cmake files location

- re2 `2019-08-01` -> `2019-09-01`
    - [(#8089)](https://github.com/microsoft/vcpkg/pull/8089) [re2] Update library to 2019-09-01

- libvpx `1.7.0-3` -> `1.8.1`
    - [(#8086)](https://github.com/microsoft/vcpkg/pull/8086) [libvpx] Update to 1.8.1.
    - [(#8100)](https://github.com/microsoft/vcpkg/pull/8100) [libvpx] Fix build when VCPKG_BUILD_TYPE is set.

- grpc `1.22.0` -> `1.23.0`
    - [(#8109)](https://github.com/microsoft/vcpkg/pull/8109) [grpc] Update grpc to 1.23.0

- egl-registry `2018-06-30-1` -> `2019-08-08`
    - [(#8095)](https://github.com/microsoft/vcpkg/pull/8095) Update egl-registry to 2019-08-08 and opengl-registry to 2019-08-22.

- opengl-registry `2018-06-30-1` -> `2019-08-22`
    - [(#8095)](https://github.com/microsoft/vcpkg/pull/8095) Update egl-registry to 2019-08-08 and opengl-registry to 2019-08-22.

- dimcli `5.0.0` -> `5.0.1`
    - [(#8024)](https://github.com/microsoft/vcpkg/pull/8024) [dimcli] Upgrade to version 5.0.1

- libwebsockets `3.1.0-3` -> `3.2.0`
    - [(#8017)](https://github.com/microsoft/vcpkg/pull/8017) Update libwebsockets to v3.2.0

- mongo-c-driver `1.14.0-3-1` -> `1.14.0-4`
    - [(#7974)](https://github.com/microsoft/vcpkg/pull/7974) [mongo-c-driver] fix debug linkage under linux

- qwt `6.1.3-7` -> `6.1.3-8`
    - [(#8030)](https://github.com/microsoft/vcpkg/pull/8030) [qwt]make qwt support unix

- ixwebsocket `5.0.4` -> `6.1.0`
    - [(#7839)](https://github.com/microsoft/vcpkg/pull/7839) [ixwebsocket] update to 6.1.0 to fix Windows problem

- cpp-httplib `0.2.1` -> `0.2.4`
    - [(#8054)](https://github.com/microsoft/vcpkg/pull/8054) [cpp-httplib] Update library to 0.2.2
    - [(#8172)](https://github.com/microsoft/vcpkg/pull/8172) [cpp-httplib] Update library to 0.2.4

- blend2d `beta_2019-07-16` -> `beta_2019-10-09`
    - [(#8120)](https://github.com/microsoft/vcpkg/pull/8120) [blend2d] Port update beta_2019-10-09

- json-c `2019-05-31` -> `2019-09-10`
    - [(#8121)](https://github.com/microsoft/vcpkg/pull/8121) [json-c] Add dynamic library support

- glfw3 `3.3-1` -> `3.3-2`
    - [(#7592)](https://github.com/microsoft/vcpkg/pull/7592) [glfw3] fix cmake config

- google-cloud-cpp `0.12.0` -> `0.13.0`
    - [(#8077)](https://github.com/microsoft/vcpkg/pull/8077) Update google-cloud-cpp and googleapis.

- googleapis `0.1.3` -> `0.1.5`
    - [(#8077)](https://github.com/microsoft/vcpkg/pull/8077) Update google-cloud-cpp and googleapis.

- tbb `2019_U8` -> `2019_U8-1`
    - [(#8018)](https://github.com/microsoft/vcpkg/pull/8018) [tbb]Fix static build.

- openxr-loader `1.0.0-2` -> `2019-09-25`
    - [(#8123)](https://github.com/microsoft/vcpkg/pull/8123) [openxr-loader] Update to 1.0.2
    - [(#8255)](https://github.com/microsoft/vcpkg/pull/8255) [openxr-loader] Add openxr C++ bindings

- sdl1 `1.2.15-6` -> `1.2.15-8`
    - [(#8070)](https://github.com/microsoft/vcpkg/pull/8070) [sdl1]Support linux build.
    - [(#8327)](https://github.com/microsoft/vcpkg/pull/8327) [sdl1] fix windows sdk 18362 build failure

- glslang `2019-03-05` -> `2019-03-05-1`
    - [(#8051)](https://github.com/microsoft/vcpkg/pull/8051) [glslang]Fix generated cmake files.

- opencl `2.2 (2017.07.18)-1` -> `2.2 (2018.08.31)`
    - [(#4204)](https://github.com/microsoft/vcpkg/pull/4204) Linux support for the OpenCL SDK package

- libspatialite `4.3.0a-3` -> `4.3.0a-4`
    - [(#8025)](https://github.com/microsoft/vcpkg/pull/8025) [libspatialite]make libspatialite support linux and osx

- libqrencode `4.0.2` -> `4.0.2-1`
    - [(#8099)](https://github.com/microsoft/vcpkg/pull/8099) [libqrencode] Add tool feature; Remove unnecessary patch

- sdl2-mixer `2.0.4-3` -> `2.0.4-6`
    - [(#7720)](https://github.com/microsoft/vcpkg/pull/7720) [sdl2-mixer]Remove useless dependency link libraries.
    - [(#8208)](https://github.com/microsoft/vcpkg/pull/8208) [sdl2-mixer] Fix features dependency link.
    - [(#8335)](https://github.com/microsoft/vcpkg/pull/8335) [sdl2-mixer]Re-fix dynamic call.

- evpp `0.7.0` -> `0.7.0-1`
    - [(#8050)](https://github.com/microsoft/vcpkg/pull/8050) [evpp]Fix linux build.

- libogg `1.3.3-4` -> `1.3.4`
    - [(#8094)](https://github.com/microsoft/vcpkg/pull/8094) [libogg] Update to 1.3.4-1

- otl `4.0.442` -> `4.0.443`
    - [(#8139)](https://github.com/microsoft/vcpkg/pull/8139) [otl] fix hash and update version

- speexdsp `1.2rc3-3` -> `1.2.0`
    - [(#8140)](https://github.com/microsoft/vcpkg/pull/8140) [speexdsp] update to 1.2.0

- pcl `1.9.1-8` -> `1.9.1-9`
    - [(#8154)](https://github.com/microsoft/vcpkg/pull/8154) [pcl] Fix problem with link-type keywords in linked libraries

- libqglviewer `2.7.0` -> `2.7.0-2`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-3d `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-activeqt `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-base `5.12.3-4` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats
    - [(#8212)](https://github.com/microsoft/vcpkg/pull/8212) [Qt] feature latest to build 5.13.1

- qt5-charts `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-connectivity `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-datavis3d `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-declarative `5.12.3-2` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-graphicaleffects `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-imageformats `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-location `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-macextras `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-modularscripts `2019-04-30-1` -> `deprecated`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4

- qt5-mqtt `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-multimedia `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-networkauth `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-purchasing `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-quickcontrols `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-quickcontrols2 `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-remoteobjects `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-script `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-scxml `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-sensors `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-serialport `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-speech `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-svg `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5

- qt5-tools `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-virtualkeyboard `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-webchannel `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-websockets `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-webview `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-winextras `5.12.3-1` -> `5.12.5-1`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5-xmlpatterns `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8222)](https://github.com/microsoft/vcpkg/pull/8222) [Qt] Fix static builds of qt5-imageformats

- qt5 `5.12.3-1` -> `5.12.5`
    - [(#7667)](https://github.com/microsoft/vcpkg/pull/7667) [Qt] Update to 5.12.4
    - [(#8159)](https://github.com/microsoft/vcpkg/pull/8159) [Qt] update to 5.12.5
    - [(#8212)](https://github.com/microsoft/vcpkg/pull/8212) [Qt] feature latest to build 5.13.1

- mathgl `2.4.3-1` -> `2.4.3-2`
    - [(#8145)](https://github.com/microsoft/vcpkg/pull/8145) [mathgl]Fix build failure on x86-windows.

- libpng `1.6.37-3` -> `1.6.37-4`
    - [(#8079)](https://github.com/microsoft/vcpkg/pull/8079) [libpng] Replace find_library() with a simple set() for linking libm on UNIX

- chakracore `1.11.12` -> `1.11.13`
    - [(#8171)](https://github.com/microsoft/vcpkg/pull/8171) [chakracore] Update library to 1.11.13

- fastcdr `1.0.10` -> `1.0.11`
    - [(#8173)](https://github.com/microsoft/vcpkg/pull/8173) [fastcdr] Update library to 1.0.11

- yara `e3439e4ead4ed5d3b75a0b46eaf15ddda2110bb9-2` -> `3.10.0`
    - [(#8194)](https://github.com/microsoft/vcpkg/pull/8194) [yara] Update to 3.10.0

- rabit `0.1` -> `0.1-2`
    - [(#8042)](https://github.com/microsoft/vcpkg/pull/8042) [rabit] Fix file conflict with dmlc
    - [(#8206)](https://github.com/microsoft/vcpkg/pull/8206) [rabit] Fix cmake files path

- gdcm `3.0.0-4` -> `3.0.0-5`
    - [(#7852)](https://github.com/microsoft/vcpkg/pull/7852) [gdcm] Fix file UseGDCM.cmake path name

- libyaml `0.2.2-1` -> `0.2.2-2`
    - [(#8177)](https://github.com/microsoft/vcpkg/pull/8177) Fix libyaml CMake package and CMake targets

- clapack `3.2.1-10` -> `3.2.1-12`
    - [(#8191)](https://github.com/microsoft/vcpkg/pull/8191) [clapack] Fix clapack-targets.cmake path in clpack-config.cmake
    - [(#8388)](https://github.com/microsoft/vcpkg/pull/8388) [clapack] fix clapack install

- embree3 `3.5.2-1` -> `3.5.2-2`
    - [(#8192)](https://github.com/microsoft/vcpkg/pull/8192) [embree3]Fix static build and cmake path.

- llvm `8.0.0` -> `8.0.0-2`
    - [(#7919)](https://github.com/microsoft/vcpkg/pull/7919) [llvm]Fix build error on Linux: cannot find -lxml2.
    - [(#8102)](https://github.com/microsoft/vcpkg/pull/8102) [halide]Upgrade to release_2019_08_27.

- vtk `8.2.0-5` -> `8.2.0-8`
    - [(#7933)](https://github.com/microsoft/vcpkg/pull/7933) [VTK] VTK links with release version of LMZA in debug build instead of debu…
    - [(#8345)](https://github.com/microsoft/vcpkg/pull/8345) [vtk] Fix vtk[python] build failure
    - [(#8403)](https://github.com/microsoft/vcpkg/pull/8403) [vtk] fix typo in lzma and lz4 patch

- dcmtk `3.6.4-1` -> `3.6.4-2`
    - [(#8202)](https://github.com/microsoft/vcpkg/pull/8202) [dcmtk] Fix build error on Linux

- openimageio `2019-08-08-2` -> `2019-08-08-4`
    - [(#8210)](https://github.com/microsoft/vcpkg/pull/8210) [openimageio] Add opencolorio as feature
    - [(#8230)](https://github.com/microsoft/vcpkg/pull/8230) [openimageio]Re-fix find openexr issue.
    - [(#8379)](https://github.com/microsoft/vcpkg/pull/8379) [alembic,geogram,openimageio]: openexr and libraw debug linkage, minor fix for geogram

- cli `1.1-1` -> `1.1.1`
    - [(#8209)](https://github.com/microsoft/vcpkg/pull/8209) [cli] Update the version to 1.1.1

- libepoxy `1.5.3` -> `1.5.3-1`
    - [(#7985)](https://github.com/microsoft/vcpkg/pull/7985) [libepoxy]Add support with unix.

- atk `2.24.0-3` -> `2.24.0-4`
    - [(#7991)](https://github.com/microsoft/vcpkg/pull/7991) [atk]Support UNIX.

- date `2019-05-18-1` -> `2019-09-09`
    - [(#8151)](https://github.com/microsoft/vcpkg/pull/8151) [date] Add official CMake targets support

- riffcpp `2.2.2` -> `2.2.4`
    - [(#8153)](https://github.com/microsoft/vcpkg/pull/8153) [riffcpp] Update to 2.2.4

- duktape `2.4.0-3` -> `2.4.0-4`
    - [(#8144)](https://github.com/microsoft/vcpkg/pull/8144) [duktape] Change download path of pip.

- cgicc `3.2.19-2` -> `3.2.19-3`
    - [(#8232)](https://github.com/microsoft/vcpkg/pull/8232) [cgicc]Fix linux build.

- graphicsmagick `1.3.32-1` -> `1.3.33`
    - [(#8256)](https://github.com/microsoft/vcpkg/pull/8256) [graphicsmagick] updated to 1.3.33

- ecsutil `1.0.7.2` -> `1.0.7.3`
    - [(#8253)](https://github.com/microsoft/vcpkg/pull/8253) update for ECSUtil 1.0.7.3

- cpp-redis `4.3.1-1` -> `4.3.1-2`
    - [(#8245)](https://github.com/microsoft/vcpkg/pull/8245) [simpleini cpp-redis tacopie] ports update

- simpleini `2018-08-31-1` -> `2018-08-31-2`
    - [(#8245)](https://github.com/microsoft/vcpkg/pull/8245) [simpleini cpp-redis tacopie] ports update

- tacopie `3.2.0-1` -> `3.2.0-2`
    - [(#8245)](https://github.com/microsoft/vcpkg/pull/8245) [simpleini cpp-redis tacopie] ports update

- cairo `1.16.0-1` -> `1.16.0-2`
    - [(#8249)](https://github.com/microsoft/vcpkg/pull/8249) [cairo]Add feature X11.

- tinynpy `1.0.0-2` -> `1.0.0-3`
    - [(#8274)](https://github.com/microsoft/vcpkg/pull/8274) [tinynpy] update

- io2d `2019-07-11` -> `2019-07-11-1`
    - [(#8251)](https://github.com/microsoft/vcpkg/pull/8251) [io2d]Fix linux build: add dependency cairo[x11].

- linenoise-ng `4754bee2d8eb3` -> `4754bee2d8eb3-1`
    - [(#8276)](https://github.com/microsoft/vcpkg/pull/8276) [linenoise-ng] Fix flaky config

- zeromq `2019-07-09-1` -> `2019-09-20`
    - [(#8119)](https://github.com/microsoft/vcpkg/pull/8119) [zeromq] Update to 2019-09-13

- basisu `1.11-1` -> `1.11-2`
    - [(#8289)](https://github.com/microsoft/vcpkg/pull/8289) [basisu] Updating with latest upstream changes

- doctest `2.3.4` -> `2.3.5`
    - [(#8295)](https://github.com/microsoft/vcpkg/pull/8295) [doctest] Update library to 2.3.5

- mbedtls `2.16.2` -> `2.16.3`
    - [(#8296)](https://github.com/microsoft/vcpkg/pull/8296) [mbedtls] Update library to 2.16.3

- pugixml `1.9-3` -> `1.10`
    - [(#8297)](https://github.com/microsoft/vcpkg/pull/8297) [pugixml] Update library to 1.10

- armadillo `2019-04-16-4` -> `2019-04-16-5`
    - [(#8299)](https://github.com/microsoft/vcpkg/pull/8299) [armadillo] Fix configure_file failed

- parallel-hashmap `1.23` -> `1.24`
    - [(#8301)](https://github.com/microsoft/vcpkg/pull/8301) [parallel-hashmap] Update library to 1.24

- realsense2 `2.22.0-1` -> `2.22.0-2`
    - [(#8303)](https://github.com/microsoft/vcpkg/pull/8303) [realsense2] fix dependency glfw3 and mismatching number of debug and release binaries

- ffmpeg `4.1-11` -> `4.2`
    - [(#8021)](https://github.com/microsoft/vcpkg/pull/8021) [ffmpeg] update to 4.2

- open62541 `0.3.0-3` -> `0.3.0-4`
    - [(#8252)](https://github.com/microsoft/vcpkg/pull/8252) [open62541] fix dynamic build

- librdkafka `1.1.0-1` -> `1.2.0-2`
    - [(#8307)](https://github.com/microsoft/vcpkg/pull/8307) [librdkafka] Update library to 1.2.0
    - [(#8355)](https://github.com/microsoft/vcpkg/pull/8355) [librdkafka] Add vcpkg-cmake-wrapper.cmake

- chartdir `6.3.1` -> `6.3.1-1`
    - [(#8308)](https://github.com/microsoft/vcpkg/pull/8308) [chartdir] fix hash for osx

- mpfr `4.0.1` -> `4.0.2-1`
    - [(#8324)](https://github.com/microsoft/vcpkg/pull/8324) update mpfr to 4.0.2 and fix build on osx

- cuda `9.0` -> `10.1`
    - [(#7536)](https://github.com/microsoft/vcpkg/pull/7536) [cudnn] add port and enable it in darknet

- darknet `0.2.5-6` -> `0.2.5.1`
    - [(#7536)](https://github.com/microsoft/vcpkg/pull/7536) [cudnn] add port and enable it in darknet

- opencv4 `4.1.1-1` -> `4.1.1-2`
    - [(#7536)](https://github.com/microsoft/vcpkg/pull/7536) [cudnn] add port and enable it in darknet

- libiconv `1.15-5` -> `1.15-6`
    - [(#8312)](https://github.com/microsoft/vcpkg/pull/8312) [libiconv] Guard imported targets in non-Windows

- gsoap `2.8.87-1` -> `2.8.93-1`
    - [(#8338)](https://github.com/microsoft/vcpkg/pull/8338) [gSoap] Update to 2.8.93

- arrow `0.14.1` -> `0.14.1-1`
    - [(#8263)](https://github.com/microsoft/vcpkg/pull/8263) [arrow]Fix build error on Visual Studio 2019.

- sol2 `3.0.3` -> `3.0.3-1`
    - [(#8243)](https://github.com/microsoft/vcpkg/pull/8243) [sol2]Fix using namespace.

- alembic `1.7.11-4` -> `1.7.11-5`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path
    - [(#8379)](https://github.com/microsoft/vcpkg/pull/8379) [alembic,geogram,openimageio]: openexr and libraw debug linkage, minor fix for geogram

- avro-c `1.8.2-2` -> `1.8.2-3`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- aws-sdk-cpp `1.7.142` -> `1.7.142-1`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- boost-system `1.70.0` -> `1.70.0-1`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- cgal `4.14-2` -> `4.14-3`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- eigen3 `3.3.7-2` -> `3.3.7-3`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- itk `5.0.1` -> `5.0.1-1`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- kinectsdk2 `2.0-1` -> `2.0-2`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- ompl `1.4.2-1` -> `1.4.2-2`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- openmvg `1.4-5` -> `1.4-6`
    - [(#8331)](https://github.com/microsoft/vcpkg/pull/8331) [many ports] Warning to VCPKG long build path

- curl `7.65.2-1` -> `7.66.0`
    - [(#7331)](https://github.com/microsoft/vcpkg/pull/7331) [curl] Update to 7.66.0

- halide `release_2018_02_15-1` -> `release_2019_08_27`
    - [(#8102)](https://github.com/microsoft/vcpkg/pull/8102) [halide]Upgrade to release_2019_08_27.

- boost-accumulators `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-algorithm `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-align `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-any `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-array `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-asio `1.70.0-2` -> `1.71.0-1`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-assert `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-assign `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-atomic `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-beast `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-bimap `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-bind `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-callable-traits `2.3.2` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-chrono `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-circular-buffer `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-compatibility `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-compute `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-concept-check `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-config `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-container-hash `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-container `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-context `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-contract `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-conversion `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-convert `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-core `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-coroutine `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-coroutine2 `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-crc `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-date-time `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-detail `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-disjoint-sets `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-dll `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-dynamic-bitset `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-endian `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-exception `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-fiber `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-filesystem `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-flyweight `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-foreach `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-format `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-function-types `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-function `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-functional `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-fusion `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-geometry `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-gil `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-graph-parallel `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-graph `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- boost-hana `1.70.0` -> `1.71.0`
    - [(#7959)](https://github.com/microsoft/vcpkg/pull/7959) [boost] Update to 1.71.0

- hpx `1.3.0-1` -> `1.3.0-2`
    - [(#8259)](https://github.com/microsoft/vcpkg/pull/8259) [hpx] Redirect --head to `stable`

- assimp `4.1.0-8` -> `5.0.0`
    - [(#8370)](https://github.com/microsoft/vcpkg/pull/8370) [assimp] Update the version to 5.0.0
    - [(#8381)](https://github.com/microsoft/vcpkg/pull/8381) [assimp] Update the version

- angle `2019-06-13` -> `2019-07-19-2`
    - [(#7329)](https://github.com/microsoft/vcpkg/pull/7329) [angle] Update to the latest commit.
    - [(#8395)](https://github.com/microsoft/vcpkg/pull/8395) drop useless patch

</details>

-- vcpkg team vcpkg@microsoft.com TUE, 01 Oct 22:00:00 -0800

vcpkg (2019.08.31)
---
#### Total port count: 1169
#### Total port count per triplet (tested): 
|triplet|ports available|
|---|---|
|**x64-windows**|1099|
|x86-windows|1085|
|x64-windows-static|987|
|**x64-linux**|930|
|**x64-osx**|876|
|arm64-windows|726|
|x64-uwp|595|
|arm-uwp|571|

#### The following commands and options have been updated:
- `depend-info`
    - `--max-recurse` ***[NEW OPTION]***: Set the max depth of recursion for listing dependencies 
    - `--sort` ***[NEW OPTION]***: Sort the list of dependencies by  `lexicographical`, `topological`, and `reverse` (topological) order
    - `--show-depth` ***[NEW OPTION]***: Display the depth of each dependency in the list
      - [(#7643)](https://github.com/microsoft/vcpkg/pull/7643) [depend-info] Fix bugs, add `--sort`, `--show-depth` and `--max-recurse` options
- `install --only-downloads` ***[NEW OPTION]***
    - Download sources for a package and its dependencies and don't build them
      - [(#7950)](https://github.com/microsoft/vcpkg/pull/7950) [vcpkg install] Enable Download Mode ⏬

#### The following documentation has been updated:
- [Index](docs/index.md)
    - [(#7506)](https://github.com/microsoft/vcpkg/pull/7506) Update tests, and add documentation!
    - [(#7821)](https://github.com/microsoft/vcpkg/pull/7821) [vcpkg docs] More tool maintainer docs! 🐱‍👤
- [Tool maintainers: Testing](docs/tool-maintainers/testing.md) ***[NEW]***
    - [(#7506)](https://github.com/microsoft/vcpkg/pull/7506) Update tests, and add documentation!
    - [(#7821)](https://github.com/microsoft/vcpkg/pull/7821) [vcpkg docs] More tool maintainer docs! 🐱‍👤
- [Examples: Overlay triplets example
](docs/examples/overlay-triplets-linux-dynamic.md)
    - [(#7502)](https://github.com/microsoft/vcpkg/pull/7502) [vcpkg-docs] Reword and reorganize overlay-triplets-linux-dynamic.md
- [Portfile helper functions](docs/maintainers/portfile-functions.md)
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
    - [(#7950)](https://github.com/microsoft/vcpkg/pull/7950) [vcpkg install] Enable Download Mode ⏬
- [`vcpkg_check_features`](docs/maintainers/vcpkg_check_features.md)
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
- [`vcpkg_configure_cmake`](docs/maintainers/vcpkg_configure_cmake.md)
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
- [`vcpkg_pretiffy_command`](docs/maintainers/vcpkg_prettify_command.md) ***[NEW]***
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
- [Maintainer Guidelines and Policies](docs/maintainers/maintainer-guide.md)
    - [(#7751)](https://github.com/microsoft/vcpkg/pull/7751) Add guideline for overriding `VCPKG_<VARIABLE>`
- [Tool maintainers: Benchmarking](docs/tool-maintainers/benchmarking.md) ***[NEW]***
    - [(#7821)](https://github.com/microsoft/vcpkg/pull/7821) [vcpkg docs] More tool maintainer docs! 🐱‍👤
- [Tool maintainers: Layout of the vcpkg source tree](docs/tool-maintainers/layout.md) ***[NEW]***
    - [(#7821)](https://github.com/microsoft/vcpkg/pull/7821) [vcpkg docs] More tool maintainer docs! 🐱‍👤
- [`vcpkg_common_definitions`](docs/maintainers/vcpkg_common_definitions.md) ***[NEW]***
    - [(#7950)](https://github.com/microsoft/vcpkg/pull/7950) [vcpkg install] Enable Download Mode ⏬
- [`vcpkg_execute_required_process`](docs/maintainers/vcpkg_execute_required_process.md)
    - [(#7950)](https://github.com/microsoft/vcpkg/pull/7950) [vcpkg install] Enable Download Mode ⏬
- [`vcpkg_fail_port_install`](docs/maintainers/vcpkg_fail_port_install.md) ***[NEW]***
    - [(#7950)](https://github.com/microsoft/vcpkg/pull/7950) [vcpkg install] Enable Download Mode ⏬

#### The following *remarkable* changes have been made to vcpkg's infrastructure:
- CONTROL files extended syntax
  - The `Build-Depends` field now supports logical expressions as well as line breaks
    - [(#7508)](https://github.com/microsoft/vcpkg/pull/7508) Improve logical evaluation of dependency qualifiers
    - [(#7863)](https://github.com/microsoft/vcpkg/pull/7863) Fix list parsing logic and add error messages
- Quality-of-Life improvements for portfile maintainers 
  - [(#7601)](https://github.com/microsoft/vcpkg/pull/7601) [vcpkg/cmake] Added a function to fail from portfiles in a default way
  - [(#7600)](https://github.com/microsoft/vcpkg/pull/7600) [vcpkg] QoL: add target dependent library prefix/suffix variables and enable find_library for portfiles
  - [(#7773)](https://github.com/microsoft/vcpkg/pull/7773) [vcpkg] QoL: Make find_library useable without errors to console.
  - [(#7599)](https://github.com/microsoft/vcpkg/pull/7599) [vcpkg] QoL: add host/target dependent variables for executable suffixes 

#### The following *additional* changes have been made to vcpkg's infrastructure:
- [(#4572)](https://github.com/microsoft/vcpkg/pull/4572) Change CMakeLists.txt in toolsrc to allow compiling with llvm toolset
- [(#7305)](https://github.com/microsoft/vcpkg/pull/7305) [vcpkg] Public ABI override option
- [(#7307)](https://github.com/microsoft/vcpkg/pull/7307) [vcpkg] Always calculate ABI tags
- [(#7491)](https://github.com/microsoft/vcpkg/pull/7491) Handle response files with Windows line-endings properly
- [(#7501)](https://github.com/microsoft/vcpkg/pull/7501) Add July changelog
- [(#7506)](https://github.com/microsoft/vcpkg/pull/7506) Update tests, and add documentation!
- [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
- [(#7568)](https://github.com/microsoft/vcpkg/pull/7568) [tensorflow] Add new port for linux
- [(#7570)](https://github.com/microsoft/vcpkg/pull/7570) [vcpkg] Make `RealFilesystem::remove_all` much, much faster, and start benchmarking
- [(#7587)](https://github.com/microsoft/vcpkg/pull/7587) [vcpkg] Revert accidental removal of powershell-core usage in bb3a9ddb6ec917f54
- [(#7619)](https://github.com/microsoft/vcpkg/pull/7619) [vcpkg] Fix `.vcpkg-root` detection issue
- [(#7620)](https://github.com/microsoft/vcpkg/pull/7620) [vcpkg] Fix warnings in `files.{h,cpp}` build under /W4
- [(#7623)](https://github.com/microsoft/vcpkg/pull/7623) Fix VS 2019 detection bug
- [(#7637)](https://github.com/microsoft/vcpkg/pull/7637) [vcpkg] Fix the build on VS2015 debug
- [(#7638)](https://github.com/microsoft/vcpkg/pull/7638) [vcpkg] Make CMakelists nicer 😁
- [(#7687)](https://github.com/microsoft/vcpkg/pull/7687) [vcpkg] Port toolchains
- [(#7754)](https://github.com/microsoft/vcpkg/pull/7754) [vcpkg] Allow multiple spaces in a comma list
- [(#7757)](https://github.com/microsoft/vcpkg/pull/7757) [vcpkg] Switch to internal hash algorithms 🐱‍💻
- [(#7793)](https://github.com/microsoft/vcpkg/pull/7793) Allow redirection of the scripts folder
- [(#7798)](https://github.com/microsoft/vcpkg/pull/7798) [vcpkg] Fix build on FreeBSD 😈
- [(#7816)](https://github.com/microsoft/vcpkg/pull/7816) [vcpkg] Fix gcc-9 warning
- [(#7864)](https://github.com/microsoft/vcpkg/pull/7864) [vcpkg] Move `do_build_package_and_clean_buildtrees()` above generating vcpkg_abi_info.txt so it will be included in the package.
- [(#7930)](https://github.com/microsoft/vcpkg/pull/7930) [vcpkg] fix bug in StringView::operator== 😱
<details>
<summary><b>The following 63 ports have been added:</b></summary>

|port|version|
|---|---|
|[riffcpp](https://github.com/microsoft/vcpkg/pull/7509) [#7541](https://github.com/microsoft/vcpkg/pull/7541) [#7859](https://github.com/microsoft/vcpkg/pull/7859) | 2.2.2
|[easyhook](https://github.com/microsoft/vcpkg/pull/7487)| 2.7.6789.0
|[brigand](https://github.com/microsoft/vcpkg/pull/7518)| 1.3.0
|[ctbignum](https://github.com/microsoft/vcpkg/pull/7512)| 2019-08-02
|[gaussianlib](https://github.com/microsoft/vcpkg/pull/7542)| 2019-08-04
|[tinycthread](https://github.com/microsoft/vcpkg/pull/7565)| 2019-08-06
|[libcerf](https://github.com/microsoft/vcpkg/pull/7320)| 1.13
|[tinynpy](https://github.com/microsoft/vcpkg/pull/7393)| 1.0.0-2
|[googleapis](https://github.com/microsoft/vcpkg/pull/7557) [#7703](https://github.com/microsoft/vcpkg/pull/7703) | 0.1.3
|[pdqsort](https://github.com/microsoft/vcpkg/pull/7464)| 2019-07-30
|[discount](https://github.com/microsoft/vcpkg/pull/7400)| 2.2.6
|[duckx](https://github.com/microsoft/vcpkg/pull/7561)| 2019-08-06
|[opencv3](https://github.com/microsoft/vcpkg/pull/5169) [#7581](https://github.com/microsoft/vcpkg/pull/7581) [#7658](https://github.com/microsoft/vcpkg/pull/7658) [#7925](https://github.com/microsoft/vcpkg/pull/7925) | 3.4.7-1
|[opencv4](https://github.com/microsoft/vcpkg/pull/5169) [#7558](https://github.com/microsoft/vcpkg/pull/7558) [#7581](https://github.com/microsoft/vcpkg/pull/7581) [#7658](https://github.com/microsoft/vcpkg/pull/7658) | 4.1.1-1
|[tiny-bignum-c](https://github.com/microsoft/vcpkg/pull/7531)| 2019-07-31
|[tgc](https://github.com/microsoft/vcpkg/pull/7644)| 2019-08-11
|[bento4](https://github.com/microsoft/vcpkg/pull/7595)| 1.5.1-628
|[dbow2](https://github.com/microsoft/vcpkg/pull/7552)| 2019-08-05
|[tiny-aes-c](https://github.com/microsoft/vcpkg/pull/7530)| 2019-07-31
|[drlibs](https://github.com/microsoft/vcpkg/pull/7656)| 2019-08-12
|[nt-wrapper](https://github.com/microsoft/vcpkg/pull/7633)| 2019-08-10
|[xorstr](https://github.com/microsoft/vcpkg/pull/7631)| 2019-08-10
|[lazy-importer](https://github.com/microsoft/vcpkg/pull/7630)| 2019-08-10
|[plf-colony](https://github.com/microsoft/vcpkg/pull/7627)| 2019-08-10
|[plf-list](https://github.com/microsoft/vcpkg/pull/7627)| 2019-08-10
|[plf-nanotimer](https://github.com/microsoft/vcpkg/pull/7627)| 2019-08-10
|[plf-stack](https://github.com/microsoft/vcpkg/pull/7627)| 2019-08-10
|[tiny-regex-c](https://github.com/microsoft/vcpkg/pull/7626)| 2019-07-31
|[hayai](https://github.com/microsoft/vcpkg/pull/7624)| 2019-08-10
|[yasm](https://github.com/microsoft/vcpkg/pull/7478)| 1.3.0
|[fast-cpp-csv-parser](https://github.com/microsoft/vcpkg/pull/7681)| 2019-08-14
|[wg21-sg14](https://github.com/microsoft/vcpkg/pull/7663)| 2019-08-13
|[pistache](https://github.com/microsoft/vcpkg/pull/7547)| 2019-08-05
|[hfsm2](https://github.com/microsoft/vcpkg/pull/7516)| beta7
|[mpmcqueue](https://github.com/microsoft/vcpkg/pull/7437)| 2019-07-26
|[spscqueue](https://github.com/microsoft/vcpkg/pull/7437)| 2019-07-26
|[tinkerforge](https://github.com/microsoft/vcpkg/pull/7523)| 2.1.25
|[field3d](https://github.com/microsoft/vcpkg/pull/7594)| 1.7.2
|[libsvm](https://github.com/microsoft/vcpkg/pull/7664)| 323
|[nanort](https://github.com/microsoft/vcpkg/pull/7778)| 2019-08-20
|[libspatialindex](https://github.com/microsoft/vcpkg/pull/7762)| 1.9.0
|[qtkeychain](https://github.com/microsoft/vcpkg/pull/7760)| v0.9.1
|[sparsehash](https://github.com/microsoft/vcpkg/pull/7772)| 2.0.3
|[tensorflow-cc](https://github.com/microsoft/vcpkg/pull/7568)| 1.14
|[qt-advanced-docking-system](https://github.com/microsoft/vcpkg/pull/7621)| 2019-08-14
|[quickfast](https://github.com/microsoft/vcpkg/pull/7814)| 1.5
|[mp3lame](https://github.com/microsoft/vcpkg/pull/7830)| 3.100
|[quickfix](https://github.com/microsoft/vcpkg/pull/7796)| 1.15.1
|[fplus](https://github.com/microsoft/vcpkg/pull/7883)| 0.2.3-p0
|[json5-parser](https://github.com/microsoft/vcpkg/pull/7915)| 1.0.0
|[gppanel](https://github.com/microsoft/vcpkg/pull/7868)| 2018-04-06
|[libguarded](https://github.com/microsoft/vcpkg/pull/7924)| 2019-08-27
|[cgl](https://github.com/microsoft/vcpkg/pull/7810)| 0.60.2-1
|[minifb](https://github.com/microsoft/vcpkg/pull/7766)| 2019-08-20-1
|[log4cpp](https://github.com/microsoft/vcpkg/pull/7433)| 2.9.1-1
|[chartdir](https://github.com/microsoft/vcpkg/pull/7912)| 6.3.1
|[outcome](https://github.com/microsoft/vcpkg/pull/7940)| 2.1
|[libP7Client](https://github.com/microsoft/vcpkg/pull/7605)| 5.2
|[clue](https://github.com/microsoft/vcpkg/pull/7564)| 1.0.0-alpha.7
|[status-value-lite](https://github.com/microsoft/vcpkg/pull/7563)| 1.1.0
|[type-lite](https://github.com/microsoft/vcpkg/pull/7563)| 0.1.0
|[value-ptr-lite](https://github.com/microsoft/vcpkg/pull/7563)| 0.2.1
|[kvasir-mpl](https://github.com/microsoft/vcpkg/pull/7562)| 2019-08-06
</details>

<details>
<summary><b>The following 199 ports have been updated:</b></summary>

- pcl `1.9.1-5` -> `1.9.1-8`
    - [(#7413)](https://github.com/microsoft/vcpkg/pull/7413) [pcl] Fix Build failure in linux
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
    - [(#7700)](https://github.com/microsoft/vcpkg/pull/7700) [czmq/pcl] Fix judgment feature condition.

- xalan-c `1.11-5` -> `1.11-7`
    - [(#7496)](https://github.com/microsoft/vcpkg/pull/7496) [xalan-c] Bump version number
    - [(#7505)](https://github.com/microsoft/vcpkg/pull/7505) [xalan-c] switch to https://github.com/apache/xalan-c (#7489)

- catch2 `2.7.2-2` -> `2.9.2`
    - [(#7497)](https://github.com/microsoft/vcpkg/pull/7497) [Catch2] Update to v2.9.1
    - [(#7702)](https://github.com/microsoft/vcpkg/pull/7702) [brynet, catch2, chakracore] Update some ports version

- ade `0.1.1d` -> `0.1.1f`
    - [(#7494)](https://github.com/microsoft/vcpkg/pull/7494) Update some ports version
    - [(#7628)](https://github.com/microsoft/vcpkg/pull/7628) [ade] Update library to 0.1.1f

- harfbuzz `2.5.1-1` -> `2.5.3`
    - [(#7494)](https://github.com/microsoft/vcpkg/pull/7494) Update some ports version

- libpmemobj-cpp `1.6-1` -> `1.7`
    - [(#7494)](https://github.com/microsoft/vcpkg/pull/7494) Update some ports version

- msgpack `3.1.1` -> `3.2.0`
    - [(#7494)](https://github.com/microsoft/vcpkg/pull/7494) Update some ports version

- protobuf `3.8.0-1` -> `3.9.1`
    - [(#7494)](https://github.com/microsoft/vcpkg/pull/7494) Update some ports version
    - [(#7671)](https://github.com/microsoft/vcpkg/pull/7671) [protobuf] Update from 3.9.0 to 3.9.1

- string-theory `2.1-1` -> `2.2`
    - [(#7494)](https://github.com/microsoft/vcpkg/pull/7494) Update some ports version

- ccfits `2.5-2` -> `2.5-3`
    - [(#7484)](https://github.com/microsoft/vcpkg/pull/7484) [manyports] Regenerate patches and modify how the patches are used.

- itpp `4.3.1` -> `4.3.1-1`
    - [(#7484)](https://github.com/microsoft/vcpkg/pull/7484) [manyports] Regenerate patches and modify how the patches are used.

- mpg123 `1.25.8-5` -> `1.25.8-6`
    - [(#7484)](https://github.com/microsoft/vcpkg/pull/7484) [manyports] Regenerate patches and modify how the patches are used.

- qwt `6.1.3-6` -> `6.1.3-7`
    - [(#7484)](https://github.com/microsoft/vcpkg/pull/7484) [manyports] Regenerate patches and modify how the patches are used.

- sdl1 `1.2.15-5` -> `1.2.15-6`
    - [(#7484)](https://github.com/microsoft/vcpkg/pull/7484) [manyports] Regenerate patches and modify how the patches are used.

- gdal `2.4.1-5` -> `2.4.1-8`
    - [(#7520)](https://github.com/microsoft/vcpkg/pull/7520) [gdal] Fix duplicate pdb file
    - [(#7434)](https://github.com/microsoft/vcpkg/pull/7434) [gdal] Fix dependent ports in static builds.

- blosc `1.16.3-2` -> `1.17.0-1`
    - [(#7525)](https://github.com/microsoft/vcpkg/pull/7525) Update some ports version
    - [(#7649)](https://github.com/microsoft/vcpkg/pull/7649) [blosc] enable dependent ports to use debug builds

- boost-callable-traits `1.70.0` -> `2.3.2`
    - [(#7525)](https://github.com/microsoft/vcpkg/pull/7525) Update some ports version

- cjson `1.7.10-1` -> `1.7.12`
    - [(#7525)](https://github.com/microsoft/vcpkg/pull/7525) Update some ports version

- cppzmq `4.3.0-1` -> `4.4.1`
    - [(#7525)](https://github.com/microsoft/vcpkg/pull/7525) Update some ports version

- restinio `0.5.1-1` -> `0.6.0`
    - [(#7514)](https://github.com/microsoft/vcpkg/pull/7514) [RESTinio] updated to v.0.5.1.1
    - [(#7962)](https://github.com/microsoft/vcpkg/pull/7962) RESTinio updated to v.0.6.0

- argh `2018-12-18` -> `2018-12-18-1`
    - [(#7527)](https://github.com/microsoft/vcpkg/pull/7527) [argh] fix flaky cmake config

- libusb `1.0.22-3` -> `1.0.22-4`
    - [(#7465)](https://github.com/microsoft/vcpkg/pull/7465) [libusb] Fix using mismatched CRT_linkage/library_linkage issue.

- casclib `1.50` -> `1.50b-1`
    - [(#7522)](https://github.com/microsoft/vcpkg/pull/7522) [casclib] Added CMake targets
    - [(#7907)](https://github.com/microsoft/vcpkg/pull/7907) [casclib] Update library to 1.50b

- opencv `3.4.3-9` -> `4.1.1-1`
    - [(#7499)](https://github.com/microsoft/vcpkg/pull/7499) Add feature halide to OpenCV.
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1
    - [(#7659)](https://github.com/microsoft/vcpkg/pull/7659) [opencv] Expose all features from `opencv4` in meta-package
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- openxr-loader `1.0.0-1` -> `1.0.0-2`
    - [(#7560)](https://github.com/microsoft/vcpkg/pull/7560) [Openxr-loader] Remove the invalid patch

- simdjson `2019-03-09` -> `2019-08-05`
    - [(#7546)](https://github.com/microsoft/vcpkg/pull/7546) [simdjson] Update to 0.2.1

- alembic `1.7.11-3` -> `1.7.11-4`
    - [(#7551)](https://github.com/microsoft/vcpkg/pull/7551) [alembic] fix hdf5 linkage

- xerces-c `3.2.2-10` -> `3.2.2-11`
    - [(#7500)](https://github.com/microsoft/vcpkg/pull/7500) [xercec-c] no symlinks in static build (#7490)
    - [(#7622)](https://github.com/microsoft/vcpkg/pull/7622) [tiff][tesseract][xerces-c] Disable unmanaged optional dependencies

- sol2 `3.0.2` -> `3.0.3`
    - [(#7545)](https://github.com/microsoft/vcpkg/pull/7545) Update sol2 portfile to 579908
    - [(#7804)](https://github.com/microsoft/vcpkg/pull/7804) [sol2] Update library to 3.0.3

- cpprestsdk `2.10.14` -> `2.10.14-1`
    - [(#7472)](https://github.com/microsoft/vcpkg/pull/7472) Repair compression dependency bugs in cpprestsdk
    - [(#7863)](https://github.com/microsoft/vcpkg/pull/7863) fix list parsing logic and add error messages

- libevent `2.1.10` -> `2.1.11`
    - [(#7515)](https://github.com/microsoft/vcpkg/pull/7515) [libevent] update to 2.1.11

- imgui `1.70-1` -> `1.72b`
    - [(#7534)](https://github.com/microsoft/vcpkg/pull/7534) Update some ports version

- mbedtls `2.15.1` -> `2.16.2`
    - [(#7534)](https://github.com/microsoft/vcpkg/pull/7534) Update some ports version

- ffmpeg `4.1-8` -> `4.1-9`
    - [(#7476)](https://github.com/microsoft/vcpkg/pull/7476) [ffmpeg] Fix debug build in Windows.
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1
    - [(#7608)](https://github.com/microsoft/vcpkg/pull/7608) [ffmpeg] Add feature avresample.
    - [(#7739)](https://github.com/microsoft/vcpkg/pull/7739) [ffmpeg] Fix static linking on Windows, FindFFMPEG

- kangaru `4.1.3-2` -> `4.2.0`
    - [(#7567)](https://github.com/microsoft/vcpkg/pull/7567) Updated kangaru version

- cpp-taskflow `2018-11-30` -> `2.2.0`
    - [(#7554)](https://github.com/microsoft/vcpkg/pull/7554) [cpp-taskflow] update to 2.2.0

- jsoncons `0.125.0` -> `0.132.1`
    - [(#7529)](https://github.com/microsoft/vcpkg/pull/7529) Update jsoncons to v0.131.2
    - [(#7718)](https://github.com/microsoft/vcpkg/pull/7718) [jsoncons] Update library to 0.132.1

- tinyexif `1.0.2-5` -> `1.0.2-6`
    - [(#7575)](https://github.com/microsoft/vcpkg/pull/7575) [TinyEXIF] fix linux/mac

- itk `5.0.0-2` -> `5.0.1`
    - [(#7241)](https://github.com/microsoft/vcpkg/pull/7241) ITK portfile support legacy user code by default
    - [(#7586)](https://github.com/microsoft/vcpkg/pull/7586) [itk] Update library from 5.0.0 to 5.0.1

- stxxl `2018-11-15-1` -> `2018-11-15-2`
    - [(#7330)](https://github.com/microsoft/vcpkg/pull/7330) [stxxl] compilation fix

- chakracore `1.11.9` -> `1.11.12`
    - [(#7576)](https://github.com/microsoft/vcpkg/pull/7576) [chakracore] Update library to 1.11.11
    - [(#7702)](https://github.com/microsoft/vcpkg/pull/7702) [brynet, catch2, chakracore] Update some ports version

- qhull `7.3.2` -> `7.3.2-1`
    - [(#7370)](https://github.com/microsoft/vcpkg/pull/7370) [Qhulluwp] fix uwp building

- netcdf-c `4.7.0-3` -> `4.7.0-4`
    - [(#7578)](https://github.com/microsoft/vcpkg/pull/7578) [netcdf-c] correctly fix hdf5 linkage

- google-cloud-cpp `0.11.0` -> `0.12.0`
    - [(#7557)](https://github.com/microsoft/vcpkg/pull/7557) Update google-cloud-cpp to 0.12.0.

- stormlib `9.22` -> `2019-05-10`
    - [(#7409)](https://github.com/microsoft/vcpkg/pull/7409) [stormlib] Add targets and streamline build

- openimageio `2.0.8` -> `2019-08-08-2`
    - [(#7419)](https://github.com/microsoft/vcpkg/pull/7419) [openimageio] Fix feature libraw build errors
    - [(#7588)](https://github.com/microsoft/vcpkg/pull/7588) [openimageio] find_package support
    - [(#7747)](https://github.com/microsoft/vcpkg/pull/7747) [openimageio] Fix find correct debug/release openexr libraries.

- librdkafka `1.1.0` -> `1.1.0-1`
    - [(#7469)](https://github.com/microsoft/vcpkg/pull/7469) Librdkafka snappy
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- open62541 `0.3.0-2` -> `0.3.0-3`
    - [(#7607)](https://github.com/microsoft/vcpkg/pull/7607) [open62541] Fix flakiness/bugginess

- jsonnet `2019-05-08` -> `2019-05-08-1`
    - [(#7587)](https://github.com/microsoft/vcpkg/pull/7587) [vcpkg] Revert accidental removal of powershell-core usage in bb3a9ddb6ec917f54
    - [(#7374)](https://github.com/microsoft/vcpkg/pull/7374) [jsonnet] Upgrade version to 0.13.0

- expat `2.2.6` -> `2.2.7`
    - [(#7596)](https://github.com/microsoft/vcpkg/pull/7596) [expat] Update library to 2.2.7

- aws-lambda-cpp `0.1.0-1` -> `0.1.0-2`
    - [(#7601)](https://github.com/microsoft/vcpkg/pull/7601) [vcpkg/cmake] Added a function to fail from portfiles in a default way

- rocksdb `6.1.2` -> `6.1.2-1`
    - [(#7452)](https://github.com/microsoft/vcpkg/pull/7452) [rocksdb] Change linkage type to static.
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- freeimage `3.18.0-6` -> `3.18.0-7`
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1

- gdcm `3.0.0-3` -> `3.0.0-4`
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1

- ogre `1.12.0-1` -> `1.12.1`
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- pthreads `3.0.0-2` -> `3.0.0-3`
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1

- qt5 `5.12.3` -> `5.12.3-1`
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1
    - [(#7642)](https://github.com/microsoft/vcpkg/pull/7642) [qt5] Only build qt5-activeqt on windows

- zxing-cpp `3.3.3-5` -> `3.3.3-6`
    - [(#5169)](https://github.com/microsoft/vcpkg/pull/5169) [OpenCV] Update to v4.1.1

- tesseract `4.1.0-1` -> `4.1.0-2`
    - [(#7622)](https://github.com/microsoft/vcpkg/pull/7622) [tiff][tesseract][xerces-c] Disable unmanaged optional dependencies

- tiff `4.0.10-6` -> `4.0.10-7`
    - [(#7622)](https://github.com/microsoft/vcpkg/pull/7622) [tiff][tesseract][xerces-c] Disable unmanaged optional dependencies

- osg `3.6.3-1` -> `3.6.4`
    - [(#7653)](https://github.com/microsoft/vcpkg/pull/7653) [osg] Update osg version to 3.6.4
    - [(#7677)](https://github.com/microsoft/vcpkg/pull/7677) [osg] Fix Applying patch failed

- cppgraphqlgen `3.0.0` -> `3.0.2`
    - [(#7639)](https://github.com/microsoft/vcpkg/pull/7639) [cppgraphqlgen] Update with matching PEGTL

- pegtl `3.0.0-pre` -> `3.0.0-pre-697aaa0`
    - [(#7639)](https://github.com/microsoft/vcpkg/pull/7639) [cppgraphqlgen] Update with matching PEGTL

- monkeys-audio `4.3.3-1` -> `4.8.3`
    - [(#7634)](https://github.com/microsoft/vcpkg/pull/7634) [monkeys-audio] Update library to 4.8.3

- directxmesh `apr2019` -> `jun2019-1`
    - [(#7665)](https://github.com/microsoft/vcpkg/pull/7665) [directxtk][directxtk12][directxmesh][directxtex] Updated to June version and improved platform toolset support
    - [(#7869)](https://github.com/microsoft/vcpkg/pull/7869) [directxmesh] Update library to aug2019

- directxtex `apr2019` -> `jun2019-1`
    - [(#7665)](https://github.com/microsoft/vcpkg/pull/7665) [directxtk][directxtk12][directxmesh][directxtex] Updated to June version and improved platform toolset support
    - [(#7870)](https://github.com/microsoft/vcpkg/pull/7870) [directxtex] Update library to aug2019

- directxtk `apr2019-1` -> `jun2019-1`
    - [(#7665)](https://github.com/microsoft/vcpkg/pull/7665) [directxtk][directxtk12][directxmesh][directxtex] Updated to June version and improved platform toolset support
    - [(#7871)](https://github.com/microsoft/vcpkg/pull/7871) [directxtk] Update library to aug2019

- directxtk12 `dec2016-1` -> `jun2019-1`
    - [(#7665)](https://github.com/microsoft/vcpkg/pull/7665) [directxtk][directxtk12][directxmesh][directxtex] Updated to June version and improved platform toolset support
    - [(#7872)](https://github.com/microsoft/vcpkg/pull/7872) [directxtk12] Update library to aug2019

- usockets `0.1.2` -> `0.3.1`
    - [(#7662)](https://github.com/microsoft/vcpkg/pull/7662) [usockets] upgrade to v0.3.1

- dimcli `4.1.0` -> `5.0.0`
    - [(#7651)](https://github.com/microsoft/vcpkg/pull/7651) [dimcli] Fix build error C2220
    - [(#7785)](https://github.com/microsoft/vcpkg/pull/7785) [dimcli] Update library to 5.0.0

- czmq `2019-06-10-1` -> `2019-06-10-3`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
    - [(#7700)](https://github.com/microsoft/vcpkg/pull/7700) [czmq/pcl] Fix judgment feature condition.

- darknet `0.2.5-5` -> `0.2.5-6`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- mimalloc `2019-06-25` -> `2019-06-25-1`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- mongo-c-driver `1.14.0-3` -> `1.14.0-3-1`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- oniguruma `6.9.2-2` -> `6.9.3`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
    - [(#7721)](https://github.com/microsoft/vcpkg/pull/7721) [oniguruma] Update library 6.9.3

- paho-mqttpp3 `1.0.1` -> `1.0.1-2`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check
    - [(#7769)](https://github.com/microsoft/vcpkg/pull/7769) [paho-mqttpp3] Fix missing reference to C library headers

- xsimd `7.2.3-1` -> `7.2.3-2`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- xtensor `0.20.7-1` -> `0.20.7-2`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- zeromq `2019-07-09` -> `2019-07-09-1`
    - [(#7558)](https://github.com/microsoft/vcpkg/pull/7558) [vcpkg_check_features] Set output variable explicitly and allow reverse-logic check

- gtest `2019-01-04-2` -> `2019-08-14-1`
    - [(#7692)](https://github.com/microsoft/vcpkg/pull/7692) [gtest] update to 90a443f9c2437ca8a682a1ac625eba64e1d74a8a
    - [(#7316)](https://github.com/microsoft/vcpkg/pull/7316) [gtest] Re-fix port_main/port_maind libraries path and add gmock cmake files.

- physx `commit-624f2cb6c0392013d54b235d9072a49d01c3cb6c` -> `4.1.1-1`
    - [(#7679)](https://github.com/microsoft/vcpkg/pull/7679) [physx] Update to 4.1.1 (with Visual Studio 2019 support)

- libidn2 `2.1.1-1` -> `2.2.0`
    - [(#7685)](https://github.com/microsoft/vcpkg/pull/7685) [libidn2] Update to version 2.2.0.

- poco `2.0.0-pre-3` -> `1.9.2-1`
    - [(#7698)](https://github.com/microsoft/vcpkg/pull/7698) [poco] Upgrade version to 1.9.2 release.
    - [(#7892)](https://github.com/microsoft/vcpkg/pull/7892) [poco] Fix conflicts with libharu.

- osgearth `2.10.1` -> `2.10.2`
    - [(#7695)](https://github.com/microsoft/vcpkg/pull/7695) [osgearth] Fix osgearth rocksdb plugin build falied

- spdlog `1.3.1-1` -> `1.3.1-2`
    - [(#7670)](https://github.com/microsoft/vcpkg/pull/7670) [spdlog] fix cmake targets path

- libgit2 `0.28.2` -> `0.28.3`
    - [(#7669)](https://github.com/microsoft/vcpkg/pull/7669) [libgit2] Upgrade to version 0.28.3

- brynet `1.0.2` -> `1.0.3`
    - [(#7702)](https://github.com/microsoft/vcpkg/pull/7702) [brynet, catch2, chakracore] Update some ports version

- nghttp2 `1.35.0` -> `1.39.2`
    - [(#7699)](https://github.com/microsoft/vcpkg/pull/7699) [nghttp2] Upgrade to version 1.39.2

- leptonica `1.76.0-1` -> `1.78.0-1`
    - [(#7358)](https://github.com/microsoft/vcpkg/pull/7358) [leptonica] Upgrade to 1.78.0
    - [(#7712)](https://github.com/microsoft/vcpkg/pull/7712) [leptonica] Add dependency port libwebp and fix find libwebp in debug/release

- libtorrent `2019-04-19` -> `1.2.1-bcb26fd6`
    - [(#7708)](https://github.com/microsoft/vcpkg/pull/7708) [libtorrent] Update to 1.2.1-bcb26fd6

- angelscript `2.33.0-1` -> `2.33.1-1`
    - [(#7650)](https://github.com/microsoft/vcpkg/pull/7650) [angelscript] Added feature to optionally install all Angelscript standard addons

- jsoncpp `1.8.4-1` -> `1.9.1`
    - [(#7719)](https://github.com/microsoft/vcpkg/pull/7719) [jsoncpp] Update library to 1.9.1

- robin-hood-hashing `3.2.13` -> `3.4.0`
    - [(#7722)](https://github.com/microsoft/vcpkg/pull/7722) [robin-hood-hashing] Update library to 3.4.0

- sqlite-orm `1.3-1` -> `1.4`
    - [(#7723)](https://github.com/microsoft/vcpkg/pull/7723) [sqlite-orm] Update library to 1.4

- doctest `2.3.3` -> `2.3.4`
    - [(#7716)](https://github.com/microsoft/vcpkg/pull/7716) [doctest] Update library to 2.3.4

- pegtl-2 `2.8.0` -> `2.8.1`
    - [(#7715)](https://github.com/microsoft/vcpkg/pull/7715) [pegtl-2] Update library to 2.8.1

- cpp-httplib `0.2.0` -> `0.2.1`
    - [(#7714)](https://github.com/microsoft/vcpkg/pull/7714) [cpp-httplib] Update library to 0.2.1

- geographiclib `1.47-patch1-6` -> `1.47-patch1-7`
    - [(#7697)](https://github.com/microsoft/vcpkg/pull/7697) [geographiclib] Fix build error on Linux

- libmariadb `3.0.10-3` -> `3.0.10-4`
    - [(#7710)](https://github.com/microsoft/vcpkg/pull/7710) [libmariadb] Fix usage error LNK2001.

- irrlicht `1.8.4-2` -> `1.8.4-1`
    - [(#7726)](https://github.com/microsoft/vcpkg/pull/7726) Revert "[irrlicht] use unicode path on windows (#7354)"

- cgltf `2019-04-30` -> `1.3`
    - [(#7731)](https://github.com/microsoft/vcpkg/pull/7731) [cgltf] Update library to 1.2
    - [(#7774)](https://github.com/microsoft/vcpkg/pull/7774) [cgltf] Update library to 1.3

- duktape `2.3.0-2` -> `2.4.0-3`
    - [(#7548)](https://github.com/microsoft/vcpkg/pull/7548) [ duktape] Update hash for pip.
    - [(#7873)](https://github.com/microsoft/vcpkg/pull/7873) [duktape] Update library to 2.4.0

- double-conversion `3.1.4` -> `3.1.5`
    - [(#7717)](https://github.com/microsoft/vcpkg/pull/7717) [double-conversion] Update library to 3.1.5

- libmorton `2018-19-07` -> `0.2`
    - [(#7738)](https://github.com/microsoft/vcpkg/pull/7738) [libmorton] Update library to 0.2

- clp `1.17.2-2` -> `1.17.3`
    - [(#7756)](https://github.com/microsoft/vcpkg/pull/7756) [clp] Update library to 1.17.3

- libfabric `1.7.1-1` -> `1.8.0`
    - [(#7755)](https://github.com/microsoft/vcpkg/pull/7755) [libfabric] Update library to 1.8.0

- leaf `0.2.1-2` -> `0.2.2`
    - [(#7782)](https://github.com/microsoft/vcpkg/pull/7782) [leaf] Update library to 0.2.2

- inih `44` -> `45`
    - [(#7780)](https://github.com/microsoft/vcpkg/pull/7780) [inih] Update library to 45

- clara `2019-03-29` -> `1.1.5`
    - [(#7775)](https://github.com/microsoft/vcpkg/pull/7775) [clara] Update library to 1.1.5

- distorm `2018-08-26-16e6f435-1` -> `3.4.1`
    - [(#7777)](https://github.com/microsoft/vcpkg/pull/7777) [distorm] Update library to 3.4.1

- libcopp `1.1.0-2` -> `1.2.0`
    - [(#7770)](https://github.com/microsoft/vcpkg/pull/7770) [libcopp] Update library to 1.2.0

- argparse `2019-06-10` -> `1.9`
    - [(#7753)](https://github.com/microsoft/vcpkg/pull/7753) [argparse] Update library to 1.9

- argagg `2019-01-25` -> `0.4.6`
    - [(#7752)](https://github.com/microsoft/vcpkg/pull/7752) [argagg] Update library to 0.4.6

- eastl `3.14.00` -> `3.14.01`
    - [(#7786)](https://github.com/microsoft/vcpkg/pull/7786) [eastl] Update library to 3.14.01

- fribidi `58c6cb3` -> `2019-02-04-1`
    - [(#7768)](https://github.com/microsoft/vcpkg/pull/7768) [fribidi] Fix static library suffix in windows-static

- luajit `2.0.5-1` -> `2.0.5-2`
    - [(#7764)](https://github.com/microsoft/vcpkg/pull/7764) [luajit] Separate debug/release build path and fix generate pdbs.

- ixwebsocket `4.0.3` -> `5.0.4`
    - [(#7789)](https://github.com/microsoft/vcpkg/pull/7789) [ixwebsocket] update to 5.0.4

- azure-c-shared-utility `2019-05-16.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- azure-iot-sdk-c `2019-07-01.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- azure-macro-utils-c `2019-05-16.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- azure-uamqp-c `2019-05-16.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- azure-uhttp-c `2019-05-16.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- azure-umqtt-c `2019-05-16.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- umock-c `2019-05-16.1` -> `2019-08-20.1`
    - [(#7791)](https://github.com/microsoft/vcpkg/pull/7791) [azure-iot] vcpkg update for master/public-preview release

- embree3 `3.5.2` -> `3.5.2-1`
    - [(#7767)](https://github.com/microsoft/vcpkg/pull/7767) [embree3] Fix install path

- re2 `2019-05-07-2` -> `2019-08-01`
    - [(#7808)](https://github.com/microsoft/vcpkg/pull/7808) [re2] Update library to 2019-08-01

- reproc `6.0.0-2` -> `8.0.1`
    - [(#7807)](https://github.com/microsoft/vcpkg/pull/7807) [reproc] Update library to 8.0.1

- safeint `3.20.0` -> `3.21`
    - [(#7806)](https://github.com/microsoft/vcpkg/pull/7806) [safeint] Update library to 3.21

- snowhouse `3.1.0` -> `3.1.1`
    - [(#7805)](https://github.com/microsoft/vcpkg/pull/7805) [snowhouse] Update library to 3.1.1

- spectra `0.8.0` -> `0.8.1`
    - [(#7803)](https://github.com/microsoft/vcpkg/pull/7803) [spectra] Update library to 0.8.1

- spirv-cross `2019-05-09` -> `2019-07-26`
    - [(#7802)](https://github.com/microsoft/vcpkg/pull/7802) [spirv-cross] Update library to 2019-07-26

- libmodbus `3.1.4-3` -> `3.1.6`
    - [(#7834)](https://github.com/microsoft/vcpkg/pull/7834) [libmodbus] Update library to 3.1.6

- basisu `0.0.1-1` -> `1.11-1`
    - [(#7836)](https://github.com/microsoft/vcpkg/pull/7836) [basisu] fix vcpkg version, merge upstream fixes

- range-v3 `0.5.0` -> `0.9.0-20190822`
    - [(#7845)](https://github.com/microsoft/vcpkg/pull/7845) Update range-v3 reference

- cryptopp `8.1.0-2` -> `8.2.0`
    - [(#7854)](https://github.com/microsoft/vcpkg/pull/7854) [cryptopp] Update library to 8.2.0

- lz4 `1.9.1-2` -> `1.9.2`
    - [(#7860)](https://github.com/microsoft/vcpkg/pull/7860) [lz4] Update library to 1.9.2

- wxwidgets `3.1.2-1` -> `3.1.2-2`
    - [(#7833)](https://github.com/microsoft/vcpkg/pull/7833) [wxwidgets] Windows ARM support

- args `2019-05-01` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- asmjit `2019-03-29` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- aws-c-common `0.3.11-1` -> `0.4.1`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- aws-sdk-cpp `1.7.116` -> `1.7.142`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- bitsery `4.6.0` -> `5.0.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- botan `2.9.0-2` -> `2.11.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- breakpad `2019-05-08` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- chipmunk `7.0.2` -> `7.0.3`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- console-bridge `0.3.2-4` -> `0.4.3-1`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- coroutine `1.4.1-1` -> `1.4.3`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- crc32c `1.0.7-1` -> `1.1.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- exprtk `2019-03-29` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- fastcdr `1.0.9-1` -> `1.0.10`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09
    - [(#7862)](https://github.com/microsoft/vcpkg/pull/7862) [fastcdr] Update library 1.0.10

- fizz `2019.05.20.00-1` -> `2019.07.08.00`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- folly `2019.05.20.00-1` -> `2019.06.17.00`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- glad `0.1.30` -> `0.1.31`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- gmmlib `19.1.2` -> `19.2.3`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- graphite2 `1.3.12-1` -> `1.3.13`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- grpc `1.21.1-1` -> `1.22.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- io2d `0.1-2` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- libarchive `3.3.3-3` -> `3.4.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- libpqxx `6.4.4` -> `6.4.5`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- libssh2 `1.8.2` -> `1.9.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- libuv `1.29.1` -> `1.30.1`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- luabridge `2.3.1` -> `2.3.2`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- matio `1.5.15` -> `1.5.16`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- mosquitto `1.6.2-2` -> `1.6.3`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- ms-gsl `2019-04-19` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- nmslib `1.7.3.6-1` -> `1.8.1`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- nuklear `2019-03-29` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- openvr `1.4.18` -> `1.5.17`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- orc `1.5.5-1` -> `1.5.6`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09
    - [(#7908)](https://github.com/microsoft/vcpkg/pull/7908) Add homepage for orc

- parson `2019-04-19` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- piex `2018-03-13-1` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- ptex `2.1.28-1` -> `2.3.2`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- pybind11 `2.2.4` -> `2.3.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- rs-core-lib `2019-05-07` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- shogun `6.1.3-3` -> `6.1.4`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- stb `2019-05-07` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- taocpp-json `2019-05-08` -> `2019-07-11`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- tbb `2019_U7-1` -> `2019_U8`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- telnetpp `1.2.4-1` -> `2.0`
    - [(#7217)](https://github.com/microsoft/vcpkg/pull/7217) [many ports] Updates 2019.07.09

- blaze `3.5` -> `3.6`
    - [(#7878)](https://github.com/microsoft/vcpkg/pull/7878) [blaze] Update to Blaze 3.6

- glfw3 `3.3-1` -> `3.3-2`
    - [(#7885)](https://github.com/microsoft/vcpkg/pull/7885) [glfw3] Add more information about installing dependencies.

- fmt `5.3.0-2` -> `6.0.0`
    - [(#7910)](https://github.com/microsoft/vcpkg/pull/7910) [fmt] Update to 6.0.0
    - [(#7884)](https://github.com/microsoft/vcpkg/pull/7884) [fmt] missing VCPKG_BUILD_TYPE support added

- magic-enum `2019-06-07` -> `0.6.0`
    - [(#7916)](https://github.com/microsoft/vcpkg/pull/7916) [magic-enum] Update to v0.6.0

- liblsl `1.13.0-b6` -> `1.13.0-b11-1`
    - [(#7906)](https://github.com/microsoft/vcpkg/pull/7906) [liblsl] Update library to 1.13.0-b11
    - [(#7945)](https://github.com/microsoft/vcpkg/pull/7945) [liblsl] Fix installation

- yaml-cpp `0.6.2-2` -> `0.6.2-3`
    - [(#7847)](https://github.com/microsoft/vcpkg/pull/7847) [yaml-cpp] Fix include path in yaml-cpp-config.cmake

- fluidsynth `2.0.5` -> `2.0.5-1`
    - [(#7837)](https://github.com/microsoft/vcpkg/pull/7837) [fluidsynth] add Windows ARM support

- nmap `7.70` -> `7.70-1`
    - [(#7811)](https://github.com/microsoft/vcpkg/pull/7811) [nmap] Fix build error.

- moos-ui `10.0.1-1` -> `10.0.1-2`
    - [(#7812)](https://github.com/microsoft/vcpkg/pull/7812) [moos-ui] Fix install path

- openni2 `2.2.0.33-9` -> `2.2.0.33-10`
    - [(#7809)](https://github.com/microsoft/vcpkg/pull/7809) [openni2] Add warning message when cannot find NETFXSDK.

- abseil `2019-05-08` -> `2019-05-08-1`
    - [(#7745)](https://github.com/microsoft/vcpkg/pull/7745) [abseil] fix cmake config issue

- libwebp `1.0.2-6` -> `1.0.2-7`
    - [(#7886)](https://github.com/microsoft/vcpkg/pull/7886) [libwebp] Fix two dependent windows library link conditions.

- wpilib `2019.5.1` -> `2019.6.1`
    - [(#7927)](https://github.com/microsoft/vcpkg/pull/7927) [wpilib] Update wpilib port to allow opencv4

- ogdf `2018-03-28-2` -> `2019-08-23`
    - [(#7846)](https://github.com/microsoft/vcpkg/pull/7846) [ogdf] Update source link

- libp7client `5.2` -> `5.2-1`
    - [(#7977)](https://github.com/microsoft/vcpkg/pull/7977) [libp7client] Rename port folder to lowercase

- libpng `1.6.37-2` -> `1.6.37-3`
    - [(#7972)](https://github.com/microsoft/vcpkg/pull/7972) [libpng] Fix find_package() in CONFIG mode (#7968)

- openblas `0.3.6-5` -> `0.3.6-6`
    - [(#7888)](https://github.com/microsoft/vcpkg/pull/7888) [openblas] Enable x86 build and fix usage errors.

- qt5-base `5.12.3-3` -> `5.12.3-4`
    - [(#7973)](https://github.com/microsoft/vcpkg/pull/7973) [Qt5] Fix libpq linkage in wrapper

- liblas `1.8.1` -> `1.8.1-2`
    - [(#7975)](https://github.com/microsoft/vcpkg/pull/7975) [liblas] Fix Geotiff linkage

- glib `2.52.3-14-2` -> `2.52.3-14-3`
    - [(#7963)](https://github.com/microsoft/vcpkg/pull/7963) [glib] Fix install config.h

</details>

-- vcpkg team vcpkg@microsoft.com THU, 04 Sept 14:00:00 -0800

vcpkg (2019.7.31)
---
#### Total port count: 1105
#### Total port count per triplet (tested): 
|triplet|ports available|
|---|---|
|**x64-windows**|1039|
|x86-windows|1009|
|x64-windows-static|928|
|**x64-linux**|866|
|**x64-osx**|788|
|arm64-windows|678|
|x64-uwp|546|
|arm-uwp|522|

#### The following commands and options have been updated:
- --scripts-root ***[NEW OPTION]***
    - Specify a directory to use in place of `<vcpkg root>/scripts`. Enables a shared script directory for those using a single vcpkg instance to manage distributed port directories
        - [(#6552)](https://github.com/microsoft/vcpkg/pull/6552) Allow redirection of the scripts folder.
- depend-info
    - Allow `vcpkg depend-info port[feature]` to display port-dependency information for a given port and the specified feature.
        - [(#6797)](https://github.com/microsoft/vcpkg/pull/6797) Make `depend-info` subcommand able to handle features

#### The following documentation has been updated:
- [Overlay triplets example: build dynamic libraries on Linux](docs/examples/overlay-triplets-linux-dynamic.md) ***[NEW]***
    - [(#7291)](https://github.com/microsoft/vcpkg/pull/7291) Example: Building dynamic libraries on Linux using overlay triplets
- [vcpkg_from_git](docs/maintainers/vcpkg_from_git.md)
    - [(#7082)](https://github.com/microsoft/vcpkg/pull/7082) Fix vcpkg_from_git
- [Maintainer Guidelines and Policies](docs/maintainers/maintainer-guide.md)
    - [(#7390)](https://github.com/microsoft/vcpkg/pull/7390) [docs] add notes about manual-link

#### The following *remarkable* changes have been made to vcpkg's infrastructure:
- `VCPKG_ENV_PASSTHROUGH` triplet variable and `environment-overrides.cmake`
    -  Port authors can add an `environment-overrides.cmake` file to a port to override triplet settings globally or to define behavior of the vpckg binary on a per port basis
        - [(#7290)](https://github.com/microsoft/vcpkg/pull/7290) [vcpkg] Environment Variable Passthrough
        - [(#7292)](https://github.com/microsoft/vcpkg/pull/7292) [vcpkg] Portfile Settings
- Testing overhaul
    - Tests have been migrated from the Visual Studio unit testing framework to the cross-platform [Catch2](https://github.com/catchorg/Catch2)
        - [(#7315)](https://github.com/microsoft/vcpkg/pull/7315) Rewrite the tests! now they're cross-platform!

#### The following *additional* changes have been made to vcpkg's infrastructure:
- [(#7080)](https://github.com/microsoft/vcpkg/pull/7080) [vcpkg] Use spaces instead of semicolons in the output
- [(#6791)](https://github.com/microsoft/vcpkg/pull/6791) Update python2, python3, perl, aria2, ninja, ruby, 7z
- [(#7082)](https://github.com/microsoft/vcpkg/pull/7082) Fix vcpkg_from_git
- [(#7117)](https://github.com/microsoft/vcpkg/pull/7117) Revert Visual Studio projects versions
- [(#7051)](https://github.com/microsoft/vcpkg/pull/7051) Fix Python3 tool on Windows
- [(#7135)](https://github.com/microsoft/vcpkg/pull/7135) revert ninja update
- [(#7136)](https://github.com/microsoft/vcpkg/pull/7136) Bump version to warn of outdated vcpkg sources
- [(#7094)](https://github.com/microsoft/vcpkg/pull/7094) [vcpkg] Fix powershell font corruption bug
- [(#7158)](https://github.com/microsoft/vcpkg/pull/7158) [vcpkg] Fix incorrect setting of FEATURE_OPTIONS
- [(#6792)](https://github.com/microsoft/vcpkg/pull/6792) Cleanup vcpkg_configure_cmake.cmake
- [(#7175)](https://github.com/microsoft/vcpkg/pull/7175) Added nasm mirror as nasm.us is down again
- [(#7216)](https://github.com/microsoft/vcpkg/pull/7216) [vcpkg] allow spaces in pathname on linux
- [(#7243)](https://github.com/microsoft/vcpkg/pull/7243) Testing for --overlay-ports and --overlay-triplets args
- [(#7294)](https://github.com/microsoft/vcpkg/pull/7294) Add June changelog
- [(#7229)](https://github.com/microsoft/vcpkg/pull/7229) Better error message when VCPKG_ROOT is independently defined
- [(#7336)](https://github.com/microsoft/vcpkg/pull/7336) Create issue templates
- [(#7322)](https://github.com/microsoft/vcpkg/pull/7322) Resolves "project is never up-to-date" problem (issue 6179)
- [(#7228)](https://github.com/microsoft/vcpkg/pull/7228) Parallel file operations
- [(#7403)](https://github.com/microsoft/vcpkg/pull/7403) Add third party notices -- copied from chakracore
- [(#7407)](https://github.com/microsoft/vcpkg/pull/7407) Modify CMakeLists to split up vcpkglib
- [(#7430)](https://github.com/microsoft/vcpkg/pull/7430) [vcpkg] Fix RealFilesystem::remove_all

<details>
<summary><b>The following 37 ports have been added:</b></summary>

|port|version|
|---|---|
|[septag-sx](https://github.com/microsoft/vcpkg/pull/6327)| 2019-05-07-1
|[librdkafka](https://github.com/microsoft/vcpkg/pull/5921)| 1.1.0
|[soxr](https://github.com/microsoft/vcpkg/pull/6478)| 0.1.3.
|[czmq](https://github.com/microsoft/vcpkg/pull/4979)<sup>[#7186](https://github.com/microsoft/vcpkg/pull/7186) </sup>| 2019-06-10-1
|[cppmicroservices](https://github.com/microsoft/vcpkg/pull/6388)| 4.0.0-pre1
|[zookeeper](https://github.com/microsoft/vcpkg/pull/7000)| 3.5.5
|[xmlsec](https://github.com/microsoft/vcpkg/pull/7196)| 1.2.28
|[librsvg](https://github.com/microsoft/vcpkg/pull/6807)| 2.40.20
|[7zip](https://github.com/microsoft/vcpkg/pull/6920)| 19.00
|[genann](https://github.com/microsoft/vcpkg/pull/7195)| 2019-07-10
|[offscale-libetcd-cpp](https://github.com/microsoft/vcpkg/pull/6999)| 2019-07-10
|[rabit](https://github.com/microsoft/vcpkg/pull/7234)| 0.1
|[zyre](https://github.com/microsoft/vcpkg/pull/7189)| 2019-07-07
|[cpp-peglib](https://github.com/microsoft/vcpkg/pull/7254)| 0.1.0
|[paho-mqttpp3](https://github.com/microsoft/vcpkg/pull/7033)| 1.0.1
|[openxr-loader](https://github.com/microsoft/vcpkg/pull/6339)<sup>[#7376](https://github.com/microsoft/vcpkg/pull/7376) [#7488](https://github.com/microsoft/vcpkg/pull/7488) </sup>| 1.0.0-1
|[wintoast](https://github.com/microsoft/vcpkg/pull/7006)| 1.2.0
|[scnlib](https://github.com/microsoft/vcpkg/pull/7014)| 0.1.2
|[mongoose](https://github.com/microsoft/vcpkg/pull/7089)| 6.15-1
|[nameof](https://github.com/microsoft/vcpkg/pull/7250)| 2019-07-13
|[leaf](https://github.com/microsoft/vcpkg/pull/7319)<sup>[#7468](https://github.com/microsoft/vcpkg/pull/7468) </sup>| 0.2.1-2
|[otl](https://github.com/microsoft/vcpkg/pull/7272)| 4.0.442
|[dbg-macro](https://github.com/microsoft/vcpkg/pull/7237)| 2019-07-11
|[p-ranav-csv](https://github.com/microsoft/vcpkg/pull/7236)| 2019-07-11
|[lastools](https://github.com/microsoft/vcpkg/pull/7220)| 2019-07-10
|[basisu](https://github.com/microsoft/vcpkg/pull/6995)<sup>[#7468](https://github.com/microsoft/vcpkg/pull/7468) </sup>| 0.0.1-1
|[cmcstl2](https://github.com/microsoft/vcpkg/pull/7348)| 2019-07-20
|[libconfuse](https://github.com/microsoft/vcpkg/pull/7252)| 2019-07-14
|[boolinq](https://github.com/microsoft/vcpkg/pull/7362)| 2019-07-22
|[libzippp](https://github.com/microsoft/vcpkg/pull/6801)| 2019-07-22
|[mimalloc](https://github.com/microsoft/vcpkg/pull/7011)| 2019-06-25
|[liblas](https://github.com/microsoft/vcpkg/pull/6746)| 1.8.1
|[xtensor-io](https://github.com/microsoft/vcpkg/pull/7398)| 0.7.0
|[easycl](https://github.com/microsoft/vcpkg/pull/7387)| 0.3
|[nngpp](https://github.com/microsoft/vcpkg/pull/7417)| 2019-07-25
|[mpi](https://github.com/microsoft/vcpkg/pull/7142)| 1
|[openmpi](https://github.com/microsoft/vcpkg/pull/7142)| 4.0.1
</details>

<details>
<summary><b>The following 160 ports have been updated:</b></summary>

- openssl-unix `1.0.2q` -> `1.0.2s-1`
    - [(#6854)](https://github.com/microsoft/vcpkg/pull/6854) Openssl version bump 1.0.2s
    - [(#6512)](https://github.com/microsoft/vcpkg/pull/6512) [openssl-unix] Shared library support

- openssl-windows `1.0.2q-2` -> `1.0.2s-1`
    - [(#6854)](https://github.com/microsoft/vcpkg/pull/6854) Openssl version bump 1.0.2s

- mongo-cxx-driver `3.4.0-2` -> `3.4.0-3`
    - [(#7050)](https://github.com/microsoft/vcpkg/pull/7050) [mongo-cxx-driver] Do not delete the third_party include folder when building with mnmlstc

- fdlibm `5.3-3` -> `5.3-4`
    - [(#7082)](https://github.com/microsoft/vcpkg/pull/7082) Fix vcpkg_from_git

- azure-iot-sdk-c `2019-05-16.1` -> `2019-07-01.1`
    - [(#7123)](https://github.com/microsoft/vcpkg/pull/7123) [azure] Update azure-iot-sdk-c for public-preview release of 2019-07-01

- open62541 `0.3.0-1` -> `0.3.0-2`
    - [(#7051)](https://github.com/microsoft/vcpkg/pull/7051) Fix Python3 tool on Windows

- lua `5.3.5-1` -> `5.3.5-2`
    - [(#7101)](https://github.com/microsoft/vcpkg/pull/7101) [lua] Add [cpp] feature to additionally build lua-c++

- flann `1.9.1-1` -> `2019-04-07-1`
    - [(#7125)](https://github.com/microsoft/vcpkg/pull/7125) [flann]Change the version tag to the corresponding time of commit id.

- tbb `2019_U7` -> `2019_U7-1`
    - [(#6510)](https://github.com/microsoft/vcpkg/pull/6510) [tbb] Add shared library support for Linux and OSX

- dcmtk `3.6.4` -> `3.6.4-1`
    - [(#7059)](https://github.com/microsoft/vcpkg/pull/7059) [dcmtk] support wchar_t* filename

- libmupdf `1.15.0` -> `1.15.0-1`
    - [(#7107)](https://github.com/microsoft/vcpkg/pull/7107) [libmupdf] Enable the old patch for fixing C2169

- mongo-c-driver `1.14.0-2` -> `1.14.0-3`
    - [(#7048)](https://github.com/microsoft/vcpkg/pull/7048) [mongo-c-driver] Add usage
    - [(#7338)](https://github.com/microsoft/vcpkg/pull/7338) [mongo-c-driver] Disable snappy auto-detection

- openimageio `1.8.16` -> `2.0.8`
    - [(#7173)](https://github.com/microsoft/vcpkg/pull/7173) [openimageio] Upgrade to version 2.0.8

- duktape `2.3.0` -> `2.3.0-2`
    - [(#7170)](https://github.com/microsoft/vcpkg/pull/7170) [duktape] Fix package not found by find_package.
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- poco `2.0.0-pre-2` -> `2.0.0-pre-3`
    - [(#7169)](https://github.com/microsoft/vcpkg/pull/7169) [Poco] Add missing ipjlpapi.lib to foundation library

- gsoap `2.8.84-1` -> `2.8.87-1`
    - [(#7145)](https://github.com/microsoft/vcpkg/pull/7145) [gsoap] Update to 2.8.87

- qt5-mqtt `5.12.3` -> `5.12.3-1`
    - [(#7130)](https://github.com/microsoft/vcpkg/pull/7130) [qt5-mqtt] crossplatform add to path
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- botan `2.9.0-1` -> `2.9.0-2`
    - [(#7140)](https://github.com/microsoft/vcpkg/pull/7140) [botan] Fix build error C2039 with Visual Studio 2019 and C++17
    - [(#7303)](https://github.com/microsoft/vcpkg/pull/7303) [botan] Fix parallel build

- kinectsdk2 `2.0` -> `2.0-1`
    - [(#7143)](https://github.com/microsoft/vcpkg/pull/7143) kinectsdk2: fix missing header files

- civetweb `1.11-1` -> `2019-07-05`
    - [(#7166)](https://github.com/microsoft/vcpkg/pull/7166) [civetweb] Upgrade and enable feature websocket

- curl `7.65.0-2` -> `7.65.2-1`
    - [(#7156)](https://github.com/microsoft/vcpkg/pull/7156) [curl] Add features.
    - [(#7093)](https://github.com/microsoft/vcpkg/pull/7093) [curl] Update to 7.65.2

- aws-checksums `0.1.2` -> `0.1.3`
    - [(#7154)](https://github.com/microsoft/vcpkg/pull/7154) [aws-checksums]Upgrade version to 0.1.3

- rapidjson `1.1.0-3` -> `d87b698-1`
    - [(#7152)](https://github.com/microsoft/vcpkg/pull/7152) [rapidjson] Update to the latest commit and also fix #3401.
    - [(#7273)](https://github.com/microsoft/vcpkg/pull/7273) [rapidjson] Fix path RapidJSON_INCLUDE_DIRS

- freetype `2.10.0` -> `2.10.1-1`
    - [(#7141)](https://github.com/microsoft/vcpkg/pull/7141) [freetype]Re-fixed the issue of exporting symbols when building dynamic library.
    - [(#7341)](https://github.com/microsoft/vcpkg/pull/7341) [freetype] Update to 2.10.1

- llvm `7.0.0-3` -> `8.0.0`
    - [(#7209)](https://github.com/microsoft/vcpkg/pull/7209) [llvm] Update to 8.0.0

- reproc `6.0.0-1` -> `6.0.0-2`
    - [(#7208)](https://github.com/microsoft/vcpkg/pull/7208) [reproc] Fix reproc++ installation path

- wil `2019-06-10` -> `2019-07-16`
    - [(#7215)](https://github.com/microsoft/vcpkg/pull/7215) [wil] Update
    - [(#7285)](https://github.com/microsoft/vcpkg/pull/7285)  Update wil port to match the commit used for NuGet package 1.0.190716.2

- tesseract `4.0.0-3` -> `4.1.0-1`
    - [(#7144)](https://github.com/microsoft/vcpkg/pull/7144) [tesseract] Fix Port. Making it crossplatform
    - [(#7227)](https://github.com/microsoft/vcpkg/pull/7227) [tesseract] port update to 4.1.0 release
    - [(#7360)](https://github.com/microsoft/vcpkg/pull/7360) [tesseract[training_tools]] Fix build error

- zeromq `2019-05-07` -> `2019-07-09`
    - [(#7203)](https://github.com/microsoft/vcpkg/pull/7203) [zeromq] Update to 4.3.2

- spirv-tools `2019.3-dev` -> `2019.3-dev-1`
    - [(#7204)](https://github.com/microsoft/vcpkg/pull/7204) [spirv-tools] Fix removed patch

- libraqm `0.6.0` -> `0.7.0`
    - [(#7149)](https://github.com/microsoft/vcpkg/pull/7149) [libraqm] Update libraqm to 0.7.0
    - [(#7263)](https://github.com/microsoft/vcpkg/pull/7263) [libraqm] Fix copying raqm-version.h to include directory

- pthreads `3.0.0-1` -> `3.0.0-2`
    - [(#7178)](https://github.com/microsoft/vcpkg/pull/7178) [pthreads4W] vcpkg wrapper fixes

- libkml `1.3.0-2` -> `1.3.0-3`
    - [(#7194)](https://github.com/microsoft/vcpkg/pull/7194) [libkml] Fix install path
    - [(#7282)](https://github.com/microsoft/vcpkg/pull/7282) [minizip] Make BZip2 an optional feature

- gherkin-c `4.1.2` -> `2019-10-07-1`
    - [(#7231)](https://github.com/microsoft/vcpkg/pull/7231) [gherkin-b] update to latest
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- google-cloud-cpp `0.10.0` -> `0.11.0`
    - [(#7134)](https://github.com/microsoft/vcpkg/pull/7134) Upgrade google-cloud-cpp to v0.11.0.

- sqlite3 `3.28.0-1` -> `3.29.0-1`
    - [(#7202)](https://github.com/microsoft/vcpkg/pull/7202) [sqlite3-tool]Fix build error on arm/uwp platform.
    - [(#7342)](https://github.com/microsoft/vcpkg/pull/7342) [sqlite3] Update to 3.29.0

- nonius `2019-04-20` -> `2019-04-20-1`
    - [(#7258)](https://github.com/microsoft/vcpkg/pull/7258) [nonius] properly install noniusConfig.cmake

- leveldb `1.22` -> `1.22-1`
    - [(#7245)](https://github.com/microsoft/vcpkg/pull/7245) [leveldb] Fix cmake config

- bond `8.1.0` -> `8.1.0-2`
    - [(#7273)](https://github.com/microsoft/vcpkg/pull/7273) [rapidjson] Fix path RapidJSON_INCLUDE_DIRS
    - [(#7306)](https://github.com/microsoft/vcpkg/pull/7306) [bond] make haskell an external dependency
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

- cpprestsdk `2.10.13-1` -> `2.10.14`
    - [(#7286)](https://github.com/microsoft/vcpkg/pull/7286) Update cpprestsdk to v2.10.14.

- qt5-base `5.12.3-1` -> `5.12.3-3`
    - [(#6983)](https://github.com/microsoft/vcpkg/pull/6983) [qt5-base]Add a print message to inform the user to install the dependency package.
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-3d `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-activeqt `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-charts `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-connectivity `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-datavis3d `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-declarative `5.12.3-1` -> `5.12.3-2`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-gamepad `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-graphicaleffects `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-imageformats `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-location `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-macextras `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-modularscripts `2019-04-30` -> `2019-04-30-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-multimedia `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-networkauth `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-purchasing `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-quickcontrols `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-quickcontrols2 `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-remoteobjects `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-script `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-scxml `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-sensors `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-serialport `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-speech `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-svg `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-tools `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-virtualkeyboard `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-webchannel `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-websockets `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-webview `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- qt5-winextras `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux
    - [(#7298)](https://github.com/microsoft/vcpkg/pull/7298) [qt5-winextras, ecsutil, soundtouch] Fix build-depends

- qt5-xmlpatterns `5.12.3` -> `5.12.3-1`
    - [(#7230)](https://github.com/microsoft/vcpkg/pull/7230) [qt5]Fix build failure in linux

- rocksdb `6.0.2` -> `6.1.2`
    - [(#7304)](https://github.com/microsoft/vcpkg/pull/7304) [rocksdb] Update rocksdb to 6.1.2, adds optional zstd feature

- metis `5.1.0-3` -> `5.1.0-5`
    - [(#7299)](https://github.com/microsoft/vcpkg/pull/7299) [metis] Fix linux build error.
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- ecsutil `1.0.6.1` -> `1.0.7.2`
    - [(#7298)](https://github.com/microsoft/vcpkg/pull/7298) [qt5-winextras, ecsutil, soundtouch] Fix build-depends
    - [(#7427)](https://github.com/microsoft/vcpkg/pull/7427) [ECSUtil] update library to v1.0.7.2

- soundtouch `2.0.0-2` -> `2.0.0-3`
    - [(#7298)](https://github.com/microsoft/vcpkg/pull/7298) [qt5-winextras, ecsutil, soundtouch] Fix build-depends

- libsodium `1.0.18` -> `1.0.18-1`
    - [(#7297)](https://github.com/microsoft/vcpkg/pull/7297) [libsodium] Fix Linux build error.

- irrlicht `1.8.4` -> `1.8.4-2`
    - [(#7296)](https://github.com/microsoft/vcpkg/pull/7296) [irrlicht] add vcpkg-cmake-wrapper
    - [(#7354)](https://github.com/microsoft/vcpkg/pull/7354) [irrlicht] use unicode path on windows

- libyaml `0.2.2` -> `0.2.2-1`
    - [(#7277)](https://github.com/microsoft/vcpkg/pull/7277) [libyaml] Fix build error

- eastl `3.13.05-1` -> `3.14.00`
    - [(#7276)](https://github.com/microsoft/vcpkg/pull/7276) [eastl] Upgrade to 3.14

- boost-asio `1.70.0-1` -> `1.70.0-2`
    - [(#7267)](https://github.com/microsoft/vcpkg/pull/7267) Fixed boost-asio on Windows

- minizip `1.2.11-4` -> `1.2.11-5`
    - [(#7282)](https://github.com/microsoft/vcpkg/pull/7282) [minizip] Make BZip2 an optional feature

- blend2d `beta_2019-04-30` -> `beta_2019-07-16`
    - [(#7239)](https://github.com/microsoft/vcpkg/pull/7239) [blend2d] Port update

- so5extra `1.2.3-1` -> `1.3.1`
    - [(#7238)](https://github.com/microsoft/vcpkg/pull/7238) [sobjectizer, so5extra] updates

- sobjectizer `5.5.24.4-1` -> `5.6.0.2`
    - [(#7238)](https://github.com/microsoft/vcpkg/pull/7238) [sobjectizer, so5extra] updates

- directxtk `apr2019` -> `apr2019-1`
    - [(#7233)](https://github.com/microsoft/vcpkg/pull/7233) [DirectXTK] Fix UWP build error

- restbed `4.16-07-28-2018` -> `4.16-07-28-2018-1`
    - [(#7232)](https://github.com/microsoft/vcpkg/pull/7232) [restbed] Add openssl feature

- clapack `3.2.1-9` -> `3.2.1-10`
    - [(#6786)](https://github.com/microsoft/vcpkg/pull/6786) [openblas/clapack] FindLapack/FindBLAS was not working.

- geogram `1.6.9-6` -> `1.6.9-7`
    - [(#6786)](https://github.com/microsoft/vcpkg/pull/6786) [openblas/clapack] FindLapack/FindBLAS was not working.

- mlpack `3.1.1` -> `3.1.1-1`
    - [(#6786)](https://github.com/microsoft/vcpkg/pull/6786) [openblas/clapack] FindLapack/FindBLAS was not working.

- openblas `0.3.6-4` -> `0.3.6-5`
    - [(#6786)](https://github.com/microsoft/vcpkg/pull/6786) [openblas/clapack] FindLapack/FindBLAS was not working.

- pprint `2019-06-01` -> `2019-07-19`
    - [(#7317)](https://github.com/microsoft/vcpkg/pull/7317) [pprint] Fix #7301

- boost-type-erasure `1.70.0` -> `1.70.0-1`
    - [(#7325)](https://github.com/microsoft/vcpkg/pull/7325) [boost-type-erasure] fix depends on arm

- armadillo `2019-04-16-3` -> `2019-04-16-4`
    - [(#7041)](https://github.com/microsoft/vcpkg/pull/7041)  [armadillo] Fix installation path

- cutelyst2 `2.7.0` -> `2.8.0`
    - [(#7327)](https://github.com/microsoft/vcpkg/pull/7327) [cutelyst2]Upgrade version to 2.8.0

- sdl2-image `2.0.4-3` -> `2.0.5`
    - [(#7355)](https://github.com/microsoft/vcpkg/pull/7355) [sdl2-image] Updated to 2.0.5

- qhull `7.2.1-3` -> `7.3.2`
    - [(#7340)](https://github.com/microsoft/vcpkg/pull/7340) [qhull] Update to 7.3.2 and fix postbuild validation

- libexif `0.6.21-1` -> `0.6.21-2`
    - [(#7344)](https://github.com/microsoft/vcpkg/pull/7344) [Libexif] update download location

- arrow `0.13.0-4` -> `0.14.1`
    - [(#7211)](https://github.com/microsoft/vcpkg/pull/7211) [Arrow] Update to Arrow v0.14.1

- date `ed0368f` -> `2019-05-18-1`
    - [(#7399)](https://github.com/microsoft/vcpkg/pull/7399) [date] Fix issue with feature remote-api

- libmariadb `3.0.10-1` -> `3.0.10-3`
    - [(#7396)](https://github.com/microsoft/vcpkg/pull/7396) [libmariadb] Fix build library type and install path
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- inja `2.1.0` -> `2.1.0-1`
    - [(#7402)](https://github.com/microsoft/vcpkg/pull/7402) [inja] Use inja CMakeLists.txt

- pcl `1.9.1-4` -> `1.9.1-5`
    - [(#7388)](https://github.com/microsoft/vcpkg/pull/7388) [pcl] Fix cuda building compatability issues with cuda 10.1

- thrift `2019-05-07-2` -> `2019-05-07-3`
    - [(#7302)](https://github.com/microsoft/vcpkg/pull/7302) [Thrift] Make Thrift static again

- forest `12.0.0` -> `12.0.3`
    - [(#7410)](https://github.com/microsoft/vcpkg/pull/7410) [forest] Update to Version 12.0.3

- nlohmann-json `3.6.1` -> `3.7.0`
    - [(#7459)](https://github.com/microsoft/vcpkg/pull/7459) [nlohmann-json] Update to 3.7.0

- ecm `5.58.0` -> `5.60.0-1`
    - [(#7457)](https://github.com/microsoft/vcpkg/pull/7457) [ecm] Update library to v5.60.0
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- gl2ps `1.4.0-1` -> `1.4.0-3`
    - [(#7453)](https://github.com/microsoft/vcpkg/pull/7453) [gl2ps]Update to use vcpkg new functions(vcpkg_from_gitlab).
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- darknet `0.2.5-4` -> `0.2.5-5`
    - [(#7450)](https://github.com/microsoft/vcpkg/pull/7450) [darknet] add training feature

- g3log `2019-05-14-1` -> `2019-07-29`
    - [(#7448)](https://github.com/microsoft/vcpkg/pull/7448) [g3log] Fix https://github.com/KjellKod/g3log/issues/319

- azure-storage-cpp `6.1.0` -> `6.1.0-2`
    - [(#7404)](https://github.com/microsoft/vcpkg/pull/7404) [azure-storage-cpp] Removed gcov dependency in debug Linux build (#7311)
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- ace `6.5.5-1` -> `6.5.6`
    - [(#7466)](https://github.com/microsoft/vcpkg/pull/7466) [ace] ace 6.5.6

- bullet3 `2.88` -> `2.88-1`
    - [(#7474)](https://github.com/microsoft/vcpkg/pull/7474) [Bullet3] feature for multithreading
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- alembic `1.7.11-2` -> `1.7.11-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- ampl-mp `2019-03-21` -> `2019-03-21-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- anax `2.1.0-5` -> `2.1.0-6`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- apr `1.6.5-1` -> `1.6.5-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- blosc `1.16.3-1` -> `1.16.3-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- capnproto `0.7.0-2` -> `0.7.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- cgicc `3.2.19-1` -> `3.2.19-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- charls `2.0.0-1` -> `2.0.0-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- collada-dom `2.5.0-1` -> `2.5.0-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- ctemplate `2017-06-23-44b7c5-3` -> `2017-06-23-44b7c5-4`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- dlfcn-win32 `1.1.1-1` -> `1.1.1-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- easyloggingpp `9.96.7` -> `9.96.7-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- fastfeat `391d5e9` -> `391d5e9-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- fastlz `1.0-2` -> `1.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- freeglut `3.0.0-6` -> `3.0.0-7`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- glbinding `3.1.0-1` -> `3.1.0-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- glew `2.1.0-4` -> `2.1.0-5`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- glfw3 `3.3` -> `3.3-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- graphicsmagick `1.3.32` -> `1.3.32-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- hypre `2.11.2-1` -> `2.11.2-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

- jack2 `1.9.12-1` -> `1.9.12-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- jxrlib `1.1-7` -> `1.1-8`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- kangaru `4.1.3-1` -> `4.1.3-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libconfig `1.7.2` -> `1.7.2-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libfreenect2 `0.2.0-2` -> `0.2.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libmad `0.15.1-2` -> `0.15.1-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libmspack `0.10.1` -> `0.10.1-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libnice `0.1.15` -> `0.1.15-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libodb-boost `2.4.0-2` -> `2.4.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libodb-mysql `2.4.0-2` -> `2.4.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libodb-pgsql `2.4.0-2` -> `2.4.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libodb-sqlite `2.4.0-3` -> `2.4.0-4`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libodb `2.4.0-4` -> `2.4.0-5`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- librabbitmq `0.9.0` -> `0.9.0-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libsamplerate `0.1.9.0` -> `0.1.9.0-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- libwebsockets `3.1.0-2` -> `3.1.0-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- lmdb `0.9.23-1` -> `0.9.23-2`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- mozjpeg `3.2-2` -> `3.2-3`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- nanodbc `2.12.4-3` -> `2.12.4-4`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- nmslib `1.7.3.6` -> `1.7.3.6-1`
    - [(#7468)](https://github.com/microsoft/vcpkg/pull/7468) Add PREFER_NINJA to many ports

- amqpcpp `4.1.4` -> `4.1.5`
    - [(#7475)](https://github.com/microsoft/vcpkg/pull/7475) [amqpcpp] Update library to v4.1.5

- cxxopts `2.1.2-1` -> `2.2.0`
    - [(#7473)](https://github.com/microsoft/vcpkg/pull/7473) [cxxopts] Bumped to v2.2.0

- boost-mpi `1.70.0-1` -> `1.70.0-2`
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

- hdf5 `1.10.5-7` -> `1.10.5-8`
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

- kealib `1.4.11` -> `1.4.11-1`
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

- parmetis `4.0.3-2` -> `4.0.3-3`
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

- vtk `8.2.0-4` -> `8.2.0-5`
    - [(#7142)](https://github.com/microsoft/vcpkg/pull/7142) [OpenMPI] add a new port

</details>

-- vcpkg team vcpkg@microsoft.com THU, 01 Aug 07:00:00 -0800

vcpkg (2019.6.30)
---
#### Total port count: 1068
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|**x64-windows**|1006|
|x86-windows|977|
|x64-windows-static|895|
|**x64-osx**|755|
|**x64-linux**|823|
|arm64-windows|654|
|x64-uwp|532|
|arm-uwp|504|

#### The following commands and options have been updated:
- [--overlay-ports](docs/specifications/ports-overlay.md) ***[NEW OPTION]***
    - Specify directories to be used when searching for ports
        - [(#6981)](https://github.com/Microsoft/vcpkg/pull/6981) Ports Overlay partial implementation
        - [(#7002)](https://github.com/Microsoft/vcpkg/pull/7002) [--overlay-ports] Show location of overriden ports during install plan
- --overlay-triplets ***[NEW OPTION]***
    - Specify directories containing triplets files
        - [(#7053)](https://github.com/Microsoft/vcpkg/pull/7053) Triplets Overlay Implementation
- integrate
    - [(#7095)](https://github.com/Microsoft/vcpkg/pull/7095) [vcpkg-integrate] Improve spelling, help, and autocomplete.

#### The following documentation has been updated:
- [Maintainer Guidelines and Policies](docs/maintainers/maintainer-guide.md) ***[NEW]***
    - [(#6871)](https://github.com/Microsoft/vcpkg/pull/6871) [docs] Add maintainer guidelines
- [Ports Overlay](docs/specifications/ports-overlay.md) ***[NEW]***
    - [(#6981)](https://github.com/Microsoft/vcpkg/pull/6981) Ports Overlay partial implementation
- [vcpkg_check_features](docs/maintainers/vcpkg_check_features.md) ***[NEW]***
    - [(#6958)](https://github.com/Microsoft/vcpkg/pull/6958) [vcpkg] Add vcpkg_check_features
    - [(#7091)](https://github.com/Microsoft/vcpkg/pull/7091) [vcpkg] Update vcpkg_check_features document
- [vcpkg_execute_build_process](docs/maintainers/vcpkg_execute_build_process.md) ***[NEW]***
    - [(#7039)](https://github.com/Microsoft/vcpkg/pull/7039) [docs]Update cmake docs
- [CONTROL files](docs/maintainers/control-files.md#Homepage)
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL
    - [(#6871)](https://github.com/Microsoft/vcpkg/pull/6871) [docs] Add maintainer guidelines
- [index](docs/index.md)
    - [(#6871)](https://github.com/Microsoft/vcpkg/pull/6871) [docs] Add maintainer guidelines
- [Portfile helper functions](docs/maintainers/portfile-functions.md)
    - [(#7039)](https://github.com/Microsoft/vcpkg/pull/7039) [docs]Update cmake docs
- [vcpkg_configure_cmake](docs/maintainers/vcpkg_configure_cmake.md)
    - [(#7074)](https://github.com/Microsoft/vcpkg/pull/7074) [vcpkg_configure_cmake] Add NO_CHARSET_FLAG option

#### The following *remarkable* changes have been made to vcpkg's infrastructure:
- [vcpkg_check_features.cmake](docs/maintainers/vcpkg_check_features.md)
    - New portfile.cmake function for vcpkg contributors; Check if one or more features are a part of the package installation
        - [(#6958)](https://github.com/Microsoft/vcpkg/pull/6958) [vcpkg] Add vcpkg_check_features
        - [(#7091)](https://github.com/Microsoft/vcpkg/pull/7091) [vcpkg] Update vcpkg_check_features document
- [CONTROL file Homepage field](docs/maintainers/control-files.md#Homepage)
    - CONTROL files may now contain a 'Homepage' field which links to the port's official website
        - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

#### The following *additional* changes have been made to vcpkg's infrastructure:
- [(#4942)](https://github.com/Microsoft/vcpkg/pull/4942) Update applocal.ps1
- [(#5630)](https://github.com/Microsoft/vcpkg/pull/5630) [scripts] Fix vcpkg_fixup_cmake on non Windows platforms
- [(#6383)](https://github.com/Microsoft/vcpkg/pull/6383) [vcpkg] update python3 to 3.7.3 on windows
- [(#6590)](https://github.com/Microsoft/vcpkg/pull/6590) ffmpeg: enable arm/arm64 windows support
- [(#6653)](https://github.com/Microsoft/vcpkg/pull/6653) [vcpkg] Fix install from head when no-downloads
- [(#6667)](https://github.com/Microsoft/vcpkg/pull/6667) make meson not download things
- [(#6695)](https://github.com/Microsoft/vcpkg/pull/6695) [icu] Enable parallel builds
- [(#6704)](https://github.com/Microsoft/vcpkg/pull/6704) [DOXYGEN]Upgrade doxygen to 1.8.15.
- [(#6788)](https://github.com/Microsoft/vcpkg/pull/6788) [vcpkg] Bootstrap should use Get-CimInstance instead of Get-WmiObject.
- [(#6826)](https://github.com/Microsoft/vcpkg/pull/6826) [vcpkg] Apply clang format
- [(#6846)](https://github.com/Microsoft/vcpkg/pull/6846) Introduce an easier way to identify target systems...
- [(#6867)](https://github.com/Microsoft/vcpkg/pull/6867) Protect #pragma comment(lib, "foo") with _WIN32 checks
- [(#6872)](https://github.com/Microsoft/vcpkg/pull/6872) set CMAKE_SYSTEM_PROCESSOR in Linux
- [(#6880)](https://github.com/Microsoft/vcpkg/pull/6880) retry on flaky linker
- [(#6919)](https://github.com/Microsoft/vcpkg/pull/6919) [vcpkg] Improve vcpkg::Files::Filesystem error handling
- [(#6943)](https://github.com/Microsoft/vcpkg/pull/6943) address qhull flaky build with msvc linker
- [(#6952)](https://github.com/Microsoft/vcpkg/pull/6952) bootstrap.s<span>h</span>: Retry up to 3 times for transient download errors
- [(#6960)](https://github.com/Microsoft/vcpkg/pull/6960) Use correct path separators for each platform
- [(#6968)](https://github.com/Microsoft/vcpkg/pull/6968) VS 2019 16.3 deprecates <experimental/filesystem>.
- [(#6987)](https://github.com/Microsoft/vcpkg/pull/6987) Bump version to 2019.06.21
- [(#7038)](https://github.com/Microsoft/vcpkg/pull/7038) #5248 make vcpkg buildable as  'system' user
- [(#7039)](https://github.com/Microsoft/vcpkg/pull/7039) [docs]Update cmake docs
- [(#7074)](https://github.com/Microsoft/vcpkg/pull/7074) [vcpkg_configure_cmake] Add NO_CHARSET_FLAG option
- [(#7086)](https://github.com/Microsoft/vcpkg/pull/7086) [vcpkg] fail archived port install when decompression fails

<details>
<summary><b>The following 44 ports have been added:</b></summary>

| port | version |
|---|---|
|[any-lite](https://github.com/Microsoft/vcpkg/pull/6629)       | 0.2.0
|[argparse](https://github.com/Microsoft/vcpkg/pull/6866)       | 2019-06-10
|[bdwgc](https://github.com/Microsoft/vcpkg/pull/6405)          | 8.0.4-1
|[byte-lite](https://github.com/Microsoft/vcpkg/pull/6630)      | 0.2.0
|[casclib](https://github.com/Microsoft/vcpkg/pull/6744)        | 1.50
|[cjson](https://github.com/Microsoft/vcpkg/pull/6081)          | 1.7.10-1
|[cpp-httplib](https://github.com/Microsoft/vcpkg/pull/7037)    | 0.2.0
|[cppcodec](https://github.com/Microsoft/vcpkg/pull/6651)       | 0.2
|[expected-lite](https://github.com/Microsoft/vcpkg/pull/6642)  | 0.3.0
|[greatest](https://github.com/Microsoft/vcpkg/pull/6934)       | 1.4.2
|[hedley](https://github.com/Microsoft/vcpkg/pull/6776)         | 2019-05-08-1
|[immer](https://github.com/Microsoft/vcpkg/pull/6814)          | 2019-06-07
|[itpp](https://github.com/Microsoft/vcpkg/pull/6672)           | 4.3.1
|[ixwebsocket](https://github.com/Microsoft/vcpkg/pull/6835)    | 4.0.3
|[json-c](https://github.com/Microsoft/vcpkg/pull/6446)         | 2019-05-31
|[libfabric](https://github.com/Microsoft/vcpkg/pull/4740)<sup>[(#7036)](https://github.com/Microsoft/vcpkg/pull/7036)</sup>      | 1.7.1-1
|[libftdi](https://github.com/Microsoft/vcpkg/pull/6843)<sup>[(#7015)](https://github.com/Microsoft/vcpkg/pull/7015) [(#7055)](https://github.com/Microsoft/vcpkg/pull/7055)</sup>        | 0.20-1
|[libftdi1](https://github.com/Microsoft/vcpkg/pull/6843)       | 1.4
|[libpmemobj-cpp](https://github.com/Microsoft/vcpkg/pull/7020)<sup>[(#7097)](https://github.com/Microsoft/vcpkg/pull/7095)</sup> | 1.6-1
|[libraqm](https://github.com/Microsoft/vcpkg/pull/6659)        | 0.6.0
|[libu2f-server](https://github.com/Microsoft/vcpkg/pull/6781)  | 1.1.0
|[libzen](https://github.com/Microsoft/vcpkg/pull/7004)         | 0.4.37
|[magic-enum](https://github.com/Microsoft/vcpkg/pull/6817)     | 2019-06-07
|[networkdirect-sdk](https://github.com/Microsoft/vcpkg/pull/4740) | 2.0.1
|[observer-ptr-lite](https://github.com/Microsoft/vcpkg/pull/6652) | 0.4.0
|[openigtlink](https://github.com/Microsoft/vcpkg/pull/6769)    | 3.0
|[optional-bare](https://github.com/Microsoft/vcpkg/pull/6654)  | 1.1.0
|[optional-lite](https://github.com/Microsoft/vcpkg/pull/6655)  | 3.2.0
|[polyclipping](https://github.com/Microsoft/vcpkg/pull/6769)   | 6.4.2
|[ppconsul](https://github.com/Microsoft/vcpkg/pull/6911)<sup>[(#6967)](https://github.com/Microsoft/vcpkg/pull/6967)</sup>       | 0.3-1
|[pprint](https://github.com/Microsoft/vcpkg/pull/6678)         | 2019-06-01
|[restclient-cpp](https://github.com/Microsoft/vcpkg/pull/6936)<sup>[(#7054)](https://github.com/Microsoft/vcpkg/pull/7054)</sup> | 0.5.1-2
|[ring-span-lite](https://github.com/Microsoft/vcpkg/pull/6696) | 0.3.0
|[robin-hood-hashing](https://github.com/Microsoft/vcpkg/pull/6709) | 3.2.13
|[simde](https://github.com/Microsoft/vcpkg/pull/6777)          | 2019-06-05
|[span-lite](https://github.com/Microsoft/vcpkg/pull/6703)      | 0.5.0
|[sprout](https://github.com/Microsoft/vcpkg/pull/6997)         | 2019-06-20
|[stormlib](https://github.com/Microsoft/vcpkg/pull/6428)       | 9.22
|[string-view-lite](https://github.com/Microsoft/vcpkg/pull/6758) | 1.3.0
|[tl-function-ref](https://github.com/Microsoft/vcpkg/pull/7028) | 1.0.0-1
|[variant-lite](https://github.com/Microsoft/vcpkg/pull/6720)   | 1.2.2
|[wpilib](https://github.com/Microsoft/vcpkg/pull/6716)<sup>[(#7087)](https://github.com/Microsoft/vcpkg/pull/7087)</sup>         | 2019.5.1
|[zstr](https://github.com/Microsoft/vcpkg/pull/6773)           | 1.0.1
|[zydis](https://github.com/Microsoft/vcpkg/pull/6861)          | 2.0.3
</details>

<details>
<summary><b>The following 291 ports have been updated:</b></summary>

- alembic        `1.7.11` -> `1.7.11-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- angelscript    `2.33.0` -> `2.33.0-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- angle          `2019-03-13-c2ee2cc-3` -> `2019-06-13`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6892)](https://github.com/Microsoft/vcpkg/pull/6892) [angle] Update to latest master

- arb            `2.11.1-2` -> `2.16.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6763)](https://github.com/Microsoft/vcpkg/pull/6763) [arb]Upgrade version to 2.16.0 and fix build error.

- armadillo      `2019-04-16-f00d3225` -> `2019-04-16-3`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#7022)](https://github.com/Microsoft/vcpkg/pull/7022) [armadillo] Fix build error in Linux

- arrow          `0.13.0-3` -> `0.13.0-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6757)](https://github.com/Microsoft/vcpkg/pull/6757) [arrow] fix findzstd patch

- asio           `1.12.2` -> `1.12.2-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6751)](https://github.com/Microsoft/vcpkg/pull/6751) [asio] Add cmake target
    - [(#7083)](https://github.com/Microsoft/vcpkg/pull/7083) [asio] fix flaky build

- assimp         `4.1.0-4` -> `4.1.0-8`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6593)](https://github.com/Microsoft/vcpkg/pull/6593) [assimp]Fix lrrXML library dependencies.
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6887)](https://github.com/Microsoft/vcpkg/pull/6887) [assimp] Fix install assimp when passing --head

- avro-c         `1.8.2-1` -> `1.8.2-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- aws-c-common   `0.3.0` -> `0.3.11-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6747)](https://github.com/Microsoft/vcpkg/pull/6747) [aws-c-common]Upgrade version to 0.3.11

- aws-sdk-cpp    `1.7.106` -> `1.7.116`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6932)](https://github.com/Microsoft/vcpkg/pull/6932) [aws-sdk-cpp]Upgrade to 1.7.116

- azure-c-shared-utility `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- azure-iot-sdk-c `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- azure-macro-utils-c `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- azure-uamqp-c  `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- azure-uhttp-c  `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- azure-umqtt-c  `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- blosc          `1.16.3` -> `1.16.3-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6928)](https://github.com/Microsoft/vcpkg/pull/6928) [blosc] Fix the bug when building release-only.

- bond           `7.0.2-2` -> `8.1.0`
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL
    - [(#6954)](https://github.com/Microsoft/vcpkg/pull/6954) [bond]Upgrade version to 8.1.0 and add Linux/OSX support.

- boost-thread   `1.70.0` -> `1.70.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6840)](https://github.com/Microsoft/vcpkg/pull/6840) [boost-thread] Fix old patches

- boost-variant  `1.69.0` -> `1.70.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#7047)](https://github.com/Microsoft/vcpkg/pull/7047) [Boost-variant] Upgrade to 1.70.0

- botan          `2.9.0` -> `2.9.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- c-ares         `2019-5-2` -> `2019-5-2-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cairo          `1.16.0` -> `1.16.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6806)](https://github.com/Microsoft/vcpkg/pull/6806) [cairo] Fix linker errors on Linux and MacOS

- capnproto      `0.7.0-1` -> `0.7.0-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL
    - [(#7024)](https://github.com/Microsoft/vcpkg/pull/7024) [capnproto] Enable Linux and OSX support

- cartographer   `1.0.0` -> `1.0.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- catch2         `2.7.2` -> `2.7.2-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- ccd            `2.1` -> `2.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- celero         `2.4.0-1` -> `2.5.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6845)](https://github.com/Microsoft/vcpkg/pull/6845) Celero: Update to v2.5.0 release

- cereal         `1.2.2-1` -> `1.2.2-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- ceres          `1.14.0-3` -> `1.14.0-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- clapack        `3.2.1-4` -> `3.2.1-9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- clblas         `2.12-1` -> `2.12-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- clfft          `2.12.2` -> `2.12.2-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cli            `1.1` -> `1.1-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- clp            `1.17.2` -> `1.17.2-2`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cnl            `2019-01-09` -> `2019-06-23`
    - [(#7031)](https://github.com/Microsoft/vcpkg/pull/7031) [cnl] Update cnl to latest

- coinutils      `2.11.2` -> `2.11.2-2`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- collada-dom    `2.5.0` -> `2.5.0-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- console-bridge `0.3.2-3` -> `0.3.2-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cpp-netlib     `0.13.0-final` -> `0.13.0-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cppcms         `1.1.0-2` -> `1.2.1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- cpr            `1.3.0-6` -> `1.3.0-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6429)](https://github.com/Microsoft/vcpkg/pull/6429) [Curl] Upgrades 2019.05.08

- crc32c         `1.0.7` -> `1.0.7-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cryptopp       `8.1.0` -> `8.1.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6821)](https://github.com/Microsoft/vcpkg/pull/6821) [cryptopp] fix build by disabling assembly on osx

- curl           `7.61.1-7` -> `7.65.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6429)](https://github.com/Microsoft/vcpkg/pull/6429) [Curl] Upgrades 2019.05.08
    - [(#6649)](https://github.com/Microsoft/vcpkg/pull/6649) [Curl] Fix cmake target name
    - [(#6698)](https://github.com/Microsoft/vcpkg/pull/6698) [curl] Revert revert of `-imp` suffix removal.
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- cxxopts        `2.1.2` -> `2.1.2-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- darknet        `0.2.5-1` -> `0.2.5-4`
    - [(#6787)](https://github.com/Microsoft/vcpkg/pull/6787) [darknet] update to latest release
    - [(#7064)](https://github.com/Microsoft/vcpkg/pull/7064) [darknet] enable ninja

- darts-clone    `1767ab87cffe` -> `1767ab87cffe-1`
    - [(#6875)](https://github.com/Microsoft/vcpkg/pull/6875) [libsodium/darts-clone] remove conflicting makefile

- dcmtk          `3.6.3-1` -> `3.6.4`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- dlib           `19.17` -> `19.17-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32

- doctest        `2.3.2` -> `2.3.3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6998)](https://github.com/Microsoft/vcpkg/pull/6998) [doctest] Update to 2.3.3

- draco          `1.3.3-2` -> `1.3.5`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6796)](https://github.com/Microsoft/vcpkg/pull/6796) [draco, flatbuffers, forge] Update to new version

- duilib         `2019-4-28-1` -> `2019-4-28-2`
    - [(#7074)](https://github.com/Microsoft/vcpkg/pull/7074) [vcpkg_configure_cmake] Add NO_CHARSET_FLAG option

- ebml           `1.3.8` -> `1.3.9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6662)](https://github.com/Microsoft/vcpkg/pull/6662) [ebml, matroska] Upgrade ebml to v1.3.9 and matroska to v1.5.2

- eigen3         `3.3.7-1` -> `3.3.7-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- ensmallen      `1.15.0` -> `1.15.1`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- entityx        `1.3.0` -> `1.3.0-1`
    - [(#6736)](https://github.com/Microsoft/vcpkg/pull/6736) [entityx][entt] Disable parallel configure
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- entt           `3.0.0` -> `3.0.0-1`
    - [(#6736)](https://github.com/Microsoft/vcpkg/pull/6736) [entityx][entt] Disable parallel configure
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- exiv2          `0.27` -> `0.27.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL
    - [(#6905)](https://github.com/Microsoft/vcpkg/pull/6905) [Exiv2] update to 0.27.1

- fastcdr        `1.0.6-2` -> `1.0.9-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- fcl            `0.5.0-5` -> `0.5.0-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- ffmpeg         `4.1-5` -> `4.1-8`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6590)](https://github.com/Microsoft/vcpkg/pull/6590) ffmpeg: enable arm/arm64 windows support
    - [(#6694)](https://github.com/Microsoft/vcpkg/pull/6694) [ffmpeg] Correctly set environment variables for gcc/clang/icc
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6743)](https://github.com/Microsoft/vcpkg/pull/6743) [ffmpeg] Fix regression on windows
    - [(#6784)](https://github.com/Microsoft/vcpkg/pull/6784) [FFmpeg] Add 'vpx' feature.

- fizz           `2019.05.13.00` -> `2019.05.20.00-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6969)](https://github.com/Microsoft/vcpkg/pull/6969) [libevent] Upgrade to version 2.1.10

- flann          `jan2019` -> `1.9.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6931)](https://github.com/Microsoft/vcpkg/pull/6931) [flann]Upgrade version to 1.9.1 and fix build error.
    - [(#7073)](https://github.com/Microsoft/vcpkg/pull/7073) [flann] fix flaky config

- flatbuffers    `1.10.0-1` -> `1.11.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6796)](https://github.com/Microsoft/vcpkg/pull/6796) [draco, flatbuffers, forge] Update to new version
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- fmi4cpp        `0.7.0` -> `0.7.0-1`
    - [(#7021)](https://github.com/Microsoft/vcpkg/pull/7021) [nana, fmi4cpp] Fix Visual Studio 2019 deprecates <experimental/filesystem>.

- folly          `2019.05.13.00` -> `2019.05.20.00-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6974)](https://github.com/Microsoft/vcpkg/pull/6974) [Folly] define _CRT_INTERNAL_NONSTDC_NAMES to 0 to disable non-underscore posix names on windows

- fontconfig     `2.12.4-8` -> `2.12.4-9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32

- forest         `11.0.1` -> `12.0.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6938)](https://github.com/Microsoft/vcpkg/pull/6938) [forest] move to 12.0.0

- forge          `1.0.3-1` -> `1.0.4-1`
    - [(#6796)](https://github.com/Microsoft/vcpkg/pull/6796) [draco, flatbuffers, forge] Update to new version

- freeimage      `3.18.0-5` -> `3.18.0-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- freerdp        `2.0.0-rc4-1` -> `2.0.0-rc4-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- freetype       `2.9.1-1` -> `2.10.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6754)](https://github.com/Microsoft/vcpkg/pull/6754) Fix freetype cmake config files
    - [(#7057)](https://github.com/Microsoft/vcpkg/pull/7057) [freetype] Upgrade to version 2.10.0

- freexl         `1.0.4-1` -> `1.0.4-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6813)](https://github.com/Microsoft/vcpkg/pull/6813) [freexl]: Linux build support

- ftgl           `2.3.1` -> `2.4.0-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- g2o            `20170730_git-4` -> `20170730_git-5`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- gdcm           `3.0.0` -> `3.0.0-3`
    - [(#6710)](https://github.com/Microsoft/vcpkg/pull/6710) [gdcm,jbig2dec] move patches from #5169
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- gdk-pixbuf     `2.36.9-2` -> `2.36.9-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6663)](https://github.com/Microsoft/vcpkg/pull/6663) [gdk-pixbuf] Fix Linux compilation.

- geogram        `1.6.9-3` -> `1.6.9-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- geographiclib  `1.47-patch1-5` -> `1.47-patch1-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- gherkin-c      `c-libs-e63e83104b` -> `4.1.2`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- gl3w           `99ed3211` -> `2018-05-31-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- glad           `0.1.29` -> `0.1.30`
    - [(#6819)](https://github.com/Microsoft/vcpkg/pull/6819) [glad] update to 0.1.30

- glbinding      `3.1.0` -> `3.1.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6872)](https://github.com/Microsoft/vcpkg/pull/6872) set CMAKE_SYSTEM_PROCESSOR in Linux
    - [(#6876)](https://github.com/Microsoft/vcpkg/pull/6876) [glbinding] remove conflict with other opengl ports

- glew           `2.1.0-3` -> `2.1.0-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6853)](https://github.com/Microsoft/vcpkg/pull/6853) [glew] Disable the link option /nodefaultlib and /noentry

- glib           `2.52.3-14-1` -> `2.52.3-14-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6663)](https://github.com/Microsoft/vcpkg/pull/6663) [gdk-pixbuf] Fix Linux compilation.

- glibmm         `2.52.1-8` -> `2.52.1-9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6550)](https://github.com/Microsoft/vcpkg/pull/6550) [glibmm] Reintroduce CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- globjects      `1.1.0-2018-09-19-1` -> `1.1.0-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- glog           `0.4.0` -> `0.4.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- glslang        `2018-03-02-2` -> `2019-03-05`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6689)](https://github.com/Microsoft/vcpkg/pull/6689) [shaderc] update

- google-cloud-cpp `0.9.0` -> `0.10.0`
    - [(#6785)](https://github.com/Microsoft/vcpkg/pull/6785) Upgrade google-cloud-cpp to 0.10.0.

- graphicsmagick `1.3.31-1` -> `1.3.32`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6947)](https://github.com/Microsoft/vcpkg/pull/6947) Graphicsmagick 1.3.32

- graphite2      `1.3.12` -> `1.3.12-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- grpc           `1.20.1-1` -> `1.21.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#5630)](https://github.com/Microsoft/vcpkg/pull/5630) [scripts] Fix vcpkg_fixup_cmake on non Windows platforms
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- gsoap          `2.8.82-2` -> `2.8.84-1`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6756)](https://github.com/Microsoft/vcpkg/pull/6756) update to 2.8.84

- gtk            `3.22.19-2` -> `3.22.19-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6671)](https://github.com/Microsoft/vcpkg/pull/6671) [pango/gtk]Fix build error C2001.

- harfbuzz       `2.4.0` -> `2.5.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6659)](https://github.com/Microsoft/vcpkg/pull/6659) [libraqm] Add new port (0.6.0)
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6761)](https://github.com/Microsoft/vcpkg/pull/6761) [harfbuzz]Upgrade version to 2.5.1 and fix patches.
    - [(#6879)](https://github.com/Microsoft/vcpkg/pull/6879) [harfbuzz] Propagate dependency on glib downstream

- hdf5           `1.10.5-5` -> `1.10.5-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6771)](https://github.com/Microsoft/vcpkg/pull/6771) [netcdf-c/hdf5] improve/correct linkage

- hpx            `1.2.1-1` -> `1.3.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6755)](https://github.com/Microsoft/vcpkg/pull/6755) Updating HPX to V1.3.0

- http-parser    `2.9.2` -> `2.9.2-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- icu            `61.1-6` -> `61.1-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6695)](https://github.com/Microsoft/vcpkg/pull/6695) [icu] Enable parallel builds

- idevicerestore `1.0.12-2` -> `1.0.12-3`
    - [(#6698)](https://github.com/Microsoft/vcpkg/pull/6698) [curl] Revert revert of `-imp` suffix removal.

- imgui          `1.70` -> `1.70-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- inih           `43` -> `44`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- ismrmrd        `1.4` -> `1.4.0-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- itk            `4.13.0-906736bd-3` -> `5.0.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6767)](https://github.com/Microsoft/vcpkg/pull/6767) [itk] Upgrade to 5.0.0

- jansson        `2.11-2` -> `2.12-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- jasper         `2.0.16-1` -> `2.0.16-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- jbig2dec       `0.16` -> `0.16-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6710)](https://github.com/Microsoft/vcpkg/pull/6710) [gdcm,jbig2dec] move patches from #5169

- json-dto       `0.2.8` -> `0.2.8-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- json11         `2017-06-20-1` -> `2017-06-20-2`
    - [(#6967)](https://github.com/Microsoft/vcpkg/pull/6967) [ppconsul] remove conflict with json11

- jxrlib         `1.1-6` -> `1.1-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- kangaru        `4.1.3` -> `4.1.3-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- kd-soap        `1.7.0` -> `1.8.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6838)](https://github.com/Microsoft/vcpkg/pull/6838) [kd-soap]Upgrade version to 1.8.0
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- lcm            `1.3.95-1` -> `1.4.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6836)](https://github.com/Microsoft/vcpkg/pull/6836) [lcm]Upgrade version to 1.4.0 and fix build error.

- leptonica      `1.76.0` -> `1.76.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- leveldb        `2017-10-25-8b1cd3753b184341e837b30383832645135d3d73-3` -> `1.22`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6900)](https://github.com/Microsoft/vcpkg/pull/6900) [leveldb] Port update

- libbson        `1.13.0` -> `1.14.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6862)](https://github.com/Microsoft/vcpkg/pull/6862) [libbson mongo-c-driver mongo-cxx-driver] upgrades to new revision

- libcroco       `0.6.13` -> `0.6.13-1`
    - [(#6663)](https://github.com/Microsoft/vcpkg/pull/6663) [gdk-pixbuf] Fix Linux compilation.

- libevent       `2.1.8-5` -> `2.1.10`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6969)](https://github.com/Microsoft/vcpkg/pull/6969) [libevent] Upgrade to version 2.1.10

- libfreenect2   `0.2.0-1` -> `0.2.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libgeotiff     `1.4.2-8` -> `1.4.2-9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration

- libgit2        `0.28.1` -> `0.28.2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libharu        `2017-08-15-d84867ebf9f-6` -> `2017-08-15-8`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libics         `1.6.2` -> `1.6.3`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libideviceactivation `1.2.68` -> `1.2.68-1`
    - [(#6698)](https://github.com/Microsoft/vcpkg/pull/6698) [curl] Revert revert of `-imp` suffix removal.

- libimobiledevice `1.2.1.215-1` -> `1.2.76`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libjpeg-turbo  `2.0.1-1` -> `2.0.2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6482)](https://github.com/Microsoft/vcpkg/pull/6482) [libjpeg-turbo] Upgrades 2019.05.08

- liblemon       `1.3.1-4` -> `2019-06-13`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6679)](https://github.com/Microsoft/vcpkg/pull/6679) [liblemon] made into a rolling-release port

- liblsl         `1.13.0-b4` -> `1.13.0-b6`
    - [(#6745)](https://github.com/Microsoft/vcpkg/pull/6745) [liblsl] Update liblsl port to 1.13.0-b6

- liblzma        `5.2.4-1` -> `5.2.4-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration

- libmikmod      `3.3.11.1-2` -> `3.3.11.1-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#7035)](https://github.com/Microsoft/vcpkg/pull/7035) [libmikmod] patch cmake warning
    - [(#7052)](https://github.com/Microsoft/vcpkg/pull/7052) [libmikmod] resolve ninja error (-w dupbuild=err)

- libmodbus      `3.1.4-2` -> `3.1.4-3`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libmupdf       `1.12.0-2` -> `1.15.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6710)](https://github.com/Microsoft/vcpkg/pull/6710) [gdcm,jbig2dec] move patches from #5169
    - [(#7046)](https://github.com/Microsoft/vcpkg/pull/7046) [libmupdf] Update the port to version 1.15.0

- libmysql       `8.0.4-3` -> `8.0.4-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6442)](https://github.com/Microsoft/vcpkg/pull/6442) [libmysql]Fix build error in linux.

- libogg         `1.3.3-2` -> `1.3.3-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6588)](https://github.com/Microsoft/vcpkg/pull/6588) [libogg] Update to 1.3.3-3
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libopusenc     `0.1-1` -> `0.2.1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6748)](https://github.com/Microsoft/vcpkg/pull/6748) [libopusenc]Upgrade version to 0.2.1

- libpff         `2018-07-14` -> `2018-07-14-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libplist       `2.0.1.197-2` -> `1.2.77`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libpng         `1.6.37-1` -> `1.6.37-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libqglviewer   `2.7.1-1` -> `2.7.0`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libraw         `0.19.2` -> `201903-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6742)](https://github.com/Microsoft/vcpkg/pull/6742) [libraw] Add include for select_library_configurations [(#6715)](https://github.com/Microsoft/vcpkg/pull/6715)

- libressl       `2.9.1` -> `2.9.1-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libsndfile     `1.0.29-6830c42-6` -> `1.0.29-8`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6896)](https://github.com/Microsoft/vcpkg/pull/6896) [sndfile/libsndfile] remove duplicate port, forward to libsndfile

- libsodium      `1.0.17-2` -> `1.0.18`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6778)](https://github.com/Microsoft/vcpkg/pull/6778) [libsodium] Update to 1.0.18
    - [(#6875)](https://github.com/Microsoft/vcpkg/pull/6875) [libsodium/darts-clone] remove conflicting makefile

- libspatialite  `4.3.0a-2` -> `4.3.0a-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration

- libsquish      `1.15` -> `1.15-1`
    - [(#6893)](https://github.com/Microsoft/vcpkg/pull/6893) [libsquish] fix flaky build

- libtins        `4.0-2` -> `4.2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#7008)](https://github.com/Microsoft/vcpkg/pull/7008) [libtins]Upgrade version to 4.2 and adds dependent ports to new version.

- libunibreak    `4.1` -> `4.2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libusb         `1.0.22-2` -> `1.0.22-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- libusbmuxd     `1.0.107-2` -> `1.2.77`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libuv          `1.29.0` -> `1.29.1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- libwebp        `1.0.2-3` -> `1.0.2-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6648)](https://github.com/Microsoft/vcpkg/pull/6648) [libwebp]Fix static build: add dependency libraries "dxguid winmm".

- libwebsockets  `3.1.0` -> `3.1.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6855)](https://github.com/Microsoft/vcpkg/pull/6855) [libwebsockets] Fix build error on Linux

- libxlsxwriter  `0.8.6-1` -> `0.8.7-1`
    - [(#7034)](https://github.com/Microsoft/vcpkg/pull/7034) [libxlsxwriter] upgrade to 0.8.7

- libxslt        `1.1.29` -> `1.1.33`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#7058)](https://github.com/Microsoft/vcpkg/pull/7058) [libxslt] Update the version to 1.1.33 and change the URL.

- libyaml        `0.2.1-1` -> `0.2.2`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- llvm           `7.0.0-2` -> `7.0.0-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6631)](https://github.com/Microsoft/vcpkg/pull/6631) [llvm]Fix build error on x64-windows.

- lmdb           `0.9.23` -> `0.9.23-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- log4cplus      `2.0.4` -> `2.0.4-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6930)](https://github.com/Microsoft/vcpkg/pull/6930) [log4cplus]Fix lnk2019 errors when using log4cplus.

- lz4            `1.9.1-1` -> `1.9.1-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6735)](https://github.com/Microsoft/vcpkg/pull/6735) [lz4]Fix conflict file xxhash.h

- magnum-extras  `2019.01-1` -> `2019.01-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- magnum-integration `2019.01-1` -> `2019.01-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- mathgl         `2.4.3` -> `2.4.3-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- matroska       `1.5.1` -> `1.5.2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6662)](https://github.com/Microsoft/vcpkg/pull/6662) [ebml, matroska] Upgrade ebml to v1.3.9 and matroska to v1.5.2

- miniz          `2.0.8` -> `2.1.0`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- mlpack         `3.1.0-1` -> `3.1.1`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6907)](https://github.com/Microsoft/vcpkg/pull/6907) [mlpack] Updated to version 3.1.1

- mongo-c-driver `1.13.0` -> `1.14.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6862)](https://github.com/Microsoft/vcpkg/pull/6862) [libbson mongo-c-driver mongo-cxx-driver] upgrades to new revision

- mongo-cxx-driver `3.2.0-2` -> `3.4.0-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6862)](https://github.com/Microsoft/vcpkg/pull/6862) [libbson mongo-c-driver mongo-cxx-driver] upgrades to new revision

- moos-core      `10.4.0-2` -> `10.4.0-3`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- mosquitto      `1.5.0-3` -> `1.6.2-2`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- ms-angle       `2018-04-18-1` -> `2018-04-18-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- msix           `MsixCoreInstaller-preview` -> `MsixCoreInstaller-preview-1`
    - [(#7074)](https://github.com/Microsoft/vcpkg/pull/7074) [vcpkg_configure_cmake] Add NO_CHARSET_FLAG option

- msmpi          `10.0` -> `10.0-2`
    - [(#6945)](https://github.com/Microsoft/vcpkg/pull/6945) [msmpi] Fix /MD for static libs.

- nana           `1.7.1` -> `1.7.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#7021)](https://github.com/Microsoft/vcpkg/pull/7021) [nana, fmi4cpp] Fix Visual Studio 2019 deprecates <experimental/filesystem>.

- nanomsg        `1.1.5` -> `1.1.5-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- netcdf-c       `4.7.0` -> `4.7.0-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6771)](https://github.com/Microsoft/vcpkg/pull/6771) [netcdf-c/hdf5] improve/correct linkage
    - [(#6865)](https://github.com/Microsoft/vcpkg/pull/6865) [netcdf-c]Fix build error on linux.
    - [(#6971)](https://github.com/Microsoft/vcpkg/pull/6971) [netcdf-c] Fix link error.

- nlopt          `2.6.1` -> `2.6.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6739)](https://github.com/Microsoft/vcpkg/pull/6739) [protobuf] Update to 3.8.0

- nmslib         `1.7.2-1` -> `1.7.3.6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- nrf-ble-driver `4.1.0` -> `4.1.1`

- nvtt           `2.1.0-3` -> `2.1.1`
    - [(#6765)](https://github.com/Microsoft/vcpkg/pull/6765) [nvtt]Upgrade version to 2.1.1 and fix build error on windows.

- octomap        `cefed0c1d79afafa5aeb05273cf1246b093b771c-6` -> `2017-03-11-7`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- ogre           `1.11.3-4` -> `1.12.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- oniguruma      `6.9.2` -> `6.9.2-2`
    - [(#6958)](https://github.com/Microsoft/vcpkg/pull/6958) [vcpkg] Add vcpkg_check_features
    - [(#7091)](https://github.com/Microsoft/vcpkg/pull/7091) [vcpkg] Update vcpkg_check_features document

- openblas       `0.3.6-2` -> `0.3.6-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- opencv         `3.4.3-7` -> `3.4.3-9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration
    - [(#6812)](https://github.com/Microsoft/vcpkg/pull/6812) [opencv] Fixed OpenCV versioning using wrong commit
    - [(#6901)](https://github.com/Microsoft/vcpkg/pull/6901) [opencv]Fix build error with feature gdcm: cannot find openjp2.

- openexr        `2.3.0-3` -> `2.3.0-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- openmama       `6.2.3` -> `6.2.3-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- openmvg        `1.4-2` -> `1.4-5`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- openmvs        `0.9` -> `1.0-1`
    - [(#6692)](https://github.com/Microsoft/vcpkg/pull/6692) update to v1.0
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- openni2        `2.2.0.33-8` -> `2.2.0.33-9`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- openssl        `0` -> `1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- opentracing    `1.5.1` -> `1.5.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- openvdb        `6.0.0-2` -> `6.1.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6864)](https://github.com/Microsoft/vcpkg/pull/6864) [openvdb]Upgrade version to 6.1.0, regenerate patches and fix build errors.

- openvpn3       `2018-03-21` -> `2018-03-21-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- openvr         `1.1.3b` -> `1.4.18`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- opusfile       `0.11-2` -> `0.11-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- orc            `1.5.5` -> `1.5.5-1`
    - [(#6739)](https://github.com/Microsoft/vcpkg/pull/6739) [protobuf] Update to 3.8.0

- orocos-kdl     `1.4` -> `1.4-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- osi            `0.108.4` -> `0.108.4-2`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- paho-mqtt      `1.2.1-1` -> `1.3.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6762)](https://github.com/Microsoft/vcpkg/pull/6762) [paho-mqtt] Upgrade to 1.3.0

- pango          `1.40.11-3` -> `1.40.11-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6671)](https://github.com/Microsoft/vcpkg/pull/6671) [pango/gtk]Fix build error C2001.

- pangolin       `0.5-6` -> `0.5-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- parallel-hashmap `1.22` -> `1.23`
    - [(#6917)](https://github.com/Microsoft/vcpkg/pull/6917) [parallel-hashmap] Update to current 1.23 version and include natvis file.

- pcl            `1.9.1-3` -> `1.9.1-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- pdal           `1.7.1-4` -> `1.7.1-5`
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration
    - [(#6603)](https://github.com/Microsoft/vcpkg/pull/6603) [pdal] delete and replace different find modules
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- pdcurses       `3.6` -> `3.8`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- poco           `2.0.0-pre-1` -> `2.0.0-pre-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- podofo         `0.9.6-6` -> `0.9.6-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration

- proj4          `4.9.3-1` -> `4.9.3-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- prometheus-cpp `0.6.0` -> `0.7.0`
    - [(#6822)](https://github.com/Microsoft/vcpkg/pull/6822) [prometheus-cpp] Update to version 0.7.0

- protobuf       `3.7.1` -> `3.8.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6739)](https://github.com/Microsoft/vcpkg/pull/6739) [protobuf] Update to 3.8.0

- pugixml        `1.9-1` -> `1.9-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- qca            `2.2.0-4` -> `2.2.1`
    - [(#6839)](https://github.com/Microsoft/vcpkg/pull/6839) [qca]Upgrade version to 2.2.1 and fix build error.
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- qt5-base       `5.12.3-1` -> `5.12.3-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#7019)](https://github.com/Microsoft/vcpkg/pull/7019) [qt5-base]Add execute permission when installing executables in Linux.

- qt5-declarative `5.12.3` -> `5.12.3-1`
    - [(#6927)](https://github.com/Microsoft/vcpkg/pull/6927) [qt5-declarative]Fix error when building release-only.

- re2            `2019-05-07` -> `2019-05-07-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- realsense2     `2.16.1-2` -> `2.22.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#5275)](https://github.com/Microsoft/vcpkg/pull/5275) [realsense2] Enable OpenNI2 driver option
    - [(#5777)](https://github.com/Microsoft/vcpkg/pull/5777) [realsense2] Update to v2.19.0

- reproc         `6.0.0` -> `6.0.0-1`
    - [(#6711)](https://github.com/Microsoft/vcpkg/pull/6711) [reproc] Enabled C++ target for version 6.0.0.

- restinio       `0.4.9` -> `0.5.1-1`
    - [(#6669)](https://github.com/Microsoft/vcpkg/pull/6669) RESTinio updated to v.0.4.9.1
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6749)](https://github.com/Microsoft/vcpkg/pull/6749) RESTinio updated to v.0.5.0
    - [(#6933)](https://github.com/Microsoft/vcpkg/pull/6933) RESTinio updated to v.0.5.1

- robin-map      `0.2.0` -> `0.6.1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- rtmidi         `2.1.1-2` -> `4.0.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6635)](https://github.com/Microsoft/vcpkg/pull/6635) [rtmidi] Update to version 4.0.0

- sdl2           `2.0.9-3` -> `2.0.9-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- sdl2-image     `2.0.4-2` -> `2.0.4-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- sdl2-mixer     `2.0.4-2` -> `2.0.4-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6929)](https://github.com/Microsoft/vcpkg/pull/6929) [sdl2-mixer]Fix build error with feature opusfile.

- sdl2-net       `2.0.1-6` -> `2.0.1-7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- sdl2-ttf       `2.0.15-2` -> `2.0.15-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- selene         `0.3.1` -> `0.3.1-1`
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- sf2cute        `0.2.0` -> `0.2.0-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- shaderc        `12fb656ab20ea9aa06e7084a74e5ff832b7ce2da-2` -> `2019-06-26`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6689)](https://github.com/Microsoft/vcpkg/pull/6689) [shaderc] update

- shiva          `1.0` -> `1.0-2`
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration
    - [(#6637)](https://github.com/Microsoft/vcpkg/pull/6637) [shiva] Fix build error "Could NOT find PythonInterp"

- shogun         `6.1.3-1` -> `6.1.3-3`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6739)](https://github.com/Microsoft/vcpkg/pull/6739) [protobuf] Update to 3.8.0
    - [(#6872)](https://github.com/Microsoft/vcpkg/pull/6872) set CMAKE_SYSTEM_PROCESSOR in Linux

- sndfile        `1.0.29-cebfdf2-1` -> `0`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6896)](https://github.com/Microsoft/vcpkg/pull/6896) [sndfile/libsndfile] remove duplicate port, forward to libsndfile

- snowhouse      `3.0.1` -> `3.1.0`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- so5extra       `1.2.3` -> `1.2.3-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- sobjectizer    `5.5.24.4` -> `5.5.24.4-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- sol2           `2.20.6` -> `3.0.2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- sophus         `1.0.0-1` -> `1.0.0-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32

- spdlog         `1.3.1` -> `1.3.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6924)](https://github.com/Microsoft/vcpkg/pull/6924) [spdlog]Add feature[benchmark]

- spirv-cross    `2018-08-07-1` -> `2019-05-09`
    - [(#6690)](https://github.com/Microsoft/vcpkg/pull/6690) update spirv cross

- spirv-headers  `2019-03-05` -> `2019-05-05`
    - [(#6689)](https://github.com/Microsoft/vcpkg/pull/6689) [shaderc] update

- spirv-tools    `2018.1-2` -> `2019.3-dev`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6689)](https://github.com/Microsoft/vcpkg/pull/6689) [shaderc] update

- sqlite-modern-cpp `3.2-e2248fa` -> `3.2-936cd0c8`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- sqlite-orm     `1.3` -> `1.3-1`
    - [(#6894)](https://github.com/Microsoft/vcpkg/pull/6894) [sqlite-orm] fix tag, update hash

- sqlite3        `3.27.2` -> `3.28.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6856)](https://github.com/Microsoft/vcpkg/pull/6856) [sqlite3]: Switch back to CMAKE_SYSTEM_NAME checks per original PR
    - [(#6856)](https://github.com/Microsoft/vcpkg/pull/6856) [sqlite3]: Shared library support for Linux
    - [(#6921)](https://github.com/Microsoft/vcpkg/pull/6921) [sqlite3] Update to 3.28.0

- sqlitecpp      `2.2-2` -> `2.3.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- strict-variant `v0.5` -> `0.5`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- string-theory  `2.1` -> `2.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- suitesparse    `5.1.2-2` -> `5.4.0-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- systemc        `2.3.3-2` -> `2.3.3-3`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- szip           `2.1.1-3` -> `2.1.1-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- taglib         `1.11.1-4` -> `1.11.1-20190531`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6851)](https://github.com/Microsoft/vcpkg/pull/6851) [taglib]Upgrade version to 1.11.1-20190531.

- tbb            `2019_U6` -> `2019_U7`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- tesseract      `4.0.0-1` -> `4.0.0-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- theia          `0.8` -> `0.8-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32

- thor           `2.0-2` -> `2.0-3`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6953)](https://github.com/Microsoft/vcpkg/pull/6953) [thor] Fix error on Linux.

- thrift         `2019-05-07` -> `2019-05-07-2`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6872)](https://github.com/Microsoft/vcpkg/pull/6872) set CMAKE_SYSTEM_PROCESSOR in Linux
    - [(#7074)](https://github.com/Microsoft/vcpkg/pull/7074) [vcpkg_configure_cmake] Add NO_CHARSET_FLAG option

- tidy-html5     `5.6.0` -> `5.6.0-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#7074)](https://github.com/Microsoft/vcpkg/pull/7074) [vcpkg_configure_cmake] Add NO_CHARSET_FLAG option

- tiff           `4.0.10-4` -> `4.0.10-6`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6000)](https://github.com/Microsoft/vcpkg/pull/6000) [LibLZMA] automatic configuration

- tinyexif       `1.0.2-4` -> `1.0.2-5`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- tinyobjloader  `1.4.1-1` -> `1.0.7-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- tinyxml2       `7.0.1` -> `7.0.1-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- tl-expected    `0.3-1` -> `1.0.0-1`
    - [(#7028)](https://github.com/Microsoft/vcpkg/pull/7028) [tl] Update tl::expected and tl::optional, add tl::function_ref

- tl-optional    `0.5-1` -> `1.0.0-1`
    - [(#7028)](https://github.com/Microsoft/vcpkg/pull/7028) [tl] Update tl::expected and tl::optional, add tl::function_ref

- tmx            `1.0.0` -> `1.0.0-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- treehopper     `1.11.3-2` -> `1.11.3-3`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- trompeloeil    `34` -> `34-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- umock-c        `2019-05-16` -> `2019-05-16.1`
    - [(#6804)](https://github.com/Microsoft/vcpkg/pull/6804) [azure] Update azure-iot-sdk-c for public-preview release of 2019-05-16

- urdfdom        `1.0.3` -> `1.0.3-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- urdfdom-headers `1.0.3` -> `1.0.4-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- usd            `0.8.4` -> `0.8.4-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- uvatlas        `sept2016-1` -> `apr2019`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- uvw            `1.17.0_libuv-v1.29` -> `1.17.0_libuv-v1.29-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6844)](https://github.com/Microsoft/vcpkg/pull/6844) [vcpkg] Add optional 'Homepage' field to CONTROL

- visit-struct   `1.0` -> `1.0-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- vlpp           `0.9.3.1-2` -> `0.10.0.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6793)](https://github.com/Microsoft/vcpkg/pull/6793) [vlpp] Upgrade to 0.10.0.0

- vtk            `8.2.0-2` -> `8.2.0-4`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6782)](https://github.com/Microsoft/vcpkg/pull/6782) [vtk] fix static hdf5 linkage.

- vxl            `v1.18.0-3` -> `v1.18.0-4`
    - [(#6657)](https://github.com/Microsoft/vcpkg/pull/6657) [vxl] move problematic feature to optional one

- wangle         `2019.05.13.00` -> `2019.05.20.00-1`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- wil            `2019-05-08` -> `2019-06-10`
    - [(#6847)](https://github.com/Microsoft/vcpkg/pull/6847) Update commit for WIL

- wt             `4.0.5` -> `4.0.5-1`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6925)](https://github.com/Microsoft/vcpkg/pull/6925) [wt] Fix XML file installation path

- xerces-c       `3.2.2-9` -> `3.2.2-10`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6970)](https://github.com/Microsoft/vcpkg/pull/6970) [xerces-c]Replace the macro DLL_EXPORT with the macro XERCES_DLL_EXPORT

- xeus           `0.19.1-1` -> `0.19.2`
    - [(#6618)](https://github.com/Microsoft/vcpkg/pull/6618) [many ports] Updates 2019.05.24

- xsimd          `7.2.3` -> `7.2.3-1`
    - [(#7091)](https://github.com/Microsoft/vcpkg/pull/7091) [vcpkg] Update vcpkg_check_features document

- xtensor        `0.20.7` -> `0.20.7-1`
    - [(#6958)](https://github.com/Microsoft/vcpkg/pull/6958) [vcpkg] Add vcpkg_check_features

- xxhash         `0.6.4-1` -> `0.7.0`
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
    - [(#6750)](https://github.com/Microsoft/vcpkg/pull/6750) [xxhash]Upgrade version to 0.7.0 and fix arm/uwp build errors.

- z3             `4.8.4-1` -> `4.8.5-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6803)](https://github.com/Microsoft/vcpkg/pull/6803) [z3] bump version to 4.8.5

- zopfli         `2019-01-19` -> `2019-01-19-1`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- zserge-webview `2019-04-27-1` -> `2019-04-27-2`
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl

- zxing-cpp      `3.3.3-3` -> `3.3.3-5`
    - [(#6371)](https://github.com/Microsoft/vcpkg/pull/6371) [openexr,openimageio,suitesparse,theia] updates for non-win32
    - [(#6730)](https://github.com/Microsoft/vcpkg/pull/6730) [many ports] improvements for linux/wsl
    - [(#6779)](https://github.com/Microsoft/vcpkg/pull/6779) [zxing-cpp] Fixed renaming zxing` -> `zxing-cpp`

- zziplib        `0.13.69-3` -> `0.13.69-4`
    - [(#7090)](https://github.com/Microsoft/vcpkg/pull/7090) [zziplib] fix flaky build
    - [(#2933)](https://github.com/Microsoft/vcpkg/pull/2933) [WIP] Add a Homepage URL entry for vcpkg ports
</details>

-- vcpkg team vcpkg@microsoft.com WED, 16 Jul 2019 05:17:00 -0800

vcpkg (2018.11.23)
--------------
  * Add ports:
    - aixlog         1.2.1
    - civetweb       1.11-1
    - cli11          1.6.1
    - cub            1.8.0
    - cutelyst2      2.5.2-1
    - easyloggingpp  9.96.5-1
    - ecsutil        1.0.1.2-1
    - fdlibm         5.3-2
    - fizz           2018.10.15.00
    - fmi4cpp        0.4.0
    - fribidi        1.0.5
    - glad           0.1.28-3
    - igloo          1.1.1
    - libtins        4.0-2
    - linalg         2.1
    - miniupnpc      2.1
    - nanovg         master
    - orc            1.5.2-f47e02c-2
    - pixel          0.3
    - plustache      0.4.0-1
    - prometheus-cpp 0.6.0
    - rapidcheck     2018-11-05-1
    - reproc         v1.0.0
    - sdl1           1.2.15-3
    - sdl1-net       1.2.8-2
    - snowhouse      3.0.1
    - so5extra       1.2.1
    - socket-io-client 1.6.1
    - stlab          1.3.3
    - tl-optional    0.5-1
    - trompeloeil    32-1
    - vulkan         1.1.82.1
  * Update ports:
    - abseil         2018-09-18-3 -> 2018-11-08
    - args           2018-06-28 -> 2018-10-25
    - asio           1.12.1 -> 1.12.1-1
    - asmjit         673dcefaa048c5f5a2bf8b85daf8f7b9978d018a -> 2018-11-08
    - assimp         4.1.0-2 -> 4.1.0-3
    - aws-sdk-cpp    1.6.12-1 -> 1.6.47
    - azure-c-shared-utility 1.1.5 -> 1.1.10-1
    - azure-iot-sdk-c 1.2.3 -> 1.2.10-1
    - azure-storage-cpp 5.1.1 -> 5.2.0
    - azure-uamqp-c  1.2.3 -> 1.2.10-1
    - azure-uhttp-c  LTS_01_2018_Ref01 -> 1.1.10-1
    - azure-umqtt-c  1.1.5 -> 1.1.10-1
    - berkeleydb     4.8.30 -> 4.8.30-2
    - boost-modular-build-helper 2018-08-21 -> 2018-10-19
    - brynet         0.9.0 -> 1.0.0
    - bzip2          1.0.6-2 -> 1.0.6-3
    - c-ares         cares-1_14_0 -> cares-1_15_0
    - catch2         2.4.0 -> 2.4.2
    - celero         2.3.0-1 -> 2.4.0
    - cgal           4.13-1 -> 4.13-2
    - chakracore     1.11.1-1 -> 1.11.2
    - cimg           2.3.6 -> 2.4.1
    - clara          2018-04-02 -> 2018-11-01
    - corrade        2018.04-1 -> 2018.10-1
    - cpprestsdk     2.10.6-1 -> 2.10.6-3
    - cxxopts        2.1.0-1 -> 2.1.1
    - dimcli         3.1.1-2 -> 4.0.1-1
    - directxmesh    aug2018 -> oct2018
    - directxtex     aug2018b -> oct2018
    - directxtk      aug2018 -> oct2018b
    - doctest        2.0.0 -> 2.0.1
    - double-conversion 3.1.0 -> 3.1.0-1
    - eastl          3.12.01 -> 3.12.04
    - egl-registry   2018-06-30 -> 2018-06-30-1
    - entityx        1.2.0-1 -> 1.2.0-2
    - entt           2.7.3 -> 2.7.3-1
    - exiv2          2018-09-18 -> 2018-11-08
    - exprtk         2018.09.30-9836f21 -> 2018-10-11
    - fastcdr        1.0.6-1 -> 1.0.6-2
    - fftw3          3.3.7-2 -> 3.3.8
    - flann          1.9.1-7 -> 1.9.1-8
    - fmt            5.2.0 -> 5.2.1
    - folly          2018.09.17.00 -> 2018.11.05.00
    - forest         9.0.5 -> 9.0.6
    - freeimage      3.17.0-4 -> 3.18.0-2
    - gdcm2          2.8.7 -> 2.8.8
    - glm            0.9.9.2 -> 0.9.9.3
    - google-cloud-cpp 0.1.0-1 -> 0.3.0-1
    - gtest          1.8.0-9 -> 1.8.1-1
    - gtk            3.22.19-1 -> 3.22.19-2
    - hunspell       1.6.1-2 -> 1.6.1-3
    - jsonnet        2018-09-18 -> 2018-11-01
    - libfreenect2   0.2.0 -> 0.2.0-1
    - libgd          2.2.4-3 -> 2.2.4-4
    - libgeotiff     1.4.2-4 -> 1.4.2-6
    - liblinear      2.20 -> 221
    - libpng         1.6.35 -> 1.6.35-1
    - libpq          9.6.1-4 -> 9.6.1-5
    - libusb         1.0.21-fc99620 -> 1.0.22-1
    - libuv          1.23.0 -> 1.24.0
    - libwebm        1.0.0.27-2 -> 1.0.0.27-3
    - magnum         2018.04-1 -> 2018.10-1
    - magnum-extras  2018.04-1 -> 2018.10-1
    - magnum-integration 2018.04-1 -> 2018.10-1
    - magnum-plugins 2018.04-1 -> 2018.10-1
    - matio          1.5.12 -> 1.5.13
    - metis          5.1.0-1 -> 5.1.0-2
    - minizip        1.2.11-2 -> 1.2.11-3
    - mpir           3.0.0-4 -> 3.0.0-5
    - ms-gsl         2018-09-18 -> 2018-11-08
    - nghttp2        1.33.0 -> 1.34.0
    - nlohmann-json  3.3.0 -> 3.4.0
    - nng            1.0.1 -> 1.1.0
    - nuklear        2018-09-18 -> 2018-11-01
    - openal-soft    1.19.0 -> 1.19.1
    - opencv         3.4.1 -> 3.4.3-3
    - opengl-registry 2018-06-30 -> 2018-06-30-1
    - openimageio    Release-1.8.13 -> 1.8.16
    - openssl-unix   1.0.2p -> 1.0.2p-1
    - opus           1.2.1-1 -> 1.3
    - osgearth       2.9-1 -> 2.9-2
    - pcl            1.8.1-12 -> 1.9.0-1
    - pixman         0.34.0-4 -> 0.34.0-5
    - portaudio      19.0.6.00-2 -> 19.0.6.00-4
    - qhull          2015.2-2 -> 2015.2-3
    - qscintilla     2.10-4 -> 2.10-7
    - qt5            5.9.2-1 -> 5.11.2
    - qt5-3d         5.9.2-0 -> 5.11.2
    - qt5-activeqt   5.9.2-0 -> 5.11.2
    - qt5-base       5.9.2-7 -> 5.11.2-1
    - qt5-charts     5.9.2-0 -> 5.11.2
    - qt5-datavis3d  5.9.2-0 -> 5.11.2
    - qt5-declarative 5.9.2-0 -> 5.11.2
    - qt5-gamepad    5.9.2-0 -> 5.11.2
    - qt5-graphicaleffects 5.9.2-0 -> 5.11.2
    - qt5-imageformats 5.9.2-0 -> 5.11.2
    - qt5-modularscripts 4 -> 2018-11-01-1
    - qt5-multimedia 5.9.2-0 -> 5.11.2
    - qt5-networkauth 5.9.2-0 -> 5.11.2
    - qt5-quickcontrols 5.9.2-1 -> 5.11.2
    - qt5-quickcontrols2 5.9.2-1 -> 5.11.2
    - qt5-script     5.9.2 -> 5.11.2
    - qt5-scxml      5.9.2-0 -> 5.11.2
    - qt5-serialport 5.9.2-0 -> 5.11.2
    - qt5-speech     5.9.2-0 -> 5.11.2
    - qt5-svg        5.9.2-0 -> 5.11.2
    - qt5-tools      5.9.2-0 -> 5.11.2
    - qt5-virtualkeyboard 5.9.2-0 -> 5.11.2
    - qt5-websockets 5.9.2-0 -> 5.11.2
    - qt5-winextras  5.9.2-0 -> 5.11.2
    - qt5-xmlpatterns 5.9.2-0 -> 5.11.2
    - qwt            6.1.3-5 -> 6.1.3-6
    - range-v3       0.3.5 -> 0.4.0-20181122
    - rapidjson      1.1.0-1 -> 1.1.0-2
    - re2            2018-09-18 -> 2018-11-01
    - rocksdb        5.14.2 -> 5.15.10
    - rs-core-lib    2018-09-18 -> 2018-10-25
    - rttr           0.9.5-2 -> 0.9.5-3
    - scintilla      4.0.3 -> 4.1.2
    - sdl2           2.0.8-1 -> 2.0.9-1
    - sfml           2.5.0-2 -> 2.5.1
    - sobjectizer    5.5.22.1 -> 5.5.23
    - spdlog         1.0.0 -> 1.2.1
    - sqlite3        3.24.0-1 -> 3.25.2
    - suitesparse    4.5.5-4 -> 5.1.2
    - tbb            2018_U5-4 -> 2018_U6
    - thrift         2018-09-18 -> 2018-11-01
    - tiff           4.0.9-4 -> 4.0.10
    - tiny-dnn       2018-09-18 -> 2018-10-25
    - unicorn        2018-09-18 -> 2018-10-25
    - unicorn-lib    2018-09-18 -> 2018-10-25
    - uriparser      0.8.6 -> 0.9.0
    - vtk            8.1.0-1 -> 8.1.0-3
    - vxl            20180414-7a130cf-1 -> v1.18.0-2
    - wangle         v2018.07.30.00-1 -> 2018.11.05.00
    - websocketpp    0.7.0-1 -> 0.8.1
    - winpcap        4.1.3-1 -> 4.1.3-2
    - xalan-c        1.11-1 -> 1.11-4
    - xerces-c       3.1.4-3 -> 3.2.2-5
    - yoga           1.9.0 -> 1.10.0
    - zeromq         2018-09-18 -> 2018-11-01
  * `vcpkg install`: Improve error messages
  * `vcpkg hash`: Now also tries `shaABCsum tools`, instead of only `shasum`. Allows building in OSes like Alpine.
  * `vcpkg edit`: No longer launches the editor in a clean (purged) environment.
  * `vcpkg upgrade`: now tab-completed in powershell (it was missing before).
  * Add new function: `vcpkg_from_git()`
  * Enable Visual Studio versions greater than 15.
  * Add Visual Studio Code autotection on OSX (#4589)
  * Work-around hash issue caused by NuGet adding signatures to all their files.
  * Improve building `vcpkg.exe` (Windows-only):
    - Builds out of source
    - Temporary files are removed after bootstrap
    - User Property Pages are ignored (#4620)
  * `vcpkg` now prints URL and filepath, when downloading a tool (#4640)
  * Bump version of `cmake` to 3.12.4
  * Bump version of `git` to 2.9.1

-- vcpkg team <vcpkg@microsoft.com>  FRI, 23 Nov 2018 14:30:00 -0800


vcpkg (2018.10.20)
--------------
  * Add ports:
    - 3fd            2.6.2
    - argtable2      2.13-1
    - asyncplusplus  1.0-1
    - bde            3.2.0.0
    - boost-hana-msvc 1.67.0-1
    - boost-yap      1.68.0
    - check          0.12.0-1
    - concurrentqueue 1.0.0-beta
    - crossguid      0.2.2-2018-06-16
    - darts-clone    1767ab87cffe
    - dcmtk          3.6.3
    - docopt         2018-04-16-2
    - egl-registry   2018-06-30
    - embree2        2.16.4-3
    - embree3        3.2.0-2
    - esaxx          ca7cb332011ec37
    - fastfeat       391d5e9
    - fmilib         2.0.3
    - fruit          3.4.0-1
    - getopt         0
    - getopt-win32   0.1
    - gmmlib         18.3.pre2-1
    - graphqlparser  v0.7.0
    - ideviceinstaller 1.1.2.23-1
    - idevicerestore 1.0.12-1
    - inih           42
    - intelrdfpmathlib 20U2
    - io2d           0.1-1
    - json11         2017-06-20
    - kangaru        4.1.2
    - kf5archive     5.50.0
    - kf5holidays    5.50.0
    - laszip         3.2.2-1
    - libdshowcapture 0.6.0
    - libideviceactivation 1.0.38-1
    - libimobiledevice 1.2.1.215-1
    - libirecovery   1.0.25-2
    - liblemon       1.3.1-2
    - libmaxminddb   1.3.2-1
    - libmodbus      3.1.4-1
    - libmorton      2018-19-07
    - libplist       2.0.1.197-2
    - libusbmuxd     1.0.107-2
    - libyaml        0.2.1-1
    - linenoise-ng   4754bee2d8eb3
    - luabridge      2.1-1
    - milerius-sfml-imgui 1.1
    - minisat-master-keying 2.2-mod-1
    - mio            2018-10-18-1
    - modp-base64
    - morton-nd      2.0.0
    - nanorange      0.0.0
    - nng            1.0.1
    - ogdf           2018-03-28-2
    - opengl-registry 2018-06-30
    - openssl-unix   1.0.2p
    - openssl-uwp    1.0.2l-winrt
    - openssl-windows 1.0.2p-1
    - osg-qt         3.5.7
    - parquet        1.4.0
    - pcg            0.98.1
    - pegtl          2.7.1
    - plib           1.8.5-2
    - pngwriter      0.7.0-1
    - python2        2.7.15-1
    - qt5-activeqt   5.9.2-0
    - qt5-script     5.9.2
    - readerwriterqueue 1.0.0
    - readline       0
    - readline-win32 5.0-2
    - restbed        4.16-07-28-2018
    - safeint        3.19.2
    - sais           2.4.1
    - selene         0.1.1
    - shiva          1.0
    - shiva-sfml     1.0
    - simpleini      2018-08-31-1
    - soil           2008.07.07-1
    - sol2           2.20.4
    - spaceland      7.8.2-0
    - spirv-cross    2018-08-07-1
    - tinyfiledialogs 3.3.7-1
    - tinyobjloader  1.2.0-1
    - tinyspline     0.2.0-1
    - tinyutf8       2.1.1-1
    - tl-expected    0.3-1
    - tmx            1.0.0
    - tmxparser      2.1.0-1
    - usbmuxd        1.1.1.133-1
    - usrsctp        35c1d97020a
    - uvw            1.11.2
    - vtk-dicom      0.8.8-alpha-1
    - vulkan-memory-allocator 2.1.0-1
    - wangle         v2018.07.30.00-1
    - woff2          1.0.2
  * Update ports:
    - abseil         2018-05-01-1 -> 2018-09-18-3
    - ace            6.4.8 -> 6.5.2
    - alembic        1.7.8 -> 1.7.9
    - allegro5       5.2.3.0 -> 5.2.4.0
    - angle          2017-06-14-8d471f-4 -> 2017-06-14-8d471f-5
    - apr            1.6.3 -> 1.6.5
    - args           2018-05-17 -> 2018-06-28
    - arrow          0.6.0-1 -> 0.9.0-1
    - asio           1.12.0-2 -> 1.12.1
    - assimp         4.1.0-1 -> 4.1.0-2
    - aws-sdk-cpp    1.4.52 -> 1.6.12-1
    - azure-c-shared-utility 1.1.3 -> 1.1.5
    - azure-storage-cpp 4.0.0 -> 5.1.1
    - azure-uhttp-c  2018-02-09 -> LTS_01_2018_Ref01
    - azure-umqtt-c  1.1.3 -> 1.1.5
    - benchmark      1.4.0 -> 1.4.1
    - blaze          3.3 -> 3.4-1
    - boost          1.67.0 -> 1.68.0
    - boost-accumulators 1.67.0 -> 1.68.0
    - boost-algorithm 1.67.0 -> 1.68.0
    - boost-align    1.67.0 -> 1.68.0
    - boost-any      1.67.0 -> 1.68.0
    - boost-array    1.67.0 -> 1.68.0
    - boost-asio     1.67.0-1 -> 1.68.0-1
    - boost-assert   1.67.0 -> 1.68.0
    - boost-assign   1.67.0 -> 1.68.0
    - boost-atomic   1.67.0 -> 1.68.0
    - boost-beast    1.67.0 -> 1.68.0
    - boost-bimap    1.67.0 -> 1.68.0
    - boost-bind     1.67.0 -> 1.68.0
    - boost-build    1.67.0 -> 1.68.0
    - boost-callable-traits 1.67.0 -> 1.68.0
    - boost-chrono   1.67.0 -> 1.68.0
    - boost-circular-buffer 1.67.0 -> 1.68.0
    - boost-compatibility 1.67.0 -> 1.68.0
    - boost-compute  1.67.0 -> 1.68.0
    - boost-concept-check 1.67.0 -> 1.68.0
    - boost-config   1.67.0 -> 1.68.0
    - boost-container 1.67.0 -> 1.68.0
    - boost-container-hash 1.67.0 -> 1.68.0
    - boost-context  1.67.0 -> 1.68.0-1
    - boost-contract 1.67.0 -> 1.68.0
    - boost-conversion 1.67.0 -> 1.68.0
    - boost-convert  1.67.0 -> 1.68.0
    - boost-core     1.67.0 -> 1.68.0
    - boost-coroutine 1.67.0 -> 1.68.0
    - boost-coroutine2 1.67.0 -> 1.68.0
    - boost-crc      1.67.0 -> 1.68.0
    - boost-date-time 1.67.0 -> 1.68.0
    - boost-detail   1.67.0 -> 1.68.0
    - boost-di       1.0.1 -> 1.0.2
    - boost-disjoint-sets 1.67.0 -> 1.68.0
    - boost-dll      1.67.0 -> 1.68.0
    - boost-dynamic-bitset 1.67.0 -> 1.68.0
    - boost-endian   1.67.0 -> 1.68.0
    - boost-exception 1.67.0 -> 1.68.0
    - boost-fiber    1.67.0 -> 1.68.0
    - boost-filesystem 1.67.0 -> 1.68.0
    - boost-flyweight 1.67.0 -> 1.68.0
    - boost-foreach  1.67.0 -> 1.68.0
    - boost-format   1.67.0 -> 1.68.0
    - boost-function 1.67.0 -> 1.68.0
    - boost-function-types 1.67.0 -> 1.68.0
    - boost-functional 1.67.0 -> 1.68.0
    - boost-fusion   1.67.0 -> 1.68.0
    - boost-geometry 1.67.0 -> 1.68.0
    - boost-gil      1.67.0 -> 1.68.0
    - boost-graph    1.67.0 -> 1.68.0
    - boost-graph-parallel 1.67.0 -> 1.68.0
    - boost-hana     1.67.0 -> 1.68.0-1
    - boost-heap     1.67.0 -> 1.68.0
    - boost-hof      1.67.0 -> 1.68.0
    - boost-icl      1.67.0 -> 1.68.0
    - boost-integer  1.67.0 -> 1.68.0
    - boost-interprocess 1.67.0 -> 1.68.0
    - boost-interval 1.67.0 -> 1.68.0
    - boost-intrusive 1.67.0 -> 1.68.0
    - boost-io       1.67.0 -> 1.68.0
    - boost-iostreams 1.67.0 -> 1.68.0
    - boost-iterator 1.67.0 -> 1.68.0
    - boost-lambda   1.67.0 -> 1.68.0
    - boost-lexical-cast 1.67.0 -> 1.68.0
    - boost-local-function 1.67.0 -> 1.68.0
    - boost-locale   1.67.0 -> 1.68.0
    - boost-lockfree 1.67.0 -> 1.68.0-1
    - boost-log      1.67.0 -> 1.68.0
    - boost-logic    1.67.0 -> 1.68.0
    - boost-math     1.67.0 -> 1.68.0
    - boost-metaparse 1.67.0 -> 1.68.0
    - boost-modular-build-helper 2018-05-14 -> 2018-08-21
    - boost-move     1.67.0 -> 1.68.0
    - boost-mp11     1.67.0 -> 1.68.0
    - boost-mpi      1.67.0-1 -> 1.68.0-1
    - boost-mpl      1.67.0 -> 1.68.0
    - boost-msm      1.67.0 -> 1.68.0
    - boost-multi-array 1.67.0 -> 1.68.0
    - boost-multi-index 1.67.0 -> 1.68.0
    - boost-multiprecision 1.67.0 -> 1.68.0
    - boost-numeric-conversion 1.67.0 -> 1.68.0
    - boost-odeint   1.67.0 -> 1.68.0
    - boost-optional 1.67.0 -> 1.68.0
    - boost-parameter 1.67.0 -> 1.68.0
    - boost-phoenix  1.67.0 -> 1.68.0
    - boost-poly-collection 1.67.0 -> 1.68.0
    - boost-polygon  1.67.0 -> 1.68.0
    - boost-pool     1.67.0 -> 1.68.0
    - boost-predef   1.67.0 -> 1.68.0
    - boost-preprocessor 1.67.0 -> 1.68.0
    - boost-process  1.67.0 -> 1.68.0
    - boost-program-options 1.67.0 -> 1.68.0
    - boost-property-map 1.67.0 -> 1.68.0
    - boost-property-tree 1.67.0 -> 1.68.0
    - boost-proto    1.67.0 -> 1.68.0
    - boost-ptr-container 1.67.0 -> 1.68.0
    - boost-python   1.67.0-1 -> 1.68.0-2
    - boost-qvm      1.67.0 -> 1.68.0
    - boost-random   1.67.0 -> 1.68.0
    - boost-range    1.67.0 -> 1.68.0
    - boost-ratio    1.67.0 -> 1.68.0
    - boost-rational 1.67.0 -> 1.68.0
    - boost-regex    1.67.0 -> 1.68.0
    - boost-scope-exit 1.67.0 -> 1.68.0
    - boost-serialization 1.67.0 -> 1.68.0
    - boost-signals  1.67.0 -> 1.68.0
    - boost-signals2 1.67.0 -> 1.68.0
    - boost-smart-ptr 1.67.0 -> 1.68.0
    - boost-sort     1.67.0 -> 1.68.0
    - boost-spirit   1.67.0 -> 1.68.0
    - boost-stacktrace 1.67.0 -> 1.68.0
    - boost-statechart 1.67.0 -> 1.68.0
    - boost-static-assert 1.67.0 -> 1.68.0
    - boost-system   1.67.0 -> 1.68.0
    - boost-test     1.67.0-2 -> 1.68.0-2
    - boost-thread   1.67.0 -> 1.68.0
    - boost-throw-exception 1.67.0 -> 1.68.0
    - boost-timer    1.67.0 -> 1.68.0
    - boost-tokenizer 1.67.0 -> 1.68.0
    - boost-tti      1.67.0 -> 1.68.0
    - boost-tuple    1.67.0 -> 1.68.0
    - boost-type-erasure 1.67.0 -> 1.68.0
    - boost-type-index 1.67.0 -> 1.68.0
    - boost-type-traits 1.67.0 -> 1.68.0
    - boost-typeof   1.67.0 -> 1.68.0
    - boost-ublas    1.67.0 -> 1.68.0
    - boost-units    1.67.0 -> 1.68.0
    - boost-unordered 1.67.0 -> 1.68.0
    - boost-utility  1.67.0 -> 1.68.0
    - boost-uuid     1.67.0 -> 1.68.0
    - boost-variant  1.67.0 -> 1.68.0
    - boost-vmd      1.67.0 -> 1.68.0
    - boost-wave     1.67.0 -> 1.68.0
    - boost-winapi   1.67.0 -> 1.68.0
    - boost-xpressive 1.67.0 -> 1.68.0
    - botan          2.0.1 -> 2.8.0
    - breakpad       2018-04-17 -> 2018-09-18
    - brotli         1.0.2-3 -> 1.0.2-4
    - cairo          1.15.8-1 -> 1.15.8-3
    - cartographer   0.3.0-4 -> 0.3.0-5
    - catch2         2.2.2 -> 2.4.0
    - celero         2.1.0-2 -> 2.3.0-1
    - cgal           4.12 -> 4.13-1
    - chaiscript     6.0.0 -> 6.1.0
    - chakracore     1.8.4 -> 1.11.1-1
    - cimg           2.2.3 -> 2.3.6
    - clockutils     1.1.1-3651f232c27074c4ceead169e223edf5f00247c5-1 -> 1.1.1-3651f232c27074c4ceead169e223edf5f00247c5-2
    - cmark          0.28.3-1 -> 0.28.3-2
    - coolprop       6.1.0-3 -> 6.1.0-4
    - cpprestsdk     2.10.2-1 -> 2.10.6-1
    - crc32c         1.0.5 -> 1.0.5-1
    - cryptopp       6.1.0-2 -> 7.0.0
    - curl           7.60.0 -> 7.61.1-1
    - cxxopts        1.3.0 -> 2.1.0-1
    - dimcli         3.1.1-1 -> 3.1.1-2
    - directxmesh    may2018 -> aug2018
    - directxtex     may2018 -> aug2018b
    - directxtk      may2018 -> aug2018
    - discord-rpc    3.3.0 -> 3.3.0-1
    - dlib           19.10-1 -> 19.16
    - doctest        1.2.9 -> 2.0.0
    - double-conversion 3.0.0-2 -> 3.1.0
    - draco          1.2.5 -> 1.3.3
    - eastl          3.09.00 -> 3.12.01
    - ecm            5.40.0 -> 5.50.0
    - eigen3         3.3.4-2 -> 3.3.5
    - entt           2.5.0 -> 2.7.3
    - exiv2          2018-05-17 -> 2018-09-18
    - expat          2.2.5 -> 2.2.6
    - exprtk         2018.04.30-46877b6 -> 2018.09.30-9836f21
    - fastrtps       1.5.0 -> 1.5.0-1
    - fdk-aac        2018-05-17 -> 2018-07-08
    - flatbuffers    1.8.0-2 -> 1.9.0-2
    - fmt            4.1.0 -> 5.2.0
    - folly          2018.05.14.00 -> 2018.09.17.00
    - fontconfig     2.12.4-1 -> 2.12.4-7
    - forest         7.0.7 -> 9.0.5
    - freeglut       3.0.0-4 -> 3.0.0-5
    - freetype-gl    2018-02-25 -> 2018-09-18
    - gdal           2.3.0-1 -> 2.3.2
    - gdcm2          2.8.6 -> 2.8.7
    - geogram        1.6.0-1 -> 1.6.4
    - geos           3.6.2-3 -> 3.6.3-2
    - glbinding      2.1.1-3 -> 3.0.2-3
    - glfw3          3.2.1-2 -> 3.2.1-3
    - glib           2.52.3-9 -> 2.52.3-11
    - glm            0.9.8.5-1 -> 0.9.9.2
    - globjects      1.0.0-1 -> 1.1.0-2018-09-19
    - glslang        2018-03-02 -> 2018-03-02-1
    - google-cloud-cpp 0.1.0 -> 0.1.0-1
    - graphicsmagick 1.3.28 -> 1.3.30-1
    - graphite2      1.3.10 -> 1.3.12
    - grpc           1.10.1-2 -> 1.14.1
    - gtest          1.8.0-8 -> 1.8.0-9
    - guetzli        2017-09-02-cb5e4a86f69628-1 -> 2018-07-30
    - gumbo          0.10.1-1 -> 0.10.1-2
    - harfbuzz       1.7.6-1 -> 1.8.4-2
    - http-parser    2.7.1-3 -> 2.8.1
    - hwloc          1.11.7-2 -> 1.11.7-3
    - icu            61.1-1 -> 61.1-4
    - imgui          1.60 -> 1.65
    - json-dto       0.2.5 -> 0.2.6
    - jsonnet        2018-05-17 -> 2018-09-18
    - kf5plotting    5.37.0 -> 5.50.0
    - lcms           2.8-4 -> 2.8-5
    - leptonica      1.74.4-3 -> 1.76.0
    - libarchive     3.3.2-1 -> 3.3.3-2
    - libflac        1.3.2-5 -> 1.3.2-6
    - libgeotiff     1.4.2-3 -> 1.4.2-4
    - libgit2        0.26.0 -> 0.27.4-2
    - libgo          2.7 -> 2.8-2
    - liblzma        5.2.3-2 -> 5.2.4
    - libmariadb     3.0.2 -> 3.0.2-1
    - libmysql       8.0.4-2 -> 8.0.4-3
    - libodb         2.4.0-2 -> 2.4.0-3
    - libodb-mysql   2.4.0-1 -> 2.4.0-2
    - libp7-baical   4.4-2 -> 4.4-3
    - libpng         1.6.34-3 -> 1.6.35
    - libpqxx        6.0.0 -> 6.0.0-1
    - libraw         0.18.2-5 -> 0.19.0-1
    - libsndfile     1.0.29-6830c42-3 -> 1.0.29-6830c42-5
    - libssh         0.7.5-4 -> 0.7.6
    - libssh2        1.8.0-3 -> 1.8.0-4
    - libuv          1.20.3-2 -> 1.23.0
    - libvorbis      1.3.5-143caf4-3 -> 1.3.6-112d3bd-1
    - libwebsockets  3.0.0 -> 3.0.1
    - libzip         rel-1-5-1 -> rel-1-5-1-vcpkg1
    - live555        2018.02.28 -> latest
    - llvm           6.0.0-1 -> 7.0.0
    - log4cplus      REL_2_0_0-RC2 -> REL_2_0_1
    - luasocket      2018-02-25 -> 2018-09-18
    - lz4            1.8.2 -> 1.8.3
    - mbedtls        2.6.1 -> 2.13.1
    - mongo-cxx-driver 3.1.1-2 -> 3.1.1-3
    - monkeys-audio  4.3.3 -> 4.3.3-1
    - mosquitto      1.4.15 -> 1.5.0
    - ms-gsl         2018-05-17 -> 2018-09-18
    - mujs           2018-05-17 -> 2018-07-30
    - nana           1.5.5 -> 1.6.2
    - nanodbc        2.12.4-1 -> 2.12.4-2
    - nanomsg        1.1.2 -> 1.1.4
    - nghttp2        1.30.0-1 -> 1.33.0
    - nlohmann-json  3.1.2 -> 3.3.0
    - nlopt          2.4.2-c43afa08d~vcpkg1-1 -> 2.4.2-1226c127
    - nuklear        2018-05-17 -> 2018-09-18
    - octomap        cefed0c1d79afafa5aeb05273cf1246b093b771c-2 -> cefed0c1d79afafa5aeb05273cf1246b093b771c-3
    - openal-soft    1.18.2-2 -> 1.19.0
    - openimageio    Release-1.9.2dev -> Release-1.8.13
    - openmama       6.2.1-a5a93a24d2f89a0def0145552c8cd4a53c69e2de -> 6.2.2
    - openmesh       6.3 -> 7.0
    - openssl        1.0.2o-2 -> 0
    - openvr         1.0.15 -> 1.0.16
    - opusfile       0.9-1 -> 0.11-1
    - osg            3.5.6-2 -> 3.6.2
    - osgearth       2.9 -> 2.9-1
    - paho-mqtt      1.2.0-3 -> 1.2.1
    - parson         2018-05-17 -> 2018-09-18
    - pcl            1.8.1-10 -> 1.8.1-12
    - pdal           1.7.1-2 -> 1.7.1-3
    - pdcurses       3.4-1 -> 3.6
    - picosha2       2018-02-25 -> 2018-07-30
    - pixman         0.34.0-2 -> 0.34.0-4
    - plibsys        0.0.3-1 -> 0.0.4-1
    - pmdk           1.4-2 -> 1.4.2
    - poco           1.9.0 -> 1.9.0-1
    - podofo         0.9.5-2 -> 0.9.6
    - protobuf       3.5.1-4 -> 3.6.1-4
    - pybind11       2.2.1 -> 2.2.3-1
    - python3        3.6.4-1 -> 3.6.4-2
    - qpid-proton    0.18.1 -> 0.24.0
    - qt5-base       5.9.2-6 -> 5.9.2-7
    - qt5-modularscripts 3 -> 4
    - re2            2018-05-17 -> 2018-09-18
    - realsense2     2.10.4 -> 2.16.1
    - restinio       0.4.5.1 -> 0.4.8
    - rocksdb        5.13.1 -> 5.14.2
    - rs-core-lib    2018-05-17 -> 2018-09-18
    - sciter         4.1.7 -> 4.2.2
    - sdl2-image     2.0.2-1 -> 2.0.2-3
    - sfgui          0.3.2-1 -> 0.3.2-2
    - sfml           2.4.2-3 -> 2.5.0-2
    - shaderc        12fb656ab20ea9aa06e7084a74e5ff832b7ce2da-1 -> 12fb656ab20ea9aa06e7084a74e5ff832b7ce2da-2
    - signalrclient  1.0.0-beta1-3 -> 1.0.0-beta1-4
    - sobjectizer    5.5.22 -> 5.5.22.1
    - soci           2016.10.22-1 -> 3.2.3-1
    - spdlog         0.16.3 -> 1.0.0
    - sqlite-modern-cpp 3.2 -> 3.2-e2248fa
    - sqlite-orm     1.1 -> 1.2
    - sqlite3        3.23.1-1 -> 3.24.0-1
    - string-theory  1.7 -> 2.1
    - strtk          2018.05.07-48c9554 -> 2018.09.30-b887974
    - sundials       2.7.0-1 -> 3.1.1
    - tbb            2018_U3 -> 2018_U5-4
    - tesseract      3.05.01-3 -> 3.05.02
    - thor           2.0-1 -> 2.0-2
    - thrift         2018-05-17 -> 2018-09-18
    - tiff           4.0.9 -> 4.0.9-4
    - tiny-dnn       2018-03-13 -> 2018-09-18
    - torch-th       20180131-89ede3ba90c906a8ec6b9a0f4bef188ba5bb2fd8-2 -> 2018-07-03
    - unicorn        2018-05-17 -> 2018-09-18
    - unicorn-lib    2018-05-17 -> 2018-09-18
    - uriparser      0.8.5 -> 0.8.6
    - wt             4.0.3 -> 4.0.4
    - x264           152-e9a5903edf8ca59-1 -> 157-303c484ec828ed0
    - xlnt           1.2.0-1 -> 1.3.0-1
    - yaml-cpp       0.6.2 -> 0.6.2-2
    - yara           e3439e4ead4ed5d3b75a0b46eaf15ddda2110bb9 -> e3439e4ead4ed5d3b75a0b46eaf15ddda2110bb9-1
    - yoga           1.8.0-1 -> 1.9.0
    - zeromq         2018-05-17 -> 2018-09-18
  * Change version format of the `vcpkg` tool to a date
  * Improve handling of ctrl-c inside `install` or `build`
  * Improvements in `vcpkg edit`:
    - Fix console blocking when using VSCode and no other instance of VSCode is running
    - `--all` option now opens package folders
    - Now checks the default user-wide installation dir of VSCode (in addition to system-wide)
  * `vcpkg env`: add argument to execute a command in the environment of the selected triplet
    - e.g. `vcpkg env --triplet x64-windows "cl.exe"`
  * Survey message changes:
    - Survey message may pop-up only in `install`, `remove`, `export`, `update`. This prevents issues with parsing the output of other more script-oriented commands
    - Adjust the survey frequency to 6 months, with an additional once after 10 days of use
    - Improve metrics performance on Windows
  * Fix OSX build for old gcc versions
  * Fix handling of symlink when installing or removing a library
  * Use -fPIC in all builds to enable mixing static libs with shared objects.
  * Move graph options to `vcpkg depend-info` (from `vcpkg search`)
  * Add `vcpkg_from_gitlab` function
  * Documentation improvements in various `vcpkg_*` cmake functions

-- vcpkg team <vcpkg@microsoft.com>  SAT, 20 Oct 2018 17:00:00 -0800


vcpkg (0.0.113)
--------------
  * Add ports:
    - json-dto       0.2.5
    - keystone       0.9.1
    - osgearth       2.9
    - pdal           1.7.1-2
    - sdl2pp         0.16.0-1
  * Update ports:
    - args           2018-02-23 -> 2018-05-17
    - aws-sdk-cpp    1.4.40 -> 1.4.52
    - chakracore     1.8.3 -> 1.8.4
    - cimg           2.2.2 -> 2.2.3
    - curl           7_59_0-2 -> 7.60.0
    - directxmesh    apr2018 -> may2018
    - directxtex     apr2018 -> may2018
    - directxtk      apr2018 -> may2018
    - doctest        1.2.8 -> 1.2.9
    - entt           2.4.2-1 -> 2.5.0
    - exiv2          2018-04-25 -> 2018-05-17
    - fdk-aac        2018-03-07 -> 2018-05-17
    - forest         7.0.6 -> 7.0.7
    - gdal           2.2.2-1 -> 2.3.0-1
    - grpc           1.10.1-1 -> 1.10.1-2
    - jsonnet        2018-05-01 -> 2018-05-17
    - libuv          1.20.2 -> 1.20.3-2
    - libwebsockets  2.4.2 -> 3.0.0
    - lodepng        2018-02-25 -> 2018-05-17
    - mpg123         1.25.8-4 -> 1.25.8-5
    - ms-gsl         2018-05-01 -> 2018-05-17
    - mujs           2018-05-01 -> 2018-05-17
    - nuklear        2018-04-25 -> 2018-05-17
    - opus           1.2.1 -> 1.2.1-1
    - parson         2018-04-17 -> 2018-05-17
    - pmdk           1.4-1 -> 1.4-2
    - podofo         0.9.5-1 -> 0.9.5-2
    - re2            2018-05-01 -> 2018-05-17
    - rocksdb        5.12.4 -> 5.13.1
    - rs-core-lib    2018-05-01 -> 2018-05-17
    - sdl2-mixer     2.0.2-2 -> 2.0.2-4
    - thrift         2018-05-01 -> 2018-05-17
    - unicorn        2018-04-25 -> 2018-05-17
    - unicorn-lib    2018-05-01 -> 2018-05-17
    - uwebsockets    0.14.8-1 -> 0.14.8-2
    - wtl            10.0 -> 10.0-1
    - zeromq         2018-05-01 -> 2018-05-17
  * `vcpkg` no longer calls `powershell` from `cmake`.
    - This completes the fix for the issue where `vcpkg.exe` would change the console's font when invoking `powershell`.
    - `Powershell` is no longer called other than for bootstrap and powershell integration for tab-completion.

-- vcpkg team <vcpkg@microsoft.com>  SAT, 16 May 2018 19:30:00 -0800


vcpkg (0.0.112)
--------------
  * Add ports:
    - robin-map      0.2.0
  * Update ports:
    - abseil         2018-04-25-1 -> 2018-05-01-1
    - ace            6.4.7 -> 6.4.8
    - aws-sdk-cpp    1.4.38 -> 1.4.40
    - azure-storage-cpp 3.2.1 -> 4.0.0
    - blosc          1.13.5 -> 1.13.5-1
    - boost-modular-build-helper 2018-04-16-4 -> 2018-05-14
    - brotli         1.0.2-2 -> 1.0.2-3
    - catch-classic  1.12.1 -> 1.12.2
    - folly          2018.04.23.00 -> 2018.05.14.00
    - jsonnet        2018-04-25 -> 2018-05-01
    - ms-gsl         2018-04-25 -> 2018-05-01
    - mujs           25821e6d74fab5fcc200fe5e818362e03e114428 -> 2018-05-01
    - openimageio    1.8.10 -> Release-1.9.2dev
    - openvr         1.0.14 -> 1.0.15
    - protobuf       3.5.1-3 -> 3.5.1-4
    - re2            2018-03-17 -> 2018-05-01
    - rs-core-lib    2018-04-25 -> 2018-05-01
    - sol            2.20.0 -> 2.20.0-1
    - thrift         2018-04-25 -> 2018-05-01
    - unicorn-lib    2018-04-09 -> 2018-05-01
    - zeromq         2018-04-25 -> 2018-05-01
  * `vcpkg` no longer calls powershell for downloading/extracting and detecting Visual Studio.
    - This also fixes an issue where `vcpkg.exe` would change the console's font when invoking `powershell`.

-- vcpkg team <vcpkg@microsoft.com>  WED, 16 May 2018 19:00:00 -0800


vcpkg (0.0.111)
--------------
  * Add ports:
    - cmark          0.28.3-1
    - inja           1.0.0
    - libgo          2.7
    - range-v3-vs2015 20151130-vcpkg5
    - restinio       0.4.5.1
    - treehopper     1.11.3-1
    - yajl           2.1.0-1
    - yato           1.0-1
  * Update ports:
    - abseil         2018-04-12 -> 2018-04-25-1
    - alembic        1.7.7 -> 1.7.8
    - aws-sdk-cpp    1.4.33 -> 1.4.38
    - bigint         2010.04.30-1 -> 2010.04.30-2
    - box2d          2.3.1-374664b -> 2.3.1-374664b-1
    - brotli         1.0.2-1 -> 1.0.2-2
    - cgal           4.11.1 -> 4.12
    - corrade        2018.02-1 -> 2018.04-1
    - directxmesh    feb2018-eb751e0b631b05aa25c36c08e7d6bbf09f5e94a9 -> apr2018
    - directxtex     feb2018b -> apr2018
    - directxtk      feb2018 -> apr2018
    - discord-rpc    3.2.0 -> 3.3.0
    - exiv2          2018-04-12 -> 2018-04-25
    - exprtk         2018.01.01-f32d2b4 -> 2018.04.30-46877b6
    - folly          2018.04.16.00 -> 2018.04.23.00
    - freeglut       3.0.0-3 -> 3.0.0-4
    - gainput        1.0.0 -> 1.0.0-1
    - geos           3.6.2-2 -> 3.6.2-3
    - http-parser    2.7.1-2 -> 2.7.1-3
    - imgui          1.53 -> 1.60
    - ismrmrd        1.3.2-1 -> 1.3.2-2
    - jsonnet        2018-04-17 -> 2018-04-25
    - leveldb        2017-10-25-8b1cd3753b184341e837b30383832645135d3d73-1 -> 2017-10-25-8b1cd3753b184341e837b30383832645135d3d73-2
    - libflac        1.3.2-4 -> 1.3.2-5
    - libqrencode    4.0.0-1 -> 4.0.0-2
    - libuv          1.20.0 -> 1.20.2
    - libxmlpp       2.40.1-1 -> 2.40.1-2
    - llvm           6.0.0 -> 6.0.0-1
    - magnum         2018.02-2 -> 2018.04-1
    - magnum-extras  2018.02-2 -> 2018.04-1
    - magnum-integration 2018.02-1 -> 2018.04-1
    - magnum-plugins 2018.02-2 -> 2018.04-1
    - ms-gsl         2018-03-17 -> 2018-04-25
    - nuklear        2018-04-17 -> 2018-04-25
    - openal-soft    1.18.2-1 -> 1.18.2-2
    - physfs         2.0.3-2 -> 3.0.1
    - poco           1.8.1-1 -> 1.9.0
    - python3        3.6.4 -> 3.6.4-1
    - quirc          1.0-1 -> 1.0-2
    - range-v3       20151130-vcpkg5 -> 0.3.5
    - rapidjson      1.1.0 -> 1.1.0-1
    - realsense2     2.10.1-1 -> 2.10.4
    - rhash          1.3.5-1 -> 1.3.6
    - rocksdb        5.12.2 -> 5.12.4
    - rs-core-lib    2018-04-12 -> 2018-04-25
    - sciter         4.1.5 -> 4.1.7
    - sfml           2.4.2-2 -> 2.4.2-3
    - sobjectizer    5.5.21 -> 5.5.22
    - sol            2.19.5 -> 2.20.0
    - sqlite3        3.23.0 -> 3.23.1-1
    - strtk          2018.01.01-5579ed1 -> 2018.05.07-48c9554
    - thrift         2018-04-17 -> 2018-04-25
    - unicorn        2018-03-20 -> 2018-04-25
    - uwebsockets    0.14.7-1 -> 0.14.8-1
    - vlpp           0.9.3.1 -> 0.9.3.1-1
    - zeromq         2018-04-17 -> 2018-04-25
    - zstd           1.3.3 -> 1.3.4
  * Add clean patching for vcpkg_from_github()
    - `vcpkg_from_github()` now takes a PATCHES argument (see the azure-storage-cpp [portfile](ports\azure-storage-cpp\portfile.cmake) as an example)
    - A unique directory name is derived from the source hash and the patch hashes
    - Modifying the patches would previously cause the new patches to fail to apply if sources with a previous version of the patches were present in the buildtrees. This is no longer the case.
  * Fix various cross-platform issues

-- vcpkg team <vcpkg@microsoft.com>  FRI, 11 May 2018 21:45:00 -0800


vcpkg (0.0.110)
--------------
  * `vcpkg` is now available for Linux and MacOS. More information [here](https://blogs.msdn.microsoft.com/vcblog/2018/04/24/announcing-a-single-c-library-manager-for-linux-macos-and-windows-vcpkg/).

-- vcpkg team <vcpkg@microsoft.com>  TUE, 24 Apr 2018 10:30:00 -0800


vcpkg (0.0.109)
--------------
  * Add ports:
    - boost-container-hash 1.67.0
    - boost-contract 1.67.0
    - boost-hof      1.67.0
    - fastrtps       1.5.0
    - fluidsynth     1.1.10
    - liblinear      2.20
    - libxmlpp       2.40.1-1
    - utf8h          841cb2deb8eb806e73fff0e1f43a11fca4f5da45
    - vxl            20180414-7a130cf-1
  * Update ports:
    - abseil         2018-04-05 -> 2018-04-12
    - aws-sdk-cpp    1.4.30-1 -> 1.4.33
    - azure-c-shared-utility 1.1.2 -> 1.1.3
    - azure-iot-sdk-c 1.2.2 -> 1.2.3
    - azure-uamqp-c  1.2.2 -> 1.2.3
    - azure-umqtt-c  1.1.2 -> 1.1.3
    - benchmark      1.3.0-1 -> 1.4.0
    - boost          1.66.0 -> 1.67.0
    - boost-*        1.66.0 -> 1.67.0
    - breakpad       2018-04-05 -> 2018-04-17
    - cartographer   0.3.0-3 -> 0.3.0-4
    - catch2         2.2.1-1 -> 2.2.2
    - celero         2.1.0-1 -> 2.1.0-2
    - chakracore     1.8.2 -> 1.8.3
    - cimg           221 -> 2.2.2
    - cppzmq         4.2.2 -> 4.2.2-1
    - date           2.4 -> 2.4.1
    - directxmesh    feb2018 -> feb2018-eb751e0b631b05aa25c36c08e7d6bbf09f5e94a9
    - exiv2          2018-04-05 -> 2018-04-12
    - folly          2018.03.19.00-2 -> 2018.04.16.00
    - forest         7.0.1 -> 7.0.6
    - gettext        0.19-2 -> 0.19-4
    - glib           2.52.3-2 -> 2.52.3-9
    - glibmm         2.52.1 -> 2.52.1-7
    - graphicsmagick 1.3.26-2 -> 1.3.28
    - grpc           1.10.1 -> 1.10.1-1
    - icu            59.1-1 -> 61.1-1
    - jsonnet        2018-03-17 -> 2018-04-17
    - libiconv       1.15-3 -> 1.15-4
    - libsigcpp      2.10 -> 2.10-1
    - libtorrent     1.1.6 -> 1.1.6-1
    - libuuid        1.0.3 -> 1.0.3-1
    - libzip         rel-1-5-0 -> rel-1-5-1
    - llvm           5.0.1 -> 6.0.0
    - magnum         2018.02-1 -> 2018.02-2
    - magnum-plugins 2018.02-1 -> 2018.02-2
    - nuklear        2018-04-05 -> 2018-04-17
    - openssl        1.0.2o-1 -> 1.0.2o-2
    - openvr         1.0.13 -> 1.0.14
    - parson         2018-03-23 -> 2018-04-17
    - protobuf       3.5.1-1 -> 3.5.1-3
    - pugixml        1.8.1-3 -> 1.9-1
    - realsense2     2.10.1 -> 2.10.1-1
    - rs-core-lib    2018-04-05 -> 2018-04-12
    - sol            2.18.7 -> 2.19.5
    - sqlite3        3.21.0-1 -> 3.23.0
    - thrift         2018-04-05 -> 2018-04-17
    - tinyxml2       6.0.0-2 -> 6.2.0
    - unicorn-lib    2018-03-13 -> 2018-04-09
    - uwebsockets    0.14.6-1 -> 0.14.7-1
    - wt             4.0.2 -> 4.0.3
    - x264           152-e9a5903edf8ca59 -> 152-e9a5903edf8ca59-1
    - yoga           1.7.0-1 -> 1.8.0-1
    - zeromq         2018-04-05 -> 2018-04-17
  * Bump required version & auto-downloaded version of `nuget` to 4.6.2
  * Bump required version & auto-downloaded version of `vswhere` to 2.4.1
  * `vcpkg edit` improvements
    - '--all' now will open both the buildtrees dir and the package dir
    - Allow multiple ports to be specified as arguments

-- vcpkg team <vcpkg@microsoft.com>  MON, 23 Apr 2018 19:00:00 -0800


vcpkg (0.0.108)
--------------
  * Add ports:
    - google-cloud-cpp 0.1.0
    - mhook          2.5.1-1
    - mosquitto      1.4.15
    - pmdk           1.4-1 (renamed from nvml)
  * Remove Ports:
    - nvml           1.3-0 (renamed to pmdk)
  * Update ports:
    - abseil         2018-03-23 -> 2018-04-05
    - asio           1.12.0-1 -> 1.12.0-2
    - aws-sdk-cpp    1.4.21 -> 1.4.30-1
    - azure-c-shared-utility 1.0.0-pre-release-1.0.9 -> 1.1.2
    - azure-iot-sdk-c 1.0.0-pre-release-1.0.9 -> 1.2.2
    - azure-uamqp-c  1.0.0-pre-release-1.0.9 -> 1.2.2
    - azure-umqtt-c  1.0.0-pre-release-1.0.9 -> 1.1.2
    - breakpad       2018-03-13 -> 2018-04-05
    - clara          2018-03-23 -> 2018-04-02
    - cryptopp       5.6.5-1 -> 6.1.0-2
    - discord-rpc    3.1.0 -> 3.2.0
    - dlib           19.10 -> 19.10-1
    - eastl          3.08.00 -> 3.09.00
    - exiv2          2018-03-23 -> 2018-04-05
    - folly          2017.11.27.00-3 -> 2018.03.19.00-2
    - forest         4.5.0 -> 7.0.1
    - gdcm2          2.8.5 -> 2.8.6
    - grpc           1.10.0 -> 1.10.1
    - gtest          1.8.0-7 -> 1.8.0-8
    - libiconv       1.15-2 -> 1.15-3
    - libuv          1.19.2 -> 1.20.0
    - libvpx         1.6.1-2 -> 1.7.0
    - libxml2        2.9.4-4 -> 2.9.4-5
    - nuklear        2018-03-23 -> 2018-04-05
    - openimageio    1.8.9 -> 1.8.10
    - openssl        1.0.2n-3 -> 1.0.2o-1
    - qt5-base       5.9.2-5 -> 5.9.2-6
    - qt5-modularscripts 2 -> 3
    - qwt            6.1.3-4 -> 6.1.3-5
    - recast         1.5.1 -> 1.5.1-1
    - rocksdb        5.11.3 -> 5.12.2
    - rs-core-lib    2018-03-17 -> 2018-04-05
    - sciter         4.1.4 -> 4.1.5
    - tbb            2018_U2 -> 2018_U3
    - tesseract      3.05.01-2 -> 3.05.01-3
    - theia          0.7-d15154a-1 -> 0.7-d15154a-3
    - thrift         2018-03-23 -> 2018-04-05
    - unrar          5.5.8 -> 5.5.8-1
    - yoga           1.7.0 -> 1.7.0-1
    - zeromq         2018-03-23 -> 2018-04-05
  * `vcpkg.cmake`: Remove detection for Windows SDK. Let `cmake` detect it instead.
  * Rework `vcpkgTools.xml`.
    - `<requiredVersion>` renamed to `<version>`
    - `<archiveRelativePath>` renamed `<archiveName>`
    - `<sha256>` changed to `<sha512>`
    - `<tool>` tags now specify an `os="x"` property
    - The version of the tools list (i.e. `<tools version="1">`) is now verified by `vcpkg.exe`.
  * Use [7zip](https://www.7-zip.org/) to extract vcpkg tools defined in `vcpkgTools.xml`.
  * Use [aria2](https://aria2.github.io/) to download vcpkg tools defined in `vcpkgTools.xml`.
    - The experimental flag `vcpkg install <port> --x-use-aria2` allows you to use `aria2` for other downloads as well.
  * `vckg hash` improvements

-- vcpkg team <vcpkg@microsoft.com>  FRI, 06 Apr 2018 19:30:00 -0800


vcpkg (0.0.107)
--------------
  * Add ports:
    - azmq           1.0.2
    - azure-c-shared-utility 1.0.0-pre-release-1.0.9
    - azure-iot-sdk-c 1.0.0-pre-release-1.0.9
    - azure-uamqp-c  1.0.0-pre-release-1.0.9
    - azure-uhttp-c  2018-02-09
    - azure-umqtt-c  1.0.0-pre-release-1.0.9
    - bitserializer  0.7
    - caf            0.15.7
    - fmem           c-libs-2ccee3d2fb
    - gherkin-c      c-libs-e63e83104b
    - librsync       2.0.2
    - libuuid        1.0.3
    - mpark-variant  1.3.0
    - nanomsg        1.1.2
    - nvml           1.3-0
    - nvtt           2.1.0
    - openvpn3       2018-03-21
    - parson         2018-03-23
    - plplot         5.13.0-1
    - sqlite-orm     1.1
    - tap-windows6   9.21.2-0e30f5c
  * Update ports:
    - abseil         2018-03-17 -> 2018-03-23
    - alembic        1.7.6 -> 1.7.7
    - asio           1.12.0 -> 1.12.0-1
    - aubio          0.4.6-1 -> 0.4.6-2
    - aws-sdk-cpp    1.3.58 -> 1.4.21
    - catch2         2.2.1 -> 2.2.1-1
    - ccfits         2.5-1 -> 2.5-2
    - ceres          1.13.0-4 -> 1.14.0-1
    - cfitsio        3.410-1 -> 3.410-2
    - clara          2018-03-11 -> 2018-03-23
    - cpprestsdk     2.10.2 -> 2.10.2-1
    - discord-rpc    3.0.0 -> 3.1.0
    - dlib           19.9-1 -> 19.10
    - eastl          3.07.02 -> 3.08.00
    - exiv2          2018-03-17 -> 2018-03-23
    - ffmpeg         3.3.3-4 -> 3.3.3-5
    - gdcm2          2.8.4 -> 2.8.5
    - harfbuzz       1.7.6 -> 1.7.6-1
    - hpx            1.0.0-8 -> 1.1.0-1
    - lcm            1.3.95 -> 1.3.95-1
    - libpq          9.6.1-1 -> 9.6.1-4
    - libvpx         1.6.1-1 -> 1.6.1-2
    - mpg123         1.25.8-2 -> 1.25.8-4
    - nuklear        2018-03-17 -> 2018-03-23
    - openssl        1.0.2n-2 -> 1.0.2n-3
    - paho-mqtt      1.2.0-2 -> 1.2.0-3
    - plog           1.1.3 -> 1.1.4
    - qt5-quickcontrols 5.9.2-0 -> 5.9.2-1
    - qt5-quickcontrols2 5.9.2-0 -> 5.9.2-1
    - sciter         4.1.3 -> 4.1.4
    - shapelib       1.4.1 -> 1.4.1-1
    - signalrclient  1.0.0-beta1-2 -> 1.0.0-beta1-3
    - soundtouch     2.0.0 -> 2.0.0-1
    - thrift         2018-03-17 -> 2018-03-23
    - unicorn        2018-03-13 -> 2018-03-20
    - zeromq         2018-03-17 -> 2018-03-23

-- vcpkg team <vcpkg@microsoft.com>  TUE, 27 Mar 2018 22:00:00 -0800


vcpkg (0.0.106)
--------------
  * Add ports:
    - armadillo      8.400.0-1
    - boost-modular-build-helper 2
    - clblas         2.12-1
    - clfft          2.12.2
    - entt           2.4.2-1
    - fastcdr        1.0.6-1
    - gamma          gamma-2018-01-27
    - gl3w           8f7f459d
    - graphite2      1.3.10
    - ismrmrd        1.3.2-1
    - kealib         1.4.7-1
    - lcm            1.3.95
    - libcds         2.3.2
    - monkeys-audio  4.3.3
    - msix           1.0
    - nmslib         1.7.2
    - opencl         2.2 (2017.07.18)
    - openmesh       6.3
    - quirc          1.0-1
    - shogun         6.1.3
    - x264           152-e9a5903edf8ca59
    - x265           2.7-1
  * Update ports:
    - abseil         2018-2-5 -> 2018-03-17
    - ace            6.4.6 -> 6.4.7
    - alembic        1.7.5 -> 1.7.6
    - args           d8905de -> 2018-02-23
    - asio           1.10.8-1 -> 1.12.0
    - atk            2.24.0-1 -> 2.24.0-2
    - avro-c         1.8.2 -> 1.8.2-1
    - azure-storage-cpp 3.0.0-4 -> 3.2.1
    - benchmark      1.3.0 -> 1.3.0-1
    - boost-build    1.66.0-5 -> 1.66.0-8
    - breakpad       2018-2-19 -> 2018-03-13
    - butteraugli    2017-09-02-8c60a2aefa19adb-1 -> 2018-02-25
    - c-ares         1.13.0-1 -> cares-1_14_0
    - catch-classic  1.12.0 -> 1.12.1
    - catch2         2.1.2 -> 2.2.1
    - cctz           2.1 -> 2.2
    - cgal           4.11-3 -> 4.11.1
    - chakracore     1.7.4 -> 1.8.2
    - chmlib         0.40-1 -> 0.40-2
    - cimg           2.1.8 -> 221
    - clara          2017-07-20-9661f2b4a50895d52ebb4c59382785a2b416c310 -> 2018-03-11
    - console-bridge 0.3.2-2 -> 0.3.2-3
    - coolprop       6.1.0-2 -> 6.1.0-3
    - cpp-redis      4.3.0 -> 4.3.1
    - cpr            1.3.0-1 -> 1.3.0-3
    - curl           7.58.0-1 -> 7_59_0-2
    - devil          1.8.0-1 -> 1.8.0-2
    - directxmesh    dec2017 -> feb2018
    - directxtex     dec2017 -> feb2018b
    - directxtk      dec2017 -> feb2018
    - dirent         2017-06-23-5c7194c2fe2c68c1a8212712c0b4b6195382d27d -> 1.23.1
    - discord-rpc    2.1.0 -> 3.0.0
    - doctest        1.2.6 -> 1.2.8
    - eastl          3.05.08 -> 3.07.02
    - evpp           0.6.1-1 -> 0.7.0
    - exiv2          8f5b795eaa4bc414d2d6041c1dbd1a7f7bf1fc99 -> 2018-03-17
    - fdk-aac        2017-11-02-1e351 -> 2018-03-07
    - ffmpeg         3.3.3-2 -> 3.3.3-4
    - freetype       2.8.1-1 -> 2.8.1-3
    - freetype-gl    2017-10-9-82fb152a74f01b1483ac80d15935fbdfaf3ed836 -> 2018-02-25
    - freexl         1.0.4 -> 1.0.4-1
    - g2o            20170730_git-2 -> 20170730_git-3
    - gdal           2.2.2 -> 2.2.2-1
    - gdcm2          2.8.3 -> 2.8.4
    - geogram        1.4.9-1 -> 1.6.0-1
    - gflags         2.2.1-1 -> 2.2.1-3
    - glib           2.52.3-1 -> 2.52.3-2
    - glslang        3a21c880500eac21cdf79bef5b80f970a55ac6af-1 -> 2018-03-02
    - grpc           1.8.3 -> 1.10.0
    - gsl            2.4-2 -> 2.4-3
    - gsl-lite       0.26.0 -> 0.28.0
    - gtest          1.8.0-6 -> 1.8.0-7
    - halide         release_2017_10_30 -> release_2018_02_15
    - harfbuzz       1.7.4 -> 1.7.6
    - ilmbase        2.2.0-1 -> 2.2.1-1
    - jansson        2.11 -> 2.11-2
    - jsoncpp        1.8.1-1 -> 1.8.4
    - jsonnet        2017-09-02-11cf9fa9f2fe8acbb14b096316006082564ca580 -> 2018-03-17
    - leptonica      1.74.4-2 -> 1.74.4-3
    - libgeotiff     1.4.2-2 -> 1.4.2-3
    - libiconv       1.15-1 -> 1.15-2
    - libjpeg-turbo  1.5.3 -> 1.5.3-1
    - libmysql       5.7.17-3 -> 8.0.4-2
    - libpng         1.6.34-2 -> 1.6.34-3
    - librtmp        2.4 -> 2.4-1
    - libsndfile     1.0.29-6830c42-2 -> 1.0.29-6830c42-3
    - libsodium      1.0.15-1 -> 1.0.16-1
    - libspatialite  4.3.0a-1 -> 4.3.0a-2
    - libssh         0.7.5-1 -> 0.7.5-4
    - libuv          1.18.0 -> 1.19.2
    - libwebp        0.6.1-1 -> 0.6.1-2
    - libwebsockets  2.4.1 -> 2.4.2
    - libxml2        2.9.4-2 -> 2.9.4-4
    - libzip         1.4.0 -> rel-1-5-0
    - live555        2018.01.29 -> 2018.02.28
    - lodepng        2017-09-01-8a0f16afe74a6a-1 -> 2018-02-25
    - luasocket      2017.05.25.5a17f79b0301f0a1b4c7f1c73388757a7e2ed309 -> 2018-02-25
    - lz4            1.8.1.2 -> 1.8.1.2-1
    - magnum-extras  2018.02-1 -> 2018.02-2
    - matio          1.5.10-2 -> 1.5.12
    - mman           git-f5ff813 -> git-f5ff813-2
    - ms-gsl         20171204-9d65e74400976b3509833f49b16d401600c7317d -> 2018-03-17
    - msinttypes     2017-06-26-f9e7c5758ed9e3b9f4b2394de1881c704dd79de0 -> 2018-02-25
    - msmpi          8.1 -> 9.0
    - nlohmann-json  3.1.0 -> 3.1.2
    - nuklear        2017-06-15-5c7194c2fe2c68c1a8212712c0b4b6195382d27d -> 2018-03-17
    - ogre           1.10.9-2 -> 1.10.11
    - opencv         3.4.0-3 -> 3.4.1
    - openexr        2.2.0-1 -> 2.2.1-1
    - openimageio    1.7.15-2 -> 1.8.9
    - openjpeg       2.2.0-1 -> 2.3.0
    - pcl            1.8.1-9 -> 1.8.1-10
    - picosha2       2017-09-01-c5ff159b6 -> 2018-02-25
    - piex           2017-09-01-473434f2dd974978b-1 -> 2018-03-13
    - protobuf       3.5.1 -> 3.5.1-1
    - qt5-modularscripts 1 -> 2
    - re2            2017-12-01-1 -> 2018-03-17
    - readosm        1.1.0 -> 1.1.0-1
    - realsense2     2.10.0 -> 2.10.1
    - rocksdb        2017-06-28-18c63af6ef2b9f014c404b88488ae52e6fead03c-1 -> 5.11.3
    - rs-core-lib    commit-1ed2dadbda3977b13e5e83cc1f3eeca76b36ebe5 -> 2018-03-17
    - rttr           0.9.5-1 -> 0.9.5-2
    - scintilla      3.7.6 -> 4.0.3
    - sdl2           2.0.7-4 -> 2.0.8-1
    - snappy         1.1.7-1 -> 1.1.7-2
    - spatialite-tools 4.3.0 -> 4.3.0-1
    - spdlog         0.14.0-1 -> 0.16.3
    - spirv-tools    2017.1-dev-7e2d26c77b606b21af839b37fd21381c4a669f23-1 -> 2018.1-1
    - sqlite3        3.21.0 -> 3.21.0-1
    - stb            20170724-9d9f75e -> 2018-03-02
    - thrift         20172805-72ca60debae1d9fb35d9f0085118873669006d7f-2 -> 2018-03-17
    - tiny-dnn       2017-10-09-dd906fed8c8aff8dc837657c42f9d55f8b793b0e -> 2018-03-13
    - tinyxml2       6.0.0 -> 6.0.0-2
    - torch-th       20180131-89ede3ba90c906a8ec6b9a0f4bef188ba5bb2fd8-1 -> 20180131-89ede3ba90c906a8ec6b9a0f4bef188ba5bb2fd8-2
    - unicorn        2017-12-06-bc34c36eaeca0f4fc672015d24ce3efbcc81d6e4-1 -> 2018-03-13
    - unicorn-lib    commit-3ffa7fe69a1d0c37fb52a4af61380c5fd84fa5aa -> 2018-03-13
    - uwebsockets    0.14.4-1 -> 0.14.6-1
    - wt             3.3.7-4 -> 4.0.2
    - wtl            9.1 -> 10.0
    - wxwidgets      3.1.0-1 -> 3.1.1
    - yaml-cpp       0.5.4-rc-2 -> 0.6.2
    - zeromq         20170908-18498f620f0f6d4076981ea16eb5760fe4d28dc2-2 -> 2018-03-17
    - zziplib        0.13.62-1 -> 0.13.69
  * Use TLS 1.2 for downloads.
  * Tools used by `vcpkg` (`git`, `cmake` etc) are now specified in `scripts\vcpkgTools.xml`.
    - Add `7zip`
  * Fix various bugs regarding feature packages. Affects `install`, `upgrade` and `export`.
  * `vcpkg hash`: Fix bug with whitespace in path.
  * Visual Studio detection now properly identifies legacy versions (VS2015).
  * Windows SDK detection no longer fails if certain registry keys are not in their expected places.
  * Dependency qualifiers now support `!` for inversion.
  * Add `VCPKG_DEFAULT_VS_PATH` environment variable.
    - `vcpkg` automatically chooses the latest stable version of Visual Studio to use.
    - You can now select the desired VS with the `VCPKG_DEFAULT_VS_PATH` environment variable
    - You can also select the behavior by specifiying `VCPKG_VISUAL_STUDIO_PATH` in the triplet file (and this takes precedence over the new environment variable)

-- vcpkg team <vcpkg@microsoft.com>  MON, 19 Mar 2018 19:00:00 -0800


vcpkg (0.0.105)
--------------
  * Add ports:
    - breakpad       2018-2-19
    - cartographer   0.3.0-3
    - chipmunk       7.0.2
    - ebml           1.3.5-1
    - intel-mkl      2018.0.1
    - jbig2dec       0.13
    - libgeotiff     1.4.2-2
    - liblo          0.29-1
    - libpng-apng    1.6.34-2
    - magnum-extras  2018.02-1
    - magnum-integration 2018.02-1
    - matroska       1.4.8
    - mman           git-f5ff813
    - qt5-graphicaleffects 5.9.2-0
    - qt5-quickcontrols 5.9.2-0
    - qt5-quickcontrols2 5.9.2-0
    - recast         1.5.1
    - tinydir        1.2.3
    - tinytoml       20180219-1
  * Update ports:
    - aubio          0.4.6 -> 0.4.6-1
    - aws-sdk-cpp    1.3.15 -> 1.3.58
    - blaze          3.2-3 -> 3.3
    - boost-build    1.66.0-4 -> 1.66.0-5
    - boost-mpi      1.66.0 -> 1.66.0-1
    - catch2         2.1.1 -> 2.1.2
    - ceres          1.13.0-2 -> 1.13.0-4
    - corrade        jan2018-1 -> 2018.02-1
    - cuda           8.0-1 -> 9.0
    - draco          0.10.0-1 -> 1.2.5
    - ffmpeg         3.3.3-1 -> 3.3.3-2
    - folly          2017.11.27.00-2 -> 2017.11.27.00-3
    - hpx            1.0.0-7 -> 1.0.0-8
    - jansson        2.10-1 -> 2.11
    - libdisasm      0.23 -> 0.23-1
    - libmupdf       1.11-1 -> 1.12.0
    - magnum         jan2018-1 -> 2018.02-1
    - magnum-plugins jan2018-1 -> 2018.02-1
    - opencv         3.4.0-2 -> 3.4.0-3
    - openvr         1.0.12 -> 1.0.13
    - pcre2          10.30-1 -> 10.30-2
    - qt5-base       5.9.2-4 -> 5.9.2-5
    - realsense2     2.9.1 -> 2.10.0
    - sciter         4.1.2 -> 4.1.3
    - suitesparse    4.5.5-3 -> 4.5.5-4
    - szip           2.1.1 -> 2.1.1-1
    - uriparser      0.8.4-1 -> 0.8.5
  * Better handling of `feature packages`.
  * Bump required version & auto-downloaded version of `git` to 2.6.2

-- vcpkg team <vcpkg@microsoft.com>  TUE, 20 Feb 2018 18:30:00 -0800


vcpkg (0.0.104)
--------------
  * Add ports:
    - asmjit         673dcefaa048c5f5a2bf8b85daf8f7b9978d018a
    - cccapstone     9b4128ee1153e78288a1b5433e2c06a0d47a4c4e
    - crc32c         1.0.5
    - epsilon        0.9.2
    - exprtk         2018.01.01-f32d2b4
    - forest         4.5.0
    - libgta         1.0.8
    - libodb-mysql   2.4.0-1
    - libopenmpt     2017-01-28-cf2390140
    - libudis86      2018-01-28-56ff6c87
    - mujs           25821e6d74fab5fcc200fe5e818362e03e114428
    - muparser       6cf2746
    - openmama       6.2.1-a5a93a24d2f89a0def0145552c8cd4a53c69e2de
    - torch-th       20180131-89ede3ba90c906a8ec6b9a0f4bef188ba5bb2fd8-1
    - yara           e3439e4ead4ed5d3b75a0b46eaf15ddda2110bb9
  * Update ports:
    - abseil         2017-11-10 -> 2018-2-5
    - blosc          1.12.1 -> 1.13.5
    - boost-build    1.66.0-3 -> 1.66.0-4
    - boost-test     1.66.0-1 -> 1.66.0-2
    - catch          2.0.1-1 -> alias
    - catch2         2.1.0 -> 2.1.1
    - cgal           4.11-2 -> 4.11-3
    - cpprestsdk     2.10.1-1 -> 2.10.2
    - curl           7.58.0 -> 7.58.0-1
    - dlib           19.9 -> 19.9-1
    - flatbuffers    1.8.0 -> 1.8.0-2
    - freeimage      3.17.0-3 -> 3.17.0-4
    - gflags         2.2.1 -> 2.2.1-1
    - gtest          1.8.0-5 -> 1.8.0-6
    - highfive       1.3 -> 1.5
    - jack2          1.9.12.2 -> 1.9.12
    - libspatialite  4.3.0a -> 4.3.0a-1
    - libwebp        0.6.1 -> 0.6.1-1
    - libzip         1.3.2 -> 1.4.0
    - live555        2017.10.28 -> 2018.01.29
    - mpg123         1.25.8-1 -> 1.25.8-2
    - nghttp2        1.28.0 -> 1.30.0-1
    - nlohmann-json  3.0.1 -> 3.1.0
    - opencv         3.4.0 -> 3.4.0-2
    - opengl         0.0-4 -> 0.0-5
    - openssl        1.0.2n-1 -> 1.0.2n-2
    - openvr         1.0.9 -> 1.0.12
    - poco           1.8.1 -> 1.8.1-1
    - protobuf       3.5.0-1 -> 3.5.1
    - qt5-base       5.9.2-1 -> 5.9.2-4
    - realsense2     2.9.0 -> 2.9.1
    - sciter         4.1.1 -> 4.1.2
    - sobjectizer    5.5.20 -> 5.5.21
    - soundtouch     2.0.0.2 -> 2.0.0
    - strtk          2017.01.02-1e2960f -> 2018.01.01-5579ed1
  * The `configure` step for `release` and `debug` now happen in parallel.
    - This can significantly reduce build times for libraries where the `configure` step was a good chunk of the total build time. For example, the total build time for `zlib` drops from ~30sec to ~20sec.
  * Fix a few bootstraping issues introduced in previous release (with the clean environment)

-- vcpkg team <vcpkg@microsoft.com>  WED, 07 Feb 2018 20:30:00 -0800


vcpkg (0.0.103)
--------------
  * `vcpkg upgrade`: Fix issue with any command executing more than 10 transactions with mixed transaction types (install + remove)

-- vcpkg team <vcpkg@microsoft.com>  WED, 24 Jan 2018 14:30:00 -0800


vcpkg (0.0.102)
--------------
  * Add ports:
    - catch-classic  1.12.0
    - catch2         2.1.0
    - cgicc          3.2.19
    - libdisasm      0.23
    - qt5-3d         5.9.2-0
    - qt5-base       5.9.2-1
    - qt5-charts     5.9.2-0
    - qt5-datavis3d  5.9.2-0
    - qt5-declarative 5.9.2-0
    - qt5-gamepad    5.9.2-0
    - qt5-imageformats 5.9.2-0
    - qt5-modularscripts 1
    - qt5-multimedia 5.9.2-0
    - qt5-networkauth 5.9.2-0
    - qt5-scxml      5.9.2-0
    - qt5-serialport 5.9.2-0
    - qt5-speech     5.9.2-0
    - qt5-svg        5.9.2-0
    - qt5-tools      5.9.2-0
    - qt5-virtualkeyboard 5.9.2-0
    - qt5-websockets 5.9.2-0
    - qt5-winextras  5.9.2-0
    - qt5-xmlpatterns 5.9.2-0
    - tre            0.8.0-1
  * Update ports:
    - boost-asio     1.66.0 -> 1.66.0-1
    - boost-build    1.66.0 -> 1.66.0-3
    - boost-vcpkg-helpers 3 -> 4
    - corrade        jun2017-3 -> jan2018-1
    - curl           7.57.0-1 -> 7.57.0-2
    - date           2.3-c286981b3bf83c79554769df68b27415cee68d77 -> 2.4
    - discord-rpc    2.0.1 -> 2.1.0
    - dlib           19.8 -> 19.9
    - libbson        1.9.0 -> 1.9.2
    - libconfig      1.7.1 -> 1.7.2
    - libjpeg-turbo  1.5.2-2 -> 1.5.3
    - libodb         2.4.0-1 -> 2.4.0-2
    - libogg         1.3.2-cab46b1-3 -> 1.3.3
    - libwebp        0.6.0-2 -> 0.6.1
    - libwebsockets  2.0.0-4 -> 2.4.1
    - lz4            1.8.0-1 -> 1.8.1.2
    - magnum         jun2017-6 -> jan2018-1
    - magnum-plugins jun2017-5 -> jan2018-1
    - mongo-c-driver 1.9.0 -> 1.9.2
    - mpg123         1.25.8 -> 1.25.8-1
    - openni2        2.2.0.33-4 -> 2.2.0.33-7
    - osg            3.5.6-1 -> 3.5.6-2
    - poco           1.8.0.1 -> 1.8.1
    - qca            2.2.0-1 -> 2.2.0-2
    - qscintilla     2.10-1 -> 2.10-4
    - qt5            5.8-6 -> 5.9.2-1
    - qwt            6.1.3-2 -> 6.1.3-4
    - sciter         4.1.0 -> 4.1.1
    - sdl2           2.0.7-3 -> 2.0.7-4
    - tiff           4.0.8-1 -> 4.0.9
    - xxhash         0.6.3-1 -> 0.6.4
  * Remove usage of `BITS-transfer`. Use .NET functions (which used to be the fallback if `BITS-transfer` failed) by default.
  * Enable the usage of `feature-packages` by default. More info [here](docs/specifications/feature-packages.md).
  * Bootstrapping `vcpkg` now happens in a clean environment to avoid issues when building in a VS Developer Prompt among others.
  * Update required version & auto-downloaded version of `cmake` to 3.10.2
  * Update required version & auto-downloaded version of `vswhere` to 2.3.2

-- vcpkg team <vcpkg@microsoft.com>  TUE, 23 Jan 2018 17:00:00 -0800


vcpkg (0.0.101)
--------------
  * Add ports:
    - alac-decoder   0.2
    - args           d8905de
    - boost-accumulators 1.66.0
    - boost-algorithm 1.66.0
    - boost-align    1.66.0
    - boost-any      1.66.0
    - boost-array    1.66.0
    - boost-asio     1.66.0
    - boost-assert   1.66.0
    - boost-assign   1.66.0
    - boost-atomic   1.66.0
    - boost-beast    1.66.0
    - boost-bimap    1.66.0
    - boost-bind     1.66.0
    - boost-build    1.66.0
    - boost-callable-traits 1.66.0
    - boost-chrono   1.66.0
    - boost-circular-buffer 1.66.0
    - boost-compatibility 1.66.0
    - boost-compute  1.66.0
    - boost-concept-check 1.66.0
    - boost-config   1.66.0
    - boost-container 1.66.0
    - boost-context  1.66.0
    - boost-conversion 1.66.0
    - boost-convert  1.66.0
    - boost-core     1.66.0
    - boost-coroutine 1.66.0
    - boost-coroutine2 1.66.0
    - boost-crc      1.66.0
    - boost-date-time 1.66.0
    - boost-detail   1.66.0
    - boost-disjoint-sets 1.66.0
    - boost-dll      1.66.0
    - boost-dynamic-bitset 1.66.0
    - boost-endian   1.66.0
    - boost-exception 1.66.0
    - boost-fiber    1.66.0
    - boost-filesystem 1.66.0
    - boost-flyweight 1.66.0
    - boost-foreach  1.66.0
    - boost-format   1.66.0
    - boost-function 1.66.0
    - boost-function-types 1.66.0
    - boost-functional 1.66.0
    - boost-fusion   1.66.0
    - boost-geometry 1.66.0
    - boost-gil      1.66.0
    - boost-graph    1.66.0
    - boost-graph-parallel 1.66.0
    - boost-hana     1.66.0
    - boost-heap     1.66.0
    - boost-icl      1.66.0
    - boost-integer  1.66.0
    - boost-interprocess 1.66.0
    - boost-interval 1.66.0
    - boost-intrusive 1.66.0
    - boost-io       1.66.0
    - boost-iostreams 1.66.0
    - boost-iterator 1.66.0
    - boost-lambda   1.66.0
    - boost-lexical-cast 1.66.0
    - boost-local-function 1.66.0
    - boost-locale   1.66.0
    - boost-lockfree 1.66.0
    - boost-log      1.66.0
    - boost-logic    1.66.0
    - boost-math     1.66.0
    - boost-metaparse 1.66.0
    - boost-move     1.66.0
    - boost-mp11     1.66.0
    - boost-mpi      1.66.0
    - boost-mpl      1.66.0
    - boost-msm      1.66.0
    - boost-multi-array 1.66.0
    - boost-multi-index 1.66.0
    - boost-multiprecision 1.66.0
    - boost-numeric-conversion 1.66.0
    - boost-odeint   1.66.0
    - boost-optional 1.66.0
    - boost-parameter 1.66.0
    - boost-phoenix  1.66.0
    - boost-poly-collection 1.66.0
    - boost-polygon  1.66.0
    - boost-pool     1.66.0
    - boost-predef   1.66.0
    - boost-preprocessor 1.66.0
    - boost-process  1.66.0
    - boost-program-options 1.66.0
    - boost-property-map 1.66.0
    - boost-property-tree 1.66.0
    - boost-proto    1.66.0
    - boost-ptr-container 1.66.0
    - boost-python   1.66.0-1
    - boost-qvm      1.66.0
    - boost-random   1.66.0
    - boost-range    1.66.0
    - boost-ratio    1.66.0
    - boost-rational 1.66.0
    - boost-regex    1.66.0
    - boost-scope-exit 1.66.0
    - boost-serialization 1.66.0
    - boost-signals  1.66.0
    - boost-signals2 1.66.0
    - boost-smart-ptr 1.66.0
    - boost-sort     1.66.0
    - boost-spirit   1.66.0
    - boost-stacktrace 1.66.0
    - boost-statechart 1.66.0
    - boost-static-assert 1.66.0
    - boost-system   1.66.0
    - boost-test     1.66.0-1
    - boost-thread   1.66.0
    - boost-throw-exception 1.66.0
    - boost-timer    1.66.0
    - boost-tokenizer 1.66.0
    - boost-tti      1.66.0
    - boost-tuple    1.66.0
    - boost-type-erasure 1.66.0
    - boost-type-index 1.66.0
    - boost-type-traits 1.66.0
    - boost-typeof   1.66.0
    - boost-ublas    1.66.0
    - boost-units    1.66.0
    - boost-unordered 1.66.0
    - boost-utility  1.66.0
    - boost-uuid     1.66.0
    - boost-variant  1.66.0
    - boost-vcpkg-helpers 3
    - boost-vmd      1.66.0
    - boost-wave     1.66.0
    - boost-winapi   1.66.0
    - boost-xpressive 1.66.0
    - brynet         0.9.0
    - chaiscript     6.0.0
    - cimg           2.1.8
    - crow           0.1
    - gainput        1.0.0
    - jack2          1.9.12.2
    - libdatrie      0.2.10-2
    - libgit2        0.26.0
    - libmupdf       1.11-1
    - libpqxx        6.0.0
    - libqrencode    4.0.0-1
    - libsamplerate  0.1.9.0
    - mbedtls        2.6.1
    - nghttp2        1.28.0
    - portmidi       0.217.1
    - re2            2017-12-01-1
    - rs-core-lib    commit-1ed2dadbda3977b13e5e83cc1f3eeca76b36ebe5
    - sol            2.18.7
    - soundtouch     2.0.0.2
    - sqlitecpp      2.2
    - tinyexif       1.0.1-1
    - unicorn        2017-12-06-bc34c36eaeca0f4fc672015d24ce3efbcc81d6e4-1
    - unicorn-lib    commit-3ffa7fe69a1d0c37fb52a4af61380c5fd84fa5aa
    - yoga           1.7.0
  * Update ports:
    - ace            6.4.5 -> 6.4.6
    - alembic        1.7.4-1 -> 1.7.5
    - arrow          0.6.0 -> 0.6.0-1
    - asio           1.10.8 -> 1.10.8-1
    - assimp         4.0.1-3 -> 4.1.0-1
    - aubio          0.46 -> 0.4.6
    - aws-sdk-cpp    1.2.4 -> 1.3.15
    - beast          v84-1 -> 0
    - blaze          3.2-2 -> 3.2-3
    - bond           7.0.2 -> 7.0.2-1
    - boost          1.65.1-3 -> 1.66.0
    - brotli         1.0.2 -> 1.0.2-1
    - bullet3        2.86.1-1 -> 2.87
    - cgal           4.11 -> 4.11-2
    - cpp-redis      3.5.2-2 -> 4.3.0
    - cpprestsdk     2.10.0 -> 2.10.1-1
    - curl           7.55.1-1 -> 7.57.0-1
    - directxmesh    oct2016 -> dec2017
    - directxtex     dec2016 -> dec2017
    - directxtk      dec2016-1 -> dec2017
    - dlib           19.7 -> 19.8
    - exiv2          4f4add2cdcbe73af7098122a509dff0739d15908 -> 8f5b795eaa4bc414d2d6041c1dbd1a7f7bf1fc99
    - fcl            0.5.0-2 -> 0.5.0-3
    - fftw3          3.3.7-1 -> 3.3.7-2
    - flatbuffers    1.7.1-1 -> 1.8.0
    - fmt            4.0.0-1 -> 4.1.0
    - folly          2017.11.27.00 -> 2017.11.27.00-2
    - gflags         2.2.0-5 -> 2.2.1
    - glm            0.9.8.5 -> 0.9.8.5-1
    - gmime          3.0.2 -> 3.0.5
    - grpc           1.7.2 -> 1.8.3
    - gsl-lite       0.24.0 -> 0.26.0
    - gtest          1.8-1 -> 1.8.0-5
    - harfbuzz       1.6.3-1 -> 1.7.4
    - hdf5           1.10.0-patch1-2 -> 1.10.1-1
    - hpx            1.0.0-5 -> 1.0.0-7
    - imgui          1.52 -> 1.53
    - itk            4.11.0 -> 4.13.0
    - libbson        1.6.2-2 -> 1.9.0
    - libconfig      1.6.0-1 -> 1.7.1
    - libiconv       1.15 -> 1.15-1
    - libkml         1.3.0-1 -> 1.3.0-2
    - librtmp        2.3 -> 2.4
    - libsodium      1.0.15 -> 1.0.15-1
    - libtorrent     1.1.5 -> 1.1.6
    - live555        2017.09.12 -> 2017.10.28
    - llvm           5.0.0-2 -> 5.0.1
    - mongo-c-driver 1.6.2-1 -> 1.9.0
    - mongo-cxx-driver 3.1.1-1 -> 3.1.1-2
    - mpg123         1.24.0-1 -> 1.25.8
    - mpir           3.0.0-3 -> 3.0.0-4
    - ms-gsl         20171104-d10ebc6555b627c9d1196076a78467e7be505987 -> 20171204-9d65e74400976b3509833f49b16d401600c7317d
    - nlohmann-json  2.1.1-1 -> 3.0.1
    - opencv         3.3.1-9 -> 3.4.0
    - openimageio    1.7.15-1 -> 1.7.15-2
    - openssl        1.0.2m -> 1.0.2n-1
    - openvdb        5.0.0 -> 5.0.0-1
    - pcl            1.8.1-7 -> 1.8.1-9
    - pybind11       2.2.0 -> 2.2.1
    - python3        3.6.1 -> 3.6.4
    - range-v3       20151130-vcpkg4 -> 20151130-vcpkg5
    - realsense2     2.8.2 -> 2.9.0
    - sciter         4.0.6 -> 4.1.0
    - sdl2-image     2.0.1-3 -> 2.0.2-1
    - sdl2-mixer     2.0.2-1 -> 2.0.2-2
    - sdl2-net       2.0.1-3 -> 2.0.1-4
    - sdl2-ttf       2.0.14-3 -> 2.0.14-4
    - sobjectizer    5.5.19.2-1 -> 5.5.20
    - speex          1.2.0-2 -> 1.2.0-4
    - string-theory  1.6-1 -> 1.7
    - szip           2.1-2 -> 2.1.1
    - tacopie        2.4.1-2 -> 3.2.0
    - tbb            2017_U7 -> 2018_U2
    - tclap          1.2.1 -> 1.2.2
    - thrift         20172805-72ca60debae1d9fb35d9f0085118873669006d7f-1 -> 20172805-72ca60debae1d9fb35d9f0085118873669006d7f-2
    - tinyxml2       5.0.1-1 -> 6.0.0
    - vtk            8.0.1-5 -> 8.1.0-1
    - wt             3.3.7-2 -> 3.3.7-4
    - zeromq         20170908-18498f620f0f6d4076981ea16eb5760fe4d28dc2-1 -> 20170908-18498f620f0f6d4076981ea16eb5760fe4d28dc2-2
    - zstd           1.3.1-1 -> 1.3.3
  * Introduce `vcpkg upgrade` command. This command automatically rebuilds outdated libraries to the latest version.
  * `vcpkg list`: Improve output for long triplets
  * Update required version & auto-downloaded version of `cmake` to 3.10.1

-- vcpkg team <vcpkg@microsoft.com>  WED, 10 Jan 2018 17:00:00 -0800


vcpkg (0.0.100)
--------------
  * Add ports:
    - libmspack      0.6
    - scintilla      3.7.6
    - vlpp           0.9.3.1
  * Update ports:
    - allegro5       5.2.2.0-1 -> 5.2.3.0
    - benchmark      1.2.0 -> 1.3.0
    - brotli         0.6.0-1 -> 1.0.2
    - chakracore     1.4.3 -> 1.7.4
    - cppunit        1.13.2 -> 1.14.0
    - doctest        1.2.0 -> 1.2.6
    - ecm            5.37.0-1 -> 5.40.0
    - expat          2.2.4-2 -> 2.2.5
    - flint          2.5.2 -> 2.5.2-1
    - folly          2017.10.02.00 -> 2017.11.27.00
    - freerdp        2.0.0-rc0~vcpkg1-1 -> 2.0.0-rc1~vcpkg1
    - libtorrent     1.1.4-1 -> 1.1.5
    - libuv          1.16.1 -> 1.18.0
    - libzip         1.2.0-2 -> 1.3.2
    - log4cplus      REL_1_2_1-RC2-1 -> REL_2_0_0-RC2
    - mpfr           3.1.6-1 -> 3.1.6-2
    - nana           1.5.4-1 -> 1.5.5
    - poco           1.7.8-2 -> 1.8.0.1
    - pugixml        1.8.1-2 -> 1.8.1-3
    - sciter         4.0.4 -> 4.0.6
    - speex          1.2.0-1 -> 1.2.0-2
  * `vcpkg` has exceeded 400 libraries!
  * `vcpkg` now supports Tab-Completion/Auto-Completion in Powershell. To enable it, simply run `.\vcpkg integrate powershell` and restart Powershell.
  * `vcpkg` now requires the English language pack of Visual Studio to be installed. This is needed because several libraries fail to build in non-English languages, so `vcpkg` sets the build environment to English to bypass these issues.

-- vcpkg team <vcpkg@microsoft.com>  MON, 04 Dec 2017 17:00:00 -0800


vcpkg (0.0.99)
--------------
  * Add ports:
    - avro-c         1.8.2
    - devil          1.8.0-1
    - halide         release_2017_10_30
    - librabbitmq    0.8.0
    - openvdb        5.0.0
    - qpid-proton    0.18.1
    - unittest-cpp   2.0.0
  * Update ports:
    - alembic        1.7.4 -> 1.7.4-1
    - angle          2017-06-14-8d471f-2 -> 2017-06-14-8d471f-4
    - aubio          0.46~alpha-3 -> 0.46
    - date           2.2 -> 2.3-c286981b3bf83c79554769df68b27415cee68d77
    - fftw3          3.3.7 -> 3.3.7-1
    - grpc           1.7.0 -> 1.7.2
    - imgui          1.51-1 -> 1.52
    - lcms           2.8-3 -> 2.8-4
    - leptonica      1.74.4-1 -> 1.74.4-2
    - leveldb        2017-10-25-8b1cd3753b184341e837b30383832645135d3d73 -> 2017-10-25-8b1cd3753b184341e837b30383832645135d3d73-1
    - libflac        1.3.2-3 -> 1.3.2-4
    - libiconv       1.14-1 -> 1.15
    - libsndfile     1.0.29-6830c42-1 -> 1.0.29-6830c42-2
    - libssh2        1.8.0-2 -> 1.8.0-3
    - llvm           5.0.0-1 -> 5.0.0-2
    - mpfr           3.1.6 -> 3.1.6-1
    - ogre           1.9.0-1 -> 1.10.9-2
    - opencv         3.3.1-7 -> 3.3.1-9
    - opengl         0.0-3 -> 0.0-4
    - pcl            1.8.1-4 -> 1.8.1-7
    - protobuf       3.4.1-2 -> 3.5.0-1
    - qhull          2015.2-1 -> 2015.2-2
    - realsense2     2.8.1 -> 2.8.2
    - redshell       1.0.0 -> 1.1.2
    - sdl2           2.0.7-1 -> 2.0.7-3
    - string-theory  1.6 -> 1.6-1
    - tesseract      3.05.01-1 -> 3.05.01-2
  * `vcpkg` now autodetects CMake usage information in libraries and displays it after install
  * `vcpkg integrate install`: Fix issue that would cause failure with unicode usernames
  * Introduce experimental support for `VCPKG_BUILD_TYPE`. Adding `set(VCPKG_BUILD_TYPE release)` in a triplet:  will cause *most* ports to only build release
  * `vcpkg` now compiles inside WSL
  * Update required version & auto-downloaded version of `cmake` to 3.10.0

-- vcpkg team <vcpkg@microsoft.com>  SAT, 26 Nov 2017 03:30:00 -0800


vcpkg (0.0.97)
--------------
  * Add ports:
    - alac           2017-11-03-c38887c5
    - atkmm          2.24.2
    - blosc          1.12.1
    - coolprop       6.1.0-2
    - discord-rpc    2.0.1
    - freetype-gl    2017-10-9-82fb152a74f01b1483ac80d15935fbdfaf3ed836
    - glibmm         2.52.1
    - gtkmm          3.22.2
    - if97           2.1.0
    - luasocket      2017.05.25.5a17f79b0301f0a1b4c7f1c73388757a7e2ed309
    - pangomm        2.40.1
    - realsense2     2.8.1
    - refprop-headers 2017-11-7-882aec454b2bc3d5323b8691736ff09c288f4ed6
    - sfgui          0.3.2-1
    - tidy-html5     5.4.0-1
  * Update ports:
    - abseil         2017-10-14 -> 2017-11-10
    - assimp         4.0.1-2 -> 4.0.1-3
    - bond           6.0.0-1 -> 7.0.2
    - catch          1.11.0 -> 2.0.1-1
    - dimcli         2.0.0-1 -> 3.1.1-1
    - dlib           19.4-5 -> 19.7
    - ffmpeg         3.3.3 -> 3.3.3-1
    - fftw3          3.3.6-p12-1 -> 3.3.7
    - freeglut       3.0.0-2 -> 3.0.0-3
    - freetype       2.8-1 -> 2.8.1-1
    - glbinding      2.1.1-2 -> 2.1.1-3
    - glm            0.9.8.4-1 -> 0.9.8.5
    - grpc           1.6.0-2 -> 1.7.0
    - jasper         2.0.13-1 -> 2.0.14-1
    - libpng         1.6.32-1 -> 1.6.34-2
    - libraw         0.18.2-4 -> 0.18.2-5
    - libsigcpp      2.99-1 -> 2.10
    - libuv          1.14.1-1 -> 1.16.1
    - libwebsockets  2.0.0-2 -> 2.0.0-4
    - ms-gsl         20170425-8b320e3f5d016f953e55dfc7ec8694c1349d3fe4 -> 20171104-d10ebc6555b627c9d1196076a78467e7be505987
    - openal-soft    1.18.1-1 -> 1.18.2-1
    - opencv         3.3.1-6 -> 3.3.1-7
    - openssl        1.0.2l-3 -> 1.0.2m
    - pcl            1.8.1-3 -> 1.8.1-4
    - sdl2           2.0.6-1 -> 2.0.7-1
    - sdl2-mixer     2.0.1-3 -> 2.0.2-1
    - sqlite-modern-cpp 2.4 -> 3.2
    - vtk            8.0.1-1 -> 8.0.1-5
    - wincrypt       0.0 -> 0.0-1
    - winsock2       0.0 -> 0.0-1
  * MSBuild integration now outputs a warning when configuration is not determinable.
  * Fix Powershell execution failures for users of PSCX. PSCX has an `Expand-Archive` cmdlet that has different parameter names than the same-named cmdlet in Powershell 5.
  * `vcpkg_from_github()`: Handle '/' in REFs

-- vcpkg team <vcpkg@microsoft.com>  TUE, 14 Nov 2017 16:00:00 -0800


vcpkg (0.0.96)
--------------
  * Add ports:
    - arb            2.11.1
    - fdk-aac        2017-11-02-1e351
    - flint          2.5.2
    - itk            4.11.0
    - libaiff        5.0
  * Update ports:
    - antlr4         4.6-1 -> 4.7
    - apr            1.6.2-1 -> 1.6.3
    - double-conversion 3.0.0-1 -> 3.0.0-2
    - flann          1.9.1-6 -> 1.9.1-7
    - opencv         3.3.1-4 -> 3.3.1-6
    - protobuf       3.4.1-1 -> 3.4.1-2
  * `vcpkg help`: Add help topics for commands. For example `vcpkg help install`
  * `vcpkg` now downloads in a temp directory; after the download is complete, the file is moved to the destination. This avoids issues with hash mismatch on partially downloaded files.
  * Update required version & auto-downloaded version of `cmake` to 3.9.5
  * Update required version & auto-downloaded version of `vswhere` to 2.2.11

-- vcpkg team <vcpkg@microsoft.com>  WED, 03 Nov 2017 18:45:00 -0800


vcpkg (0.0.95)
--------------
  * Update ports:
    - assimp         4.0.1 -> 4.0.1-2
    - blaze          3.2-1 -> 3.2-2
    - boost          1.65.1-2 -> 1.65.1-3
    - catch          1.10.0 -> 1.11.0
    - libharu        2017-08-15-d84867ebf9f-2 -> 2017-08-15-d84867ebf9f-4
    - libsndfile     libsndfile-1.0.29-6830c42-1 -> 1.0.29-6830c42-1
    - opencv         3.3.1 -> 3.3.1-4
    - pcl            1.8.1-2 -> 1.8.1-3
    - poco           1.7.8-1 -> 1.7.8-2
    - signalrclient  1.0.0-beta1-1 -> 1.0.0-beta1-2
    - vtk            8.0.0-3 -> 8.0.1-1
    - xlnt           1.1.0-1 -> 1.2.0-1
  * Various improvements in `vcpkg` when obtaining data from `PowerShell` scripts. It should now be more robust
  * Fix Windows 7 (i.e. `PowerShell 2.0`) issues in `PowerShell` scripts
  * Fix an issue with `feature packages` where an installed package would appear to be uninstalled if a feature of the package was installed and then uninstalled
  * Bump required version & auto-downloaded version of `git` to 2.5.0

-- vcpkg team <vcpkg@microsoft.com>  WED, 01 Nov 2017 15:30:00 -0800


vcpkg (0.0.94)
--------------
  * Add ports:
    - capstone       3.0.5-rc3
    - cgal           4.11
    - gettimeofday   2017-10-14-2
    - gmime          3.0.2
    - leveldb        2017-10-25-8b1cd3753b184341e837b30383832645135d3d73
    - rpclib         2.2.0
  * Update ports:
    - alembic        1.7.1-4 -> 1.7.4
    - blaze          3.2 -> 3.2-1
    - boost          1.65.1-1 -> 1.65.1-2
    - ceres          1.13.0-1 -> 1.13.0-2
    - cpprestsdk     2.9.0-4 -> 2.10.0
    - cppwinrt       spring_2017_creators_update_for_vs_15.3 -> fall_2017_creators_update_for_vs_15.3-2
    - cppzmq         4.2.1 -> 4.2.2
    - eigen3         3.3.4-1 -> 3.3.4-2
    - gdcm2          2.6.8-1 -> 2.8.3
    - harfbuzz       1.4.6-2 -> 1.6.3-1
    - libjpeg-turbo  1.5.2-1 -> 1.5.2-2
    - libmariadb     2.3.2-1 -> 3.0.2
    - libmysql       5.7.17-2 -> 5.7.17-3
    - live555        2017.06.04-1 -> 2017.09.12
    - mpir           3.0.0-2 -> 3.0.0-3
    - opencv         3.3.0-4 -> 3.3.1
    - pangolin       0.5-2 -> 0.5-3
    - pugixml        1.8.1-1 -> 1.8.1-2
    - secp256k1      2017-19-10-0b7024185045a49a1a6a4c5615bf31c94f63d9c4 -> 2017-19-10-0b7024185045a49a1a6a4c5615bf31c94f63d9c4-1
    - smpeg2         2.0.0-2 -> 2.0.0-3
    - sqlite3        3.20.1 -> 3.21.0
  * Bump required version & auto-downloaded version of `git` to 2.4.3

-- vcpkg team <vcpkg@microsoft.com>  FRI, 27 Oct 2017 19:30:00 -0800


vcpkg (0.0.93)
--------------
  * Add ports:
    - berkeleydb     4.8.30
    - libsodium      1.0.15
    - secp256k1      2017-19-10-0b7024185045a49a1a6a4c5615bf31c94f63d9c4
  * Update ports:
    - assimp         4.0.0-2 -> 4.0.1
    - azure-storage-cpp 3.0.0-3 -> 3.0.0-4
    - cctz           v2.1 -> 2.1
    - folly          v2017.07.17.01-1 -> 2017.10.02.00
    - grpc           1.6.0-1 -> 1.6.0-2
    - openblas       v0.2.20-2 -> 0.2.20-2
    - pthreads       2.9.1-1 -> 2.9.1-2
    - sdl2-gfx       1.0.3-2 -> 1.0.3-3
    - sdl2-image     2.0.1-2 -> 2.0.1-3
    - sdl2-mixer     2.0.1-2 -> 2.0.1-3
    - sdl2-net       2.0.1-2 -> 2.0.1-3
    - sdl2-ttf       2.0.14-2 -> 2.0.14-3
    - spirv-tools    v2017.1-dev-7e2d26c77b606b21af839b37fd21381c4a669f23-1 -> 2017.1-dev-7e2d26c77b606b21af839b37fd21381c4a669f23-1
    - thor           v2.0-1 -> 2.0-1
    - tinyexr        v0.9.5-d16ea6 -> 0.9.5-d16ea6
  * Fix issue where `vcpkg` was getting output from powershell scripts. Powershell adds newlines when the console width is reached; the extra newlines was causing `vcpkg`'s parsing to fail.
  * Improve autocomplete/tab-completion for powershell (still experimental)

-- vcpkg team <vcpkg@microsoft.com>  THU, 19 Oct 2017 21:30:00 -0800


vcpkg (0.0.92)
--------------
  * Add ports:
    - cctz           v2.1
    - celero         2.1.0-1
    - eastl          3.05.08
    - imgui          1.51-1
    - libidn2        2.0.4
    - mozjpeg        3.2-1
    - spatialite-tools 4.3.0
    - string-theory  1.6
    - tiny-dnn       2017-10-09-dd906fed8c8aff8dc837657c42f9d55f8b793b0e
    - wincrypt       0.0
    - winsock2       0.0
  * Update ports:
    - abseil         2017-09-28 -> 2017-10-14
    - boost          1.65.1 -> 1.65.1-1
    - cpprestsdk     2.9.0-3 -> 2.9.0-4
    - gdal           1.11.3-5 -> 2.2.2
    - jansson        v2.10-1 -> 2.10-1
    - lua            5.3.4-2 -> 5.3.4-4
    - mpfr           3.1.5-1 -> 3.1.6
    - ogre           1.9.0 -1 -> 1.9.0-1
    - openni2        2.2.0.33-2 -> 2.2.0.33-4
    - pcl            1.8.1-1 -> 1.8.1-2
    - sciter         4.0.3 -> 4.0.4
    - vtk            8.0.0-2 -> 8.0.0-3
    - websocketpp    0.7.0 -> 0.7.0-1
  * Initial support for autocomplete/tab-completion for powershell (still experimental)
  * Add `VCPKG_CHAINLOAD_TOOLCHAIN_FILE variable`. As the name suggests, you can chainload your own toolchain file along with the `vcpkg` toolchain file.
  * Fix issues with the new Visual Studio detection ([`vswhere.exe`](https://github.com/Microsoft/vswhere)). Notably:
    - Detect VS2015 BuildTools, VS2017 BuildTools and VS Express Edition
  * Fix issues with Windows SDK detection
  * Rework acquisition of `vcpkg` dependencies (e.g. `cmake`, `git`). It is now more robust and should be faster on modern Operating Systems while still having fallback functions for older ones.
  * Bump required version & auto-downloaded version of `cmake` to 3.9.4
  * Bump required version & auto-downloaded version of `nuget` to 4.4.0
  * Bump required version & auto-downloaded version of `vswhere` to 2.2.7
  * Bump required version & auto-downloaded version of `git` to 2.4.2(.3)
  * Bump ninja to version 1.8.0

-- vcpkg team <vcpkg@microsoft.com>  TUE, 17 Oct 2017 16:00:00 -0800


vcpkg (0.0.91)
--------------
  * Add ports:
    - abseil         2017-09-28
    - enet           1.3.13
    - exiv2          4f4add2cdcbe73af7098122a509dff0739d15908
    - freexl         1.0.4
    - gts            0.7.6
    - kinectsdk2     2.0
    - libexif        0.6.21-1
    - libfreenect2   0.2.0
    - librtmp        2.3
    - libspatialite  4.3.0a
    - libxmp-lite    4.4.1
    - proj4          4.9.3-1
    - readosm        1.1.0
    - spirit-po      1.1.2
    - telnetpp       1.2.4
    - wildmidi       0.4.1
  * Update ports:
    - anax           2.1.0-2 -> 2.1.0-3
    - aws-sdk-cpp    1.0.61-1 -> 1.2.4
    - geos           3.5.0-1 -> 3.6.2-2
    - kinectsdk1     1.8-1 -> 1.8-2
    - lua            5.3.4-1 -> 5.3.4-2
    - openni2        2.2.0.33 -> 2.2.0.33-2
    - openssl        1.0.2l-2 -> 1.0.2l-3
    - pangolin       0.5-1 -> 0.5-2
    - proj           4.9.3-1 -> 0
    - sdl2           2.0.5-4 -> 2.0.6-1
    - zlib           1.2.11-2 -> 1.2.11-3
  * `vcpkg export`: Add new option `--ifw` which creates a standalone GUI installer for the exported packages. More information and screenshots [here](https://github.com/Microsoft/vcpkg/pull/1734)
  * Complete rework of Visual Studio detection & selection:
    - Use [`vswhere.exe`](https://github.com/Microsoft/vswhere) to detect Visual Studio installation instances
    - Add the ability to specify the Visual Studio instance to use in the triplet file with the `VCPKG_VISUAL_STUDIO_PATH` variable
    - Automatic selection now picks instances in order: stable, prerelease, legacy. Within each group, newer versions are preferred over old versions
    - Fix issue where v140 toolset would not work if VS2017 (with v140) was installed but VS2015 was not installed
  * Add message when downloading a `vcpkg` dependency (e.g. `cmake`)

-- vcpkg team <vcpkg@microsoft.com>  THU, 05 Oct 2017 19:00:00 -0800


vcpkg (0.0.90)
--------------
  * Add ports:
    - caffe2         0.8.1
    - date           2.2
    - jsonnet        2017-09-02-11cf9fa9f2fe8acbb14b096316006082564ca580
    - kf5plotting    5.37.0
    - units          2.3.0
    - winpcap        4.1.3-1
  * Update ports:
    - arrow          apache-arrow-0.4.0-2 -> 0.6.0
    - benchmark      1.1.0-1 -> 1.2.0
    - cppwinrt       feb2017_refresh-14393 -> spring_2017_creators_update_for_vs_15.3
    - llvm           4.0.0-1 -> 5.0.0-1
    - luafilesystem  1.6.3-1 -> 1.7.0.2
    - opencv         3.2.0-4 -> 3.3.0-4
    - paho-mqtt      1.2.0-1 -> 1.2.0-2
    - protobuf       3.4.0-2 -> 3.4.1-1
    - qt5            5.8-5 -> 5.8-6
    - sfml           2.4.2-1 -> 2.4.2-2
    - xlnt           0.9.4-1 -> 1.1.0-1
    - zlib           1.2.11-1 -> 1.2.11-2
  * Bump required version & auto-downloaded version of `cmake` to 3.9.3 (was 3.9.1). Noteable changes:
    - Fix codepage issues
    - FindBoost: Add support for Boost 1.65.0 and 1.65.1
  * `vcpkg edit`: Fix inspected locations for VSCode

-- vcpkg team <vcpkg@microsoft.com>  SUN, 24 Sep 2017 03:30:00 -0800


vcpkg (0.0.89)
--------------
  * Update ports:
    - boost                1.65-1 -> 1.65.1
    - chmlib               0.40 -> 0.40-1
    - pybind11             2.1.0-2 -> 2.2.0
    - sciter               4.0.2-1 -> 4.0.3
    - sqlite3              3.19.1-2 -> 3.20.1
  * `vcpkg` now warns if the built version of the `vcpkg.exe` itself is outdated
  * Update to latest python 3.5
  * `vcpkg install` improvements:
    - Add `--keep-going` option to keep going if a package fails to install
    - Add elapsed time to each invidial package as well as total time
    - Add a counter to the install (e.g. Starting package 3/12: <name>)
  * `vcpkg edit` now checks more location for VSCode Insiders

-- vcpkg team <vcpkg@microsoft.com>  WED, 14 Sep 2017 16:00:00 -0800


vcpkg (0.0.88)
--------------
   * `vcpkg_configure_cmake` has been modified to embed debug symbols within static libraries (using the /Z7 option). Most of the libraries in `vcpkg` had their versions bumped due to this.
   * `vcpkg_configure_meson` has been modified in the same manner.

-- vcpkg team <vcpkg@microsoft.com>  SAT, 09 Sep 2017 00:30:00 -0800


vcpkg (0.0.87)
--------------
  * Add ports:
    - console-bridge       0.3.2-1
    - leptonica            1.74.4
    - tesseract            3.05.01
    - urdfdom              1.0.0-1
    - urdfdom-headers      1.0.0-1
  * Update ports:
    - ace                  6.4.4 -> 6.4.5
    - c-ares               1.12.1-dev-40eb41f-1 -> 1.13.0
    - glslang              1c573fbcfba6b3d631008b1babc838501ca925d3-2 -> 3a21c880500eac21cdf79bef5b80f970a55ac6af
    - grpc                 1.4.1 -> 1.6.0
    - libuv                1.14.0 -> 1.14.1
    - meschach              -> 1.2b
    - openblas             v0.2.20 -> v0.2.20-1
    - openssl              1.0.2l-1 -> 1.0.2l-2
    - protobuf             3.3.0-3 -> 3.4.0-1
    - qt5                  5.8-4 -> 5.8-5
    - shaderc              2df47b51d83ad83cbc2e7f8ff2b56776293e8958-1 -> 12fb656ab20ea9aa06e7084a74e5ff832b7ce2da
    - spirv-tools          1.1-f72189c249ba143c6a89a4cf1e7d53337b2ddd40 -> v2017.1-dev-7e2d26c77b606b21af839b37fd21381c4a669f23
    - xxhash               0.6.2 -> 0.6.3
    - zeromq               4.2.2 -> 20170908-18498f620f0f6d4076981ea16eb5760fe4d28dc2
  * Add new function `vcpkg_from_bitbucket` which the Bitbucket equivalent of `vcpkg_from_github`

-- vcpkg team <vcpkg@microsoft.com>  FRI, 08 Sep 2017 22:00:00 -0800


vcpkg (0.0.86)
--------------
  * Add ports:
    - bigint               2010.04.30
    - butteraugli          2017-09-02-8c60a2aefa19adb
    - ccd                  2.0.0-1 (Renamed from libccd)
    - fadbad               2.1.0
    - fcl                  0.5.0-1
    - guetzli              2017-09-02-cb5e4a86f69628
    - gumbo                0.10.1
    - libmicrohttpd        0.9.55
    - libstemmer           2017-9-02
    - libunibreak          4.0
    - lodepng              2017-09-01-8a0f16afe74a6a
    - meschach
    - nlopt                2.4.2-c43afa08d~vcpkg1
    - picosha2             2017-09-01-c5ff159b6
    - piex                 2017-09-01-473434f2dd974978b
    - pthreads             2.9.1
    - tinythread           1.1
    - tinyxml              2.6.2-1
  * Removed ports:
    - libccd               2.0.0 (Renamed to ccd)
  * Update ports:
    - ace                  6.4.3 -> 6.4.4
    - boost                1.65 -> 1.65-1
    - cairo                1.15.6 -> 1.15.8
    - gdk-pixbuf           2.36.6 -> 2.36.9
    - glib                 2.52.2 -> 2.52.3
    - gtk                  3.22.15 -> 3.22.19
    - jxrlib               1.1-2 -> 1.1-3
    - paho-mqtt            Version 1.1.0 (Paho 1.2) -> 1.2.0
    - pango                1.40.6 -> 1.40.11
    - shaderc              2df47b51d83ad83cbc2e7f8ff2b56776293e8958 -> 2df47b51d83ad83cbc2e7f8ff2b56776293e8958-1
  * Fix warnings in bootstrap-vcpkg.ps1
  * Fix codepage related issues with ninja/cmake
  * Improve handling for non-ascii environments
  * Configurations names are now more tolerant:
    - If a configuration name is prefixed with "Release", then it is compatible with "Release"
    - If a configuration name is prefixed with "Debug", then it is compatible with "Debug"
  * `vcpkg edit`: Improve detection of VSCode and add better messages when no path is found
  * Fixes and improvements in the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 04 Sep 2017 02:00:00 -0800


vcpkg (0.0.85)
--------------
  * Add ports:
    - ccfits               2.5
    - highfive             1.3
    - lzfse                1.0
    - pangolin             0.5
    - rhash                1.3.5
    - speexdsp             1.2rc3-1
    - unrar                5.5.8
  * Update ports:
    - assimp               4.0.0 -> 4.0.0-1
    - catch                1.9.7 -> 1.10.0
    - ctemplate            2017-06-23-44b7c5b918a08ad561c63e9d28beecb40c10ebca -> 2017-06-23-44b7c5-2
    - curl                 7.55.0 -> 7.55.1
    - ecm                  5.32.0 -> 5.37.0
    - expat                2.1.1-1 -> 2.2.4-1
    - ffmpeg               3.2.4-3 -> 3.3.3
    - gl2ps                OpenGL to PostScript Printing Library -> 1.4.0
    - jsoncpp              1.7.7 -> 1.8.1
    - libp7-baical         4.1 -> 4.4-1
    - libpng               1.6.31 -> 1.6.32
    - libraw               0.18.2-2 -> 0.18.2-3
    - libsigcpp            2.10 -> 2.99
    - snappy               1.1.6-be6dc3d -> 1.1.7
  * `vcpkg edit`: Add new option `--builtrees`; opens editor in buildtrees directory for examining build issues
  * Improve Windows SDK support (contract version detection)
  * Improve handling for non-ascii environments
  * Fixes and improvements in the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  SUN, 27 Aug 2017 22:00:00 -0800


vcpkg (0.0.84)
--------------
  * Add ports:
    - cfitsio              3.410
    - chmlib               0.40
    - gl2ps                OpenGL to PostScript Printing Library
    - libharu              2017-08-15-d84867ebf9f-1
    - mpfr                 3.1.5
    - sophus               1.0.0
  * Update ports:
    - allegro5             5.2.1.0 -> 5.2.2.0
    - blaze                3.1 -> 3.2
    - boost                1.64-5 -> 1.65
    - curl                 7.51.0-3 -> 7.55.0
    - flann                1.9.1-4 -> 1.9.1-5
    - gdal                 1.11.3-4 -> 1.11.3-5
    - glew                 2.0.0-2 -> 2.1.0
    - lcms                 2.8-1 -> 2.8-2
    - libogg               2017-07-27-cab46b19847 -> 1.3.2-cab46b1-2
    - libuv                1.13.1 -> 1.14.0
    - lz4                  1.7.5 -> 1.8.0
    - pcre2                10.23 -> 10.30
    - spdlog               0.13.0 -> 0.14.0
    - zstd                 1.3.0 -> 1.3.1
  * Bump required version & auto-downloaded version of `git` to 2.14.1 (due to a security vulnerability)
  * Show more information when there are issues acquiring `vcpkg` tool dependencies (`git`, `cmake`, `nuget`)
  * Remove download prompts for cmake/git. The prompts were causing a lot of issues for users and especially CI builds
  * `vcpkg edit`: Fix detection of 64-bit VSCode
  * Fixes and improvements in the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  TUE, 22 Aug 2017 13:00:00 -0800


vcpkg (0.0.83)
--------------
  * Add ports:
    - fuzzylite            6.0
    - jemalloc             4.3.1-1
    - libkml               1.3.0
    - pcl                  1.8.1
    - plog                 1.1.3
  * Update ports:
    - catch                1.9.6 -> 1.9.7
    - ceres                1.12.0-4 -> 1.13.0
    - cpp-redis            3.5.2 -> 3.5.2-1
    - gdal                 1.11.3-3 -> 1.11.3-4
    - graphicsmagick       1.3.26 -> 1.3.26-1
    - hypre                2.11.1 -> 2.11.2
    - libtheora            1.1.1 -> 1.2.0alpha1-20170719~vcpkg1
    - minizip              1.2.11 -> 1.2.11-1
    - openblas             v0.2.19-2 -> v0.2.20
    - openjpeg             2.1.2-2 -> 2.2.0
    - physfs               2.0.3 -> 2.0.3-1
    - stb                  1.0 -> 20170724-9d9f75e
    - uwebsockets          0.14.3 -> 0.14.4
    - vtk                  7.1.1-1 -> 8.0.0-1
    - yaml-cpp             0.5.4 candidate -> 0.5.4-rc-1
  * Bump required version & auto-downloaded version of `cmake` to 3.9.1 (was 3.9.0)
  * Fixes and improvements in the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  FRI, 11 Aug 2017 12:00:00 -0800


vcpkg (0.0.82)
--------------
  * Add ports:
    - alembic              1.7.1-3
    - allegro5             5.2.1.0
    - angle                2017-06-14-8d471f-1
    - apr-util             1.6.0
    - arrow                apache-arrow-0.4.0-1
    - aubio                0.46~alpha-2
    - aurora               2017-06-21-c75699d2a8caa726260c29b6d7a0fd35f8f28933
    - benchmark            1.1.0
    - blaze                3.1
    - brotli               0.6.0
    - c-ares               1.12.1-dev-40eb41f-1
    - ceres                1.12.0-4
    - clara                2017-07-20-9661f2b4a50895d52ebb4c59382785a2b416c310
    - corrade              jun2017-2
    - cpp-redis            3.5.2
    - cppcms               1.1.0
    - cppunit              1.13.2
    - cpr                  1.3.0
    - ctemplate            2017-06-23-44b7c5b918a08ad561c63e9d28beecb40c10ebca
    - cunit                2.1.3-1
    - cxxopts              1.3.0
    - dirent               2017-06-23-5c7194c2fe2c68c1a8212712c0b4b6195382d27d
    - draco                0.10.0
    - duktape              2.0.3-3
    - embree               2.16.4-1
    - evpp                 0.6.1
    - flann                1.9.1-4
    - folly                v2017.07.17.01
    - g2o                  20170730_git-1
    - geogram              1.4.9
    - gsl-lite             0.24.0
    - hpx                  1.0.0-4
    - hunspell             1.6.1-1
    - hwloc                1.11.7-1
    - hypre                2.11.1
    - ilmbase              2.2.0
    - jansson              v2.10
    - jasper               2.0.13
    - kinectsdk1           1.8-1
    - libconfig            1.6.0
    - libmikmod            3.3.11.1
    - libopusenc           0.1
    - libssh               0.7.5
    - libtorrent           1.1.4
    - libusb               1.0.21-fc99620
    - libusb-win32         1.2.6.0
    - libzip               1.2.0-1
    - live555              2017.06.04
    - llvm                 4.0.0
    - lpeg                 1.0.1-2
    - luafilesystem        1.6.3
    - luajit               2.0.5
    - magnum               jun2017-5
    - magnum-plugins       jun2017-4
    - matio                1.5.10-1
    - minizip              1.2.11
    - msinttypes           2017-06-26-f9e7c5758ed9e3b9f4b2394de1881c704dd79de0
    - nuklear              2017-06-15-5c7194c2fe2c68c1a8212712c0b4b6195382d27d
    - ode                  0.15.1
    - openexr              2.2.0
    - openimageio          1.7.15
    - openni2              2.2.0.33
    - opusfile             0.9
    - osg                  3.5.6
    - paho-mqtt            Version 1.1.0 (Paho 1.2)
    - plibsys              0.0.3
    - podofo               0.9.5
    - ptex                 2.1.28
    - pystring             1.1.3
    - python3              3.6.1
    - qhull                2015.2
    - qscintilla           2.10-1
    - redshell             1.0.0
    - rocksdb              2017-06-28-18c63af6ef2b9f014c404b88488ae52e6fead03c
    - rtmidi               2.1.1-1
    - rttr                 0.9.5
    - sciter               4.0.2-1
    - sdl2-gfx             1.0.3-1
    - snappy               1.1.6-be6dc3d
    - sobjectizer          5.5.19.2
    - speex                1.2.0
    - strtk                2017.01.02-1e2960f
    - suitesparse          4.5.5-2
    - sundials             2.7.0
    - tacopie              2.4.1-1
    - theia                0.7-d15154a
    - thor                 v2.0
    - thrift               20172805-72ca60debae1d9fb35d9f0085118873669006d7f
    - uriparser            0.8.4
    - utf8proc             2.1.0
    - utfz                 1.2
    - wxwidgets            3.1.0-1
  * Update ports:
    - apr                  1.5.2 -> 1.6.2
    - assimp               3.3.1 -> 4.0.0
    - beast                1.0.0-b30 -> v84-1
    - bond                 5.3.1 -> 6.0.0
    - boost                1.64-2 -> 1.64-5
    - bzip2                1.0.6 -> 1.0.6-1
    - cairo                1.15.4 -> 1.15.6
    - catch                1.9.1 -> 1.9.6
    - cereal               1.2.1 -> 1.2.2
    - chakracore           1.4.0 -> 1.4.3
    - dimcli               1.0.3 -> 2.0.0
    - dlfcn-win32          1.1.0 -> 1.1.1
    - dlib                 19.4-1 -> 19.4-4
    - doctest              1.1.0 -> 1.2.0
    - double-conversion    2.0.1 -> 3.0.0
    - eigen3               3.3.3 -> 3.3.4
    - expat                2.1.1 -> 2.1.1-1
    - ffmpeg               3.2.4-2 -> 3.2.4-3
    - fftw3                3.3.6-p11 -> 3.3.6-p12
    - flatbuffers          1.6.0 -> 1.7.1
    - fltk                 1.3.4-2 -> 1.3.4-4
    - fmt                  3.0.1-4 -> 4.0.0
    - fontconfig           2.12.1 -> 2.12.4
    - freeglut             3.0.0 -> 3.0.0-1
    - freeimage            3.17.0-1 -> 3.17.0-2
    - freerdp              2.0.0-beta1+android11 -> 2.0.0-rc0~vcpkg1
    - freetype             2.6.3-5 -> 2.8
    - gdcm2                2.6.7 -> 2.6.8
    - gettext              0.19 -> 0.19-1
    - gflags               2.2.0-2 -> 2.2.0-4
    - glew                 2.0.0-1 -> 2.0.0-2
    - gli                  0.8.2 -> 0.8.2-1
    - glib                 2.52.1 -> 2.52.2
    - glm                  0.9.8.1 -> 0.9.8.4
    - glog                 0.3.4-0472b91-1 -> 0.3.5
    - glslang              1c573fbcfba6b3d631008b1babc838501ca925d3-1 -> 1c573fbcfba6b3d631008b1babc838501ca925d3-2
    - graphicsmagick       1.3.25 -> 1.3.26
    - grpc                 1.2.3 -> 1.4.1
    - gsl                  2.3 -> 2.4-1
    - gtk                  3.22.11 -> 3.22.15
    - harfbuzz             1.4.6 -> 1.4.6-1
    - lcms                 2.8 -> 2.8-1
    - libarchive           3.3.1 -> 3.3.2
    - libbson              1.6.2 -> 1.6.2-1
    - libepoxy             1.4.1-7d58fd3 -> 1.4.3
    - libevent             2.1.8-1 -> 2.1.8-2
    - libgd                2.2.4-1 -> 2.2.4-2
    - libjpeg-turbo        1.5.1-1 -> 1.5.2
    - libogg               1.3.2 -> 2017-07-27-cab46b19847
    - libpng               1.6.28-1 -> 1.6.31
    - libraw               0.18.0-1 -> 0.18.2-2
    - libuv                1.10.1-2 -> 1.13.1
    - log4cplus            1.1.3-RC7 -> REL_1_2_1-RC2
    - lzo                  2.09 -> 2.10-1
    - msgpack              2.1.1 -> 2.1.5
    - msmpi                8.0-1 -> 8.1
    - nana                 1.4.1-66be23c9204c5567d1c51e6f57ba23bffa517a7c -> 1.5.4
    - openal-soft          1.17.2 -> 1.18.1
    - openblas             v0.2.19-1 -> v0.2.19-2
    - opencv               3.2.0-1 -> 3.2.0-3
    - openjpeg             2.1.2-1 -> 2.1.2-2
    - openssl              1.0.2k-2 -> 1.0.2l-1
    - openvr               1.0.5 -> 1.0.9
    - opus                 1.1.4 -> 1.2.1
    - pango                1.40.5-1 -> 1.40.6
    - pcre                 8.40 -> 8.41
    - pdcurses             3.4 -> 3.4-1
    - portaudio            19.0.6.00 -> 19.0.6.00-1
    - protobuf             3.2.0 -> 3.3.0-3
    - pybind11             2.1.0 -> 2.1.0-1
    - qt5                  5.8-1 -> 5.8-4
    - qwt                  6.1.3-1 -> 6.1.3-2
    - ragel                6.9 -> 6.10
    - range-v3             20150729-vcpkg3 -> 20151130-vcpkg4
    - rxcpp                3.0.0 -> 4.0.0-1
    - sdl2                 2.0.5-2 -> 2.0.5-3
    - sdl2-image           2.0.1 -> 2.0.1-1
    - sdl2-mixer           2.0.1 -> 2.0.1-1
    - sdl2-net             2.0.1 -> 2.0.1-1
    - sdl2-ttf             2.0.14 -> 2.0.14-1
    - smpeg2               2.0.0 -> 2.0.0-1
    - spdlog               0.12.0 -> 0.13.0
    - sqlite3              3.18.0-1 -> 3.19.1-1
    - taglib               1.11.1-1 -> 1.11.1-3
    - tbb                  20160916 -> 2017_U7
    - think-cell-range     e2d3018 -> 498839d
    - tiff                 4.0.7-1 -> 4.0.8
    - tinyxml2             3.0.0 -> 5.0.1
    - utfcpp               2.3.4 -> 2.3.5
    - uwebsockets          0.14.2 -> 0.14.3
    - vtk                  7.1.0 -> 7.1.1-1
    - wt                   3.3.7 -> 3.3.7-1
    - zstd                 1.1.1 -> 1.3.0
  * `vcpkg` has exceeded 300 libraries!
  * Add the following options to `vcpkg export` command: `--nuget-id`, `--nuget-version`
  * Improve `vcpkg help`:
    - Improve clarity
    - Add `vcpkg help <topic>` option (example: `vcpkg help export`)
    - Add `vcpkg help topics` option
  * `vcpkg search` now also searches in the description of ports
  * Documentation has been reworked and is now also available in ReadTheDocs: https://vcpkg.readthedocs.io/
  * Bump required version & auto-downloaded version of `cmake` to 3.9.0 (was 3.8.0)
  * Bump required version & auto-downloaded version of `nuget` to 4.1.0 (was 3.5.0)
  * Huge number of fixes and improvements in the `vcpkg` tool

-- vcpkg team <vcpkg@microsoft.com>  MON, 07 Aug 2017 16:00:00 -0800


vcpkg (0.0.81)
--------------
  * Add ports:
    - atlmfc               0
    - giflib               5.1.4
    - graphicsmagick       1.3.25
    - libmad               0.15.1
    - libsndfile           libsndfile-1.0.29-6830c42
    - ms-gsl               20170425-8b320e3f5d016f953e55dfc7ec8694c1349d3fe4 (**see below)
    - taglib               1.11.1-1
    - xalan-c              1.11-1
  * Update ports:
    - ace                  6.4.2 -> 6.4.3
    - bond                 5.2.0 -> 5.3.1
    - boost                1.63-4 -> 1.64-2
    - cppzmq               0.0.0-1 -> 4.2.1
    - gdal                 1.11.3-1 -> 1.11.3-3
    - gdk-pixbuf           2.36.5 -> 2.36.6
    - grpc                 1.1.2-1 -> 1.2.3
    - gsl                  0-fd5ad87bf -> 2.3 (**see below)
    - harfbuzz             1.3.4-2 -> 1.4.6
    - icu                  58.2-1 -> 59.1-1
    - libflac              1.3.2-1 -> 1.3.2-2
    - libmodplug           0.8.8.5-bb25b05 -> 0.8.9.0
    - pango                1.40.4 -> 1.40.5-1
    - pcre                 8.38-1 -> 8.40
    - poco                 1.7.6-4 -> 1.7.8
    - qt5                  5.7.1-7 -> 5.8-1
    - wt                   3.3.6-3 -> 3.3.7
  * The Guidelines Support Library has been renamed from`gsl` to `ms-gsl`. The GNU Scientific Library has been added as `gsl`.
  * Introducing `vcpkg export` command:
    - Exports one or more installed packages along with their dependencies
    - Options for target format: --nuget --7zip --zip --raw (can specify more than one)
    - Option `--dry-run`: This will print out the export plan, but will not actually perform the export
    - More information and examples [here](https://blogs.msdn.microsoft.com/vcblog/2017/05/03/vcpkg-introducing-export-command/).
  * Add `--head` option for `vcpkg install`. It only applies to github-based project and allows you to use the latest master commit
    - For example: `./vcpkg install cpprestsdk:x64-windows --head` will build cpprestsdk from the latest master commit instead of version 2.9.0 specified in the `CONTROL` file
  * Bump auto-downloaded version of `cmake` to 3.8.0 (was 3.8.0rc1)
  * `--options` are now case-insensitive
  * `vcpkg` now uses `clang-format`
  * Fixes and improvements in the `vcpkg` tool

-- vcpkg team <vcpkg@microsoft.com>  WED, 03 May 2017 18:00:00 -0800


vcpkg (0.0.80)
--------------
  * Add ports:
    - clapack              3.2.1
    - geographiclib        1.47-patch1-3
    - libevent             2.1.8-1
    - mdnsresponder        765.30.11
    - openblas             v0.2.19-1
    - picojson             1.3.0
    - sdl2-mixer           2.0.1
    - sdl2-net             2.0.1
    - sdl2-ttf             2.0.14
  * Update ports:
    - azure-storage-cpp    3.0.0 -> 3.0.0-2
    - catch                1.8.2 -> 1.9.1
    - eigen3               3.3.0 -> 3.3.3
    - glib                 2.50.3 -> 2.52.1
    - libbson              1.5.1 -> 1.6.2
    - libpng               1.6.28 -> 1.6.28-1
    - libvorbis            1.3.5-1-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee -> 1.3.5-143caf4-2
    - libxml2              2.9.4 -> 2.9.4-1
    - mongo-c-driver       1.5.1 -> 1.6.2
    - mongo-cxx-driver     3.0.3-1 -> 3.1.1
    - opencv               3.2.0 -> 3.2.0-1
    - qwt                  6.1.3 -> 6.1.3-1
    - uwebsockets          0.14.1 -> 0.14.2
    - xerces-c             3.1.4 -> 3.1.4-3
  * Added `System32\Wbem` to the sanizited environment
  * `--debug` flag will now show environment information when launching external commands
  * `vcpkg install` command has been enhanced:
    - When a package build starts or ends, a message with the package name is diplayed
    - Before the start of the build, a summary of the install plan is displayed
    - Added new option `--dry-run`: This will print out the install plan, but will not actually perform the install
  * Add CI badge in the front page
  * Fix WindowsSDK detection to correctly handle the new optional c++ desktop deployment of the Windows SDK.
  * Reduce verbosity of `vcpkg remove` when purging the package
  * Fixes and improvements in the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  WED, 18 Apr 2017 18:00:00 -0800


vcpkg (0.0.79)
--------------
  * Add ports:
    - ecm                  5.32.0
    - libgd                2.2.4-1
    - octomap              cefed0c1d79afafa5aeb05273cf1246b093b771c-1
  * Update ports:
    - boost                1.63-3 -> 1.63-4
    - cuda                 8.0 -> 8.0-1
    - freeimage            3.17.0 -> 3.17.0-1
    - freetype             2.6.3-4 -> 2.6.3-5
    - glfw3                3.2.1 -> 3.2.1-1
    - libarchive           3.2.2-2 -> 3.3.1
    - pqp                  1.3 -> 1.3-1
    - qt5                  5.7.1-6 -> 5.7.1-7
    - sqlite3              3.17.0 -> 3.18.0-1
  * `vcpkg` has exceeded 200 libraries!
  * `vcpkg remove` command has been reworked:
    - `vcpkg remove <pkg>` now uninstalls and deletes the package by default. Previously, this was the behavior of `vpckg remove --purge <pkg>`
    - `vcpkg remove <pkg> --no-purge` now uninstalls the package without deleting it. Previously, this was the behavior or `vcpkg remove <pkg>`
    - Added new option `--dry-run`: This will print out the remove plan, but will not actually perform the removal
    - Added new option `--outdated`: Using `vcpkg remove --outdated` will remove all packages for which updates are available
  * Add `bootstrap-vcpkg.bat` in the root directory for easier building of `vcpkg`
    - Also fix a regression with `vcpkg` bootstrapping
  * Add information about how to use header-only libraries from cmake in [EXAMPLES.md](docs\EXAMPLES.md)
  * `vcpkg build_external` changed to `vcpkg build-external` (underscore to dash)
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  WED, 05 Apr 2017 15:00:00 -0800


vcpkg (0.0.78)
--------------
  * Add ports:
    - libp7-baical         4.1
    - pybind11             2.1.0
    - xxhash               0.6.2
  * Update ports:
    - catch                1.8.1            -> 1.8.2
    - glog                 0.3.4-0472b91    -> 0.3.4-0472b91-1
    - libuv                1.10.1           -> 1.10.1-2
    - libwebp              0.5.1-1          -> 0.6.0-1
    - range-v3             20150729-vcpkg2  -> 20150729-vcpkg3
    - tiff                 4.0.6-2          -> 4.0.7
    - uwebsockets          0.13.0-1         -> 0.14.1
  * `--debug` flag enhanced to give line information on any exit. Applies to any `vcpkg` command
  * Improve error messages when requesting a portfile that does not exist (for example via command line or via dependencies)
  * Add `EMPTY_INCLUDE_FOLDER` policy
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  TUE, 28 Mar 2017 21:15:00 -0800


vcpkg (0.0.77)
--------------
  * Add ports:
    - beast                1.0.0-b30
    - botan                2.0.1
    - cairomm              1.15.3-1
    - dlfcn-win32          1.1.0
    - freerdp              2.0.0-beta1+android11
    - gdcm2                2.6.7
    - jbigkit              2.1
    - libpopt              1.16-10~vcpkg1
    - libvpx               1.6.1-1
    - libwebm              1.0.0.27-1
    - msgpack              2.1.1
    - nlohmann-json        2.1.1
    - pcre2                10.23
    - tinyexr              v0.9.5-d16ea6
    - xlnt                 0.9.4
  * Update ports:
    - antlr4               4.6              -> 4.6-1
    - atk                  2.22.0           -> 2.24.0
    - boost                1.63-2           -> 1.63-3
    - dlib                 19.2             -> 19.4-1
    - glib                 2.50.2           -> 2.50.3
    - gtk                  3.22.8           -> 3.22.11
    - libepoxy             1.4.0-2432daf-1  -> 1.4.1-7d58fd3
    - libjpeg-turbo        1.4.90-1         -> 1.5.1-1
    - liblzma              5.2.3            -> 5.2.3-1
    - mpg123               1.23.3           -> 1.24.0-1
    - mpir                 2.7.2-1          -> 3.0.0-2
    - pango                1.40.3           -> 1.40.4
    - qt5                  5.7.1-5          -> 5.7.1-6
    - uwebsockets          0.12.0           -> 0.13.0-1
  * Improvements and fixes in the sanizited environment introduced in the previous version
  * `--debug` flag now gives line information when an error occurs. Applies to any `vcpkg` command
  * Fixes and improvements around launching powershell scripts
    - Correct handling of spaces in the path
    - Ignore user profile (-NoProfile)
  * `openssl`: Enable building in paths with space and ignore installed versions in `C:/OpenSSL/`
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  WED, 22 Mar 2017 15:30:00 -0800


vcpkg (0.0.76)
--------------
  * Add ports:
    - ffmpeg               3.2.4-2
    - fftw3                3.3.6-p11
    - flatbuffers          1.6.0
    - netcdf-c             4.4.1.1-1
    - netcdf-cxx4          4.3.0
    - portaudio            19.0.6.00
    - vtk                  7.1.0
  * Update ports:
    - azure-storage-cpp    2.6.0            -> 3.0.0
    - boost                1.63             -> 1.63-2
    - bullet3              2.83.7.98d4780   -> 2.86.1
    - catch                1.5.7            -> 1.8.1
    - cppwinrt             1.010.0.14393.0  -> feb2017_refresh-14393
    - hdf5                 1.8.18           -> 1.10.0-patch1-1
    - libflac              1.3.2            -> 1.3.2-1
    - libpng               1.6.24-1         -> 1.6.28
    - lua                  5.3.3-2          -> 5.3.4
    - msmpi                8.0              -> 8.0-1
    - openjpeg             2.1.2            -> 2.1.2-1
    - poco                 1.7.6-3          -> 1.7.6-4
    - szip                 2.1              -> 2.1-1
    - zeromq               4.2.0            -> 4.2.2
  * `vcpkg` now launches external commands (most notably builds) in a sanitized environment
  * Better proxy handling when fetching dependencies (cmake/git/nuget)
  * Fix more VS2017 issues
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 10 Mar 2017 17:45:00 -0800


vcpkg (0.0.75)
--------------
  * Add ports:
    - dlib                 19.2
    - gtk                  3.22.8
    - pqp                  1.3
    - pugixml              1.8.1
  * Update ports:
    - clockutils           1.1.1            -> 1.1.1-3651f232c27074c4ceead169e223edf5f00247c5
    - grpc                 1.1.0-dev-1674f65-2 -> 1.1.2-1
    - libflac              1.3.1-1          -> 1.3.2
    - liblzma              5.2.2            -> 5.2.3
    - libmysql             5.7.17           -> 5.7.17-1
    - lz4                  1.7.4.2          -> 1.7.5
    - mongo-cxx-driver     3.0.3            -> 3.0.3-1
    - nana                 1.4.1            -> 1.4.1-66be23c9204c5567d1c51e6f57ba23bffa517a7c
    - opengl               10.0.10240.0     -> 0.0-3
    - protobuf             3.0.2            -> 3.2.0
    - qt5                  5.7.1-2          -> 5.7.1-5
    - spdlog               0.11.0           -> 0.12.0
  * Numerous improvements in Visual Studio, MSBuild and Windows SDK auto-detection
  * `vcpkg integrate install` now outputs the specific toolchain file to use for CMake integration
  * All commands now checks for `--options` and will issue an error on unknown options.
    - Previously only commands with options would do this (for example `vcpkg remove --purge <pkg>`) and commands with no options would ignore them, for example `vcpkg install --purge <pkg>`
  * Update version of the automatically acquired JOM, python
    - Also, for python: automatically acquire the 32-bit versions instead of the 64-bit ones
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 27 Feb 2017 14:00:00 -0800


vcpkg (0.0.74)
--------------
  * Bump required version & auto-downloaded version of `cmake` to 3.8.0 (was 3.7.x). This fixes UWP builds with Visual Studio 2017
  * Fix `vcpkg build` not printing out the missing dependencies on fail
  * Fixes and improvements in the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  THU, 16 Feb 2017 18:15:00 -0800


vcpkg (0.0.73)
--------------
  * Add ports:
    - gdk-pixbuf           2.36.5
    - openvr               1.0.5
  * Update ports:
    - lmdb                 0.9.18-1         -> 0.9.18-2
    - opencv               3.1.0-1          -> 3.2.0
    - sqlite3              3.15.0           -> 3.17.0
  * Add functions to correctly find the "Program Files" folders in all parts of `vcpkg` (C++, CMake, powershell)
  * Flush std::cout before launching an external process. Fixes issues when redirecting std::cout to a file
  * Update version of the automatically acquired nasm. Resolves build failure with libjpeg-turbo
  * Change the format of the listfile. The file is now sorted and directories now have a trailing slash so they can easily be identified.
     - Old listfiles will be automatically updated on first access. This will happen to all old listfiles when a new package is installed (`vcpkg install`) or after a call to `vcpkg owns`.
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  WED, 15 Feb 2017 19:30:00 -0800


vcpkg (0.0.72)
--------------
  * Add ports:
    - cuda                 8.0
    - hdf5                 1.8.18
    - lcms                 2.8
    - libepoxy             1.4.0-2432daf-1
    - libnice              0.1.13
    - msmpi                8.0
    - parmetis             4.0.3
    - sqlite-modern-cpp    2.4
    - websocketpp          0.7.0
  * Update ports:
    - asio                 1.10.6           -> 1.10.8
    - aws-sdk-cpp          1.0.47           -> 1.0.61
    - bond                 5.0.0-4-g53ea136 -> 5.2.0
    - cpprestsdk           2.9.0-1          -> 2.9.0-2
    - fmt                  3.0.1-1          -> 3.0.1-4
    - grpc                 1.1.0-dev-1674f65-1 -> 1.1.0-dev-1674f65-2
    - libraw               0.17.2-2         -> 0.18.0-1
    - libvorbis            1.3.5-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee -> 1.3.5-1-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee
    - poco                 1.7.6-2          -> 1.7.6-3
    - rapidjson            1.0.2-1          -> 1.1.0
    - sfml                 2.4.1            -> 2.4.2
    - wt                   3.3.6-2          -> 3.3.6-3
  * Introduce Build Policies:
     - Packages with special characteristics (e.g. CUDA) can now use Build Policies to control which post-build checks apply to them.
  * Improve support for Visual Studio 2017
    - Add auto-detection for Windows SDK
    - Fixed various issues with `bootstrap.ps1` and VS2017 support
  * Automatic acquisition of perl now uses the 32-bit version isntead of the 64-bit version
  * Fix `vcpkg remove --purge` not applying to non-installed packages
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  TUE, 14 Feb 2017 11:30:00 -0800


vcpkg (0.0.71)
--------------
  * Add ports:
    - atk                  2.22.0
    - fontconfig           2.12.1
    - opus                 1.1.4
    - pango                1.40.3
    - xerces-c             3.1.4
  * Update ports:
    - boost                1.62-11          -> 1.63
    - cairo                1.14.6           -> 1.15.4
    - directxtk            dec2016          -> dec2016-1
    - fltk                 1.3.4-1          -> 1.3.4-2
    - gdal                 1.11.3           -> 1.11.3-1
    - harfbuzz             1.3.4            -> 1.3.4-2
    - libarchive           3.2.2            -> 3.2.2-2
    - libmariadb           2.3.1            -> 2.3.2
    - mpir                 2.7.2            -> 2.7.2-1
    - openssl              1.0.2j-2         -> 1.0.2k-2
    - wt                   3.3.6            -> 3.3.6-2
  * Improve `vcpkg remove`:
     - Now shows all dependencies that need to be removed instead of just the immediate dependencies
     - Add `--recurse` option that removes all dependencies
     - Improve messages
  * Improve support for Visual Studio 2017
    - Better VS2017 detection
    - Fixed various issues with `bootstrap.ps1` and VS2017 support
  * Fix `vcpkg_copy_pdbs()` under non-English locale
  * Notable changes for buiding the `vcpkg` tool:
    - Restructure `vcpkg` project hierarchy. Now only has 4 projects (down from 6). Most of the code now lives under vcpkglib.vcxproj
    - Enable multiprocessor compilation
    - Disable MinimalRebuild
    - Use precompiled headers
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 30 Jan 2017 23:00:00 -0800


vcpkg (0.0.70)
--------------
  * Add ports:
    - fltk                 1.3.4-1
    - glib                 2.50.2
    - lzo                  2.09
    - uvatlas              sept2016
  * Update ports:
    - dx                   1.0.0            -> 1.0.1
    - libmysql             5.7.16           -> 5.7.17
  * Add support for Visual Studio 2017
    - Previously, you could use Visual Studio 2017 for your own application and `vcpkg` integration would work, but you needed to have Visual Studio 2015 to build `vcpkg` itself as well as the libraries. This requirement has now been removed
    - If both Visual Studio 2015 and Visual Studio 2017 are installed, Visual Studio 2017 tools will be preferred over those of Visual Studio 2015
  * Bump required version & auto-downloaded version of `cmake` to 3.7.2 (was 3.5.x), which includes generators for Visual Studio 2017
  * Bump auto-downloaded version of `nuget` to 3.5.0 (was 3.4.3)
  * Bump auto-downloaded version of `git` to 2.11.0 (was 2.8.3)
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 23 Jan 2017 19:50:00 -0800


vcpkg (0.0.67)
--------------
  * Add ports:
    - cereal               1.2.1
    - directxmesh          oct2016
    - directxtex           dec2016
    - metis                5.1.0
    - sdl2-image           2.0.1
    - szip                 2.1
  * Update ports:
    - ace                  6.4.0            -> 6.4.2
    - boost                1.62-9           -> 1.62-11
    - curl                 7.51.0-2         -> 7.51.0-3
    - directxtk            oct2016-1        -> dec2016
    - directxtk12          oct2016          -> dec2016
    - freetype             2.6.3-3          -> 2.6.3-4
    - glew                 2.0.0            -> 2.0.0-1
    - grpc                 1.1.0-dev-1674f65 -> 1.1.0-dev-1674f65-1
    - http-parser          2.7.1            -> 2.7.1-1
    - libssh2              1.8.0            -> 1.8.0-1
    - libwebsockets        2.0.0            -> 2.0.0-1
    - openssl              1.0.2j-1         -> 1.0.2j-2
    - tiff                 4.0.6-1          -> 4.0.6-2
    - zlib                 1.2.10           -> 1.2.11
  * Add 7z to `vcpkg_find_acquire_program.cmake`
  * Enhance `vcpkg_build_cmake.cmake` and `vcpkg_install_cmake.cmake`:
    - Add option to disable parallel building (it is enabled by default)
    - Add option to use the 64-bit toolset (for the 32-bit builds; output binaries are still 32-bit)
  * Fix bug in `applocal.ps1` that would infinitely recurse when there were no depenndencies
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  WED, 18 Jan 2017 13:45:00 -0800


vcpkg (0.0.66)
--------------
  * Add ports:
    - antlr4               4.6
    - bzip2                1.0.6
    - dx                   1.0.0
    - gli                  0.8.2
    - libarchive           3.2.2
    - libffi               3.1
    - liblzma              5.2.2
    - libmodplug           0.8.8.5-bb25b05
    - libsigcpp            2.10
    - lmdb                 0.9.18-1
    - lz4                  1.7.4.2
    - ogre                 1.9.0
    - qwt                  6.1.3
    - smpeg2               2.0.0
    - spirv-tools          1.1-f72189c249ba143c6a89a4cf1e7d53337b2ddd40
  * Update ports:
    - aws-sdk-cpp          1.0.34-1         -> 1.0.47
    - azure-storage-cpp    2.5.0            -> 2.6.0
    - boost                1.62-8           -> 1.62-9
    - chakracore           1.3.1            -> 1.4.0
    - freetype             2.6.3-2          -> 2.6.3-3
    - icu                  58.1             -> 58.2-1
    - libbson              1.5.0-rc6        -> 1.5.1
    - libvorbis                             -> 1.3.5-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee
    - lua                  5.3.3-1          -> 5.3.3-2
    - mongo-c-driver       1.5.0-rc6        -> 1.5.1
    - pixman               0.34.0           -> 0.34.0-1
    - qt5                  5.7-1            -> 5.7.1-2
    - sdl2                 2.0.5            -> 2.0.5-2
    - zlib                 1.2.8            -> 1.2.10
  * Improvements in pre-install checks:
    - Refactor file-exists-check. Improved clarity and performance.
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  TUE, 10 Jan 2017 17:15:00 -0800


vcpkg (0.0.65)
--------------
  * Add ports:
    - anax                 2.1.0-1
    - aws-sdk-cpp          1.0.34-1
    - azure-storage-cpp    2.5.0
    - charls               2.0.0
    - dimcli               1.0.3
    - entityx              1.2.0
    - freeimage            3.17.0
    - gdal                 1.11.3
    - globjects            1.0.0
    - http-parser          2.7.1
    - icu                  58.1
    - libflac              1.3.1-1
    - libssh2              1.8.0
    - nana                 1.4.1
    - qca                  2.2.0
    - sfml                 2.4.1
    - shaderc              2df47b51d83ad83cbc2e7f8ff2b56776293e8958
    - uwebsockets          0.12.0
    - yaml-cpp             0.5.4 candidate
  * Update ports:
    - boost                1.62-6           -> 1.62-8
    - curl                 7.51.0-1         -> 7.51.0-2
    - gflags               2.1.2            -> 2.2.0-2
    - glbinding            2.1.1            -> 2.1.1-1
    - glslang              1c573fbcfba6b3d631008b1babc838501ca925d3 -> 1c573fbcfba6b3d631008b1babc838501ca925d3-1
    - harfbuzz             1.3.2            -> 1.3.4
    - jxrlib               1.1-1            -> 1.1-2
    - libraw               0.17.2           -> 0.17.2-2
    - lua                  5.3.3            -> 5.3.3-1
    - openssl              1.0.2j           -> 1.0.2j-1
  * Improvements in the post-build checks:
    - Add check for files in the `<package>\` dir and `<package>\debug\` dir
  * Introduce pre-install checks:
    - The `install` command now checks that files will not be overwrriten when installing a package. A particular file can only be owned by a single package
  * Introduce 'lib\manul-link\' directory. Libraries placing the lib files in that directory are not automatically added to the link line
  * Disable all interactions with CMake registry
  * `vcpkg /?` is now a valid equivalent of `vcpkg help`
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 12 Dec 2016 18:15:00 -0800


vcpkg (0.0.61)
--------------
  * Add ports:
    - cairo                1.14.6
    - clockutils           1.1.1
    - directxtk            oct2016-1
    - directxtk12          oct2016
    - glslang              1c573fbcfba6b3d631008b1babc838501ca925d3
    - libodb-pgsql         2.4.0
    - pixman               0.34.0
    - proj                 4.9.3
    - zstd                 1.1.1
  * Update ports:
    - chakracore           1.3.0            -> 1.3.1
    - curl                 7.51.0           -> 7.51.0-1
    - dxut                 11.14            -> 11.14-2
    - fmt                  3.0.1            -> 3.0.1-1
    - freetype             2.6.3-1          -> 2.6.3-2
    - rxcpp                2.3.0            -> 3.0.0
    - think-cell-range     1d785d9          -> e2d3018
    - tiff                 4.0.6            -> 4.0.6-1
  * Fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  MON, 28 Nov 2016 18:30:00 -0800


vcpkg (0.0.60)
--------------
  * Add ports:
    - box2d                2.3.1-374664b
    - decimal-for-cpp      1.12
    - jsoncpp              1.7.7
    - libpq                9.6.1
    - libxslt              1.1.29
    - poco                 1.7.6-2
    - qt5                  5.7-1
    - signalrclient        1.0.0-beta1
    - soci                 2016.10.22
    - tclap                1.2.1
  * Update ports:
    - boost                1.62-1           -> 1.62-6
    - chakracore           1.2.0.0          -> 1.3.0
    - eigen3               3.2.10-2         -> 3.3.0
    - fmt                  3.0.0-1          -> 3.0.1
    - jxrlib               1.1              -> 1.1-1
    - libbson              1.4.2            -> 1.5.0-rc6
    - libuv                1.9.1            -> 1.10.1
    - libwebp              0.5.1            -> 0.5.1-1
    - mongo-c-driver       1.4.2            -> 1.5.0-rc6
    - mongo-cxx-driver     3.0.2            -> 3.0.3
    - pcre                 8.38             -> 8.38-1
    - sdl2                 2.0.4            -> 2.0.5
  * `vcpkg` has exceeded 100 libraries!
  * Rework dependency handling
  * Many more portfiles now support static builds. The remaining ones warn that static is not yet supported and will perform a dynamic build instead
  * The triplet file is now automatically included and is available in every portfile
  * Improvements in the post-build checks:
    - Introduce `BUILD_INFO` file. This contains information about the settings used in the build. The post-build checks use this file to choose what checks to perform
    - Add CRT checks
    - Improve coff file reader. It is now more robust and it correctly handles a couple of corner cases
    - A few miscellaneous checks to further prevent potential issues with the produced packages
  * Improve integration and fix related issues
  * Add support for VS 2017
  * Introduce function that tries to repeatedly build up to a number of failures. This reduces/resolves issues from libraries with flaky builds
  * Many fixes and improvements in existing portfiles and the `vcpkg` tool itself

-- vcpkg team <vcpkg@microsoft.com>  WED, 23 Nov 2016 15:30:00 -0800


vcpkg (0.0.51)
--------------
  * Add simple substring search to `vcpkg cache`
  * Add simple substring search to `vcpkg list`

-- vcpkg team <vcpkg@microsoft.com>  MON, 07 Nov 2016 14:45:00 -0800


vcpkg (0.0.50)
--------------
  * Add ports:
    - apr                  1.5.2
    - assimp               3.3.1
    - boost-di             1.0.1
    - bullet3              2.83.7.98d4780
    - catch                1.5.7
    - chakracore           1.2.0.0
    - cppwinrt             1.010.0.14393.0
    - cppzmq               0.0.0-1
    - cryptopp             5.6.5
    - double-conversion    2.0.1
    - dxut                 11.14
    - fastlz               1.0
    - freeglut             3.0.0
    - geos                 3.5.0
    - gettext              0.19
    - glbinding            2.1.1
    - glog                 0.3.4-0472b91
    - harfbuzz             1.3.2
    - jxrlib               1.1
    - libbson              1.4.2
    - libccd               2.0.0
    - libmariadb           2.3.1
    - libmysql             5.7.16
    - libodb               2.4.0
    - libodb-sqlite        2.4.0
    - libogg               1.3.2
    - libraw               0.17.2
    - libtheora            1.1.1
    - libvorbis
    - libwebp              0.5.1
    - libxml2              2.9.4
    - log4cplus            1.1.3-RC7
    - lua                  5.3.3
    - mongo-c-driver       1.4.2
    - mongo-cxx-driver     3.0.2
    - nanodbc              2.12.4
    - openjpeg             2.1.2
    - pcre                 8.38
    - pdcurses             3.4
    - physfs               2.0.3
    - rxcpp                2.3.0
    - spdlog               0.11.0
    - tbb                  20160916
    - think-cell-range     1d785d9
    - utfcpp               2.3.4
    - wt                   3.3.6
    - wtl                  9.1
    - zeromq               4.2.0
    - zziplib              0.13.62
  * Update ports:
    - boost                1.62             -> 1.62-1
    - cpprestsdk           2.8              -> 2.9.0-1
    - curl                 7.48.0           -> 7.51.0
    - eigen3               3.2.9            -> 3.2.10-2
    - freetype             2.6.3            -> 2.6.3-1
    - glew                 1.13.0           -> 2.0.0
    - openssl              1.0.2h           -> 1.0.2j
    - range-v3             0.0.0-1          -> 20150729-vcpkg2
    - sqlite3              3120200          -> 3.15.0
  * Add support for static libraries
  * Add more post build checks
  * Improve post build checks related to verifying information in the dll/pdb files (e.g. architecture)
  * Many fixes in existing portfiles
  * Various updates in FAQ
  * Release builds now create pdbs (debug builds already did)

-- vcpkg team <vcpkg@microsoft.com>  MON, 07 Nov 2016 00:01:00 -0800


vcpkg (0.0.40)
--------------
  * Add ports:
    - ace 6.4.0
    - asio 1.10.6
    - bond 5.0.0
    - constexpr 1.0
    - doctest 1.1.0
    - eigen3 3.2.9
    - fmt 3.0.0
    - gflags 2.1.2
    - glm 0.9.8.1
    - grpc 1.1.0
    - gsl 0-fd5ad87bf
    - gtest 1.8
    - libiconv 1.14
    - mpir 2.7.2
    - protobuf 3.0.2
    - ragel 6.9
    - rapidxml 1.13
    - sery 1.0.0
    - stb 1.0
  * Update ports:
    - boost 1.62
    - glfw3 3.2.1
    - opencv 3.1.0-1
  * Various fixes in existing portfiles
  * Introduce environment variable `VCPKG_DEFAULT_TRIPLET`
  * Replace everything concerning MD5 with SHA512
  * Add mirror support
  * `vcpkg` now checks for valid package names: only ASCII lowercase chars, digits, or dashes are allowed
  * `vcpkg create` now also creates a templated CONTROL file
  * `vcpkg create` now checks for invalid chars in the zip path
  * `vcpkg edit` now throws an error if it cannot launch an editor
  * Fix `vcpkg integrate` to only apply to C++ projects instead of all projects
  * Fix `vcpkg integrate` locale-specific failures
  * `vcpkg search` now does simple substring searching
  * Fix path that assumed Visual Studio is installed in default location
  * Enable multicore builds by default
  * Add `.vcpkg-root` file to detect the root directory
  * Fix `bootstrap.ps1` to work with older versions of powershell
  * Add `SOURCE_PATH` variable to all portfiles.
  * Many improvements in error messages shown by `vcpkg`
  * Various updates in FAQ
  * Move `CONTRIBUTING.md` to root

-- vcpkg team <vcpkg@microsoft.com>  WED, 05 Oct 2016 17:00:00 -0700


vcpkg (0.0.30)
--------------
  * DLLs are now accompanied with their corresponding PDBs.
  * Rework removal commands. `vcpkg remove <pkg>` now uninstalls the package. `vcpkg remove --purge <pkg>` now uninstalls and also deletes the package.
  * Rename option --arch to --triplet.
  * Extensively rework directory tree layout to make it more intuitive.
  * Improve post-build verification checks.
  * Improve post-build verification messages; they are now more compact, more consistent and contain more suggestions on how to resolve the issues found.
  * Fix `vcpkg integrate project` in cases where the path contained non-alphanumeric chars.
  * Improve handling of paths. In general, commands with whitespace and non-ascii characters should be handled better now.
  * Add colorized output for `vcpkg clean` and `vcpkg purge`.
  * Add colorized output for many more errors.
  * Improved `vcpkg update` to identify installed libraries that are out of sync with their portfiles.
  * Added list of example port files to EXAMPLES.md
  * Rename common CMake utilities to use prefix `vcpkg_`.
  * [libpng] Fixed x86-uwp and x64-uwp builds.
  * [libjpeg-turbo] Fixed x86-uwp and x64-uwp builds via suppressing static CRT linkage.
  * [rapidjson] New library.

-- vcpkg team <vcpkg@microsoft.com>  WED, 18 Sep 2016 20:50:00 -0700
