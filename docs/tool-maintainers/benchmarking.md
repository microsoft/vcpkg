# Benchmarking

Benchmarking new code against old code is extremely important whenever making
large changes to how something works. If you are attempting to make something
faster, and you end up slowing it down, you'll never know if you don't
benchmark! We have benchmarks in the `toolsrc/src/vcpkg-test` directory, just
like the tests -- they're treated as a special kind of test.

## Running Benchmarks

Unlike normal tests, benchmarks are hidden behind a special define -- `CATCH_CONFIG_ENABLE_BENCHMARKING` -- so that you never try to run benchmarks
unless you specifically want to. This is because benchmarks actually take quite
a long time! However, if you want to run benchmarks (and I recommend running
only specific benchmarks at a time), you can do so by passing the
`VCPKG_ENABLE_BENCHMARKING` option at cmake configure time.

```sh
$ cmake -B toolsrc/out -S toolsrc -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DVCPKG_BUILD_BENCHMARKING=On

-- The C compiler identification is MSVC 19.22.27905.0
-- The CXX compiler identification is MSVC 19.22.27905.0
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.22.27905/bin/Hostx64/x64/cl.exe
-- Check for working C compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.22.27905/bin/Hostx64/x64/cl.exe -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.22.27905/bin/Hostx64/x64/cl.exe
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.22.27905/bin/Hostx64/x64/cl.exe -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Looking for pthread.h
-- Looking for pthread.h - not found
-- Found Threads: TRUE
-- Configuring done
-- Generating done
-- Build files have been written to: C:/Users/t-nimaz/src/vcpkg/toolsrc/out

$ cmake --build toolsrc/out

[0/2] Re-checking globbed directories...
[80/80] Linking CXX executable vcpkg-test.exe
```

You can then run benchmarks easily with the following command (which run the
files benchmarks):

```sh
$ ./toolsrc/out/vcpkg-test [!benchmark][file]
```

You can switch out `[file]` for a different set -- `[hash]`, for example.

## Writing Benchmarks

First, before anything else, I recommend reading the
[benchmarking documentation] at Catch2's repository.

Now, after that, let's say that you wanted to benchmark, say, our ASCII
case-insensitive string compare against your new implementation. We place
benchmarks for code in the same file as their tests, so open
`vcpkg-test/strings.cpp`, and add the following at the bottom:

```cpp
#if defined(CATCH_CONFIG_ENABLE_BENCHMARKING)
TEST_CASE ("case insensitive ascii equals: benchmark", "[strings][!benchmark]")
{
    BENCHMARK("qwertyuiop") {
        return vcpkg::Strings::case_insensitive_ascii_equals("qwertyuiop", "QWERTYUIOP");
    };
}
#endif
```

Remember the `;` at the end of the benchmark -- it's not required for
`TEST_CASE`s, but is for `BENCHMARK`s.

Now, let's rebuild and run:

```sh
$ cmake --build toolsrc/out
[0/2] Re-checking globbed directories...
[2/2] Linking CXX executable vcpkg-test.exe
$ ./toolsrc/out/vcpkg-test [strings][!benchmark]
Filters: [strings][!benchmark]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vcpkg-test.exe is a Catch v2.9.1 host application.
Run with -? for options

-------------------------------------------------------------------------------
case insensitive ascii equals: benchmark
-------------------------------------------------------------------------------
C:\Users\t-nimaz\src\vcpkg\toolsrc\src\vcpkg-test\strings.cpp(36)
...............................................................................

benchmark name                                  samples       iterations    estimated
                                                mean          low mean      high mean
                                                std dev       low std dev   high std dev
-------------------------------------------------------------------------------
qwertyuiop                                              100         2088    3.9672 ms
                                                      25 ns        24 ns        26 ns
                                                       6 ns         5 ns         8 ns


===============================================================================
test cases: 1 | 1 passed
assertions: - none -
```

You've now written your first benchmark!

But wait. This seems kind of silly. Benchmarking the comparison of literal
strings is great and all, but could we make it a little more realistic?

This is where `BENCHMARK_ADVANCED` comes in. `BENCHMARK_ADVANCED` allows one to
write a benchmark that has a little setup to it without screwing up the numbers.
Let's try it now:

```cpp
TEST_CASE ("case insensitive ascii equals: benchmark", "[strings][!benchmark]")
{
    BENCHMARK_ADVANCED("equal strings")(Catch::Benchmark::Chronometer meter)
    {
        std::vector<std::string> strings;
        strings.resize(meter.runs());
        std::mt19937_64 urbg;
        std::uniform_int_distribution<std::uint64_t> data_generator;

        std::generate(strings.begin(), strings.end(), [&] {
            std::string result;
            for (std::size_t i = 0; i < 1000; ++i)
            {
                result += vcpkg::Strings::b32_encode(data_generator(urbg));
            }

            return result;
        });

        meter.measure(
            [&](int run) { return vcpkg::Strings::case_insensitive_ascii_equals(strings[run], strings[run]); });
    };
}
```

Then, run it again!

```sh
$ cmake --build toolsrc/out
[0/2] Re-checking globbed directories...
[2/2] Linking CXX executable vcpkg-test.exe
$ toolsrc/out/vcpkg-test [strings][!benchmark]
Filters: [strings][!benchmark]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vcpkg-test.exe is a Catch v2.9.1 host application.
Run with -? for options

-------------------------------------------------------------------------------
case insensitive ascii equals: benchmark
-------------------------------------------------------------------------------
C:\Users\t-nimaz\src\vcpkg\toolsrc\src\vcpkg-test\strings.cpp(36)
...............................................................................

benchmark name                                  samples       iterations    estimated
                                                mean          low mean      high mean
                                                std dev       low std dev   high std dev
-------------------------------------------------------------------------------
equal strings                                           100            2    5.4806 ms
                                                  22.098 us    21.569 us    23.295 us
                                                   3.842 us     2.115 us      7.41 us


===============================================================================
test cases: 1 | 1 passed
assertions: - none -
```

And now you have a working benchmark to test the speed of the existing code, and
of new code!

If you're writing a lot of benchmarks that follow the same sort of pattern, with
some differences in constants, look into `vcpkg-test/files.cpp`'s benchmarks --
there are a lot of things one can do to make writing new benchmarks really easy.

If you wish to add a benchmark for a piece of code that has not yet been tested,
please read the [testing documentation], and please write some unit tests.
The speed of your code isn't very important if it doesn't work at all!

[benchmarking documentation]: https://github.com/catchorg/Catch2/blob/master/docs/benchmarks.md#top
[testing documentation]: ./testing.md#adding-new-test-files
