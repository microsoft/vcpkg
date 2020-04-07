# Testing

Testing vcpkg is important whenever one makes changes to the tool itself, and
writing new tests and keeping them up to date is also very important. If one's
code is subtly broken, we'd rather find it out right away than a few weeks down
the line when someone complains!

## Running Tests

Before anything else, we should know whether you can actually run the tests!
All you should need is a way to build vcpkg -- anything will do! All you have to
do is follow the guide 😄

With `$VCPKG_DIRECTORY` being the directory where you have cloned vcpkg, create
a build directory in `$VCPKG_DIRECTORY/toolsrc` (commonly named `out`), and
`cd` into it. Make sure to clean it out if it already exists!

```sh
$ cmake .. -DCMAKE_BUILD_TYPE=Debug -G Ninja
$ cmake --build .
$ ./vcpkg-test # ./vcpkg-test [$SPECIFIC_TEST] for a specific set of tests
$ # i.e., ./vcpkg-test [arguments]
```

If you make any modifications to `vcpkg`, you'll have to do the
`cmake --build .` step again.

## Writing Tests

In your journey to write new tests, and to modify existing tests, reading the
[Catch2 documentation] will be very helpful! Come back after reading those 😀

You'll want to place your tests in one of the existing files, or, if it doesn't
belong in any of those, in a [new file](#adding-new-test-files).

The layout of these tests is as follows:

```cpp
// ... includes

TEST_CASE("Name of test", "[filename without the .cpp]") {
    // setup and the like
    REQUIRE(some boolean expression);
}

// etc.
```

You want to give these test cases good, descriptive, unique names, like
`SourceParagraph construct minimum` -- it doesn't need to be extremely clear
english, and shorthand is good, but make sure it's clear what the test is from
the name. For the latter parameter, known as "tags", you should at least put the
name of the file which the test case is in -- e.g., in `arguments.cpp`, you'd
tag all of the test cases with `[arguments]`.

If you wish to add helper functions, make sure to place them in an anonymous
namespace -- this will ensure that they don't trample over anybody else's
space. Additionally, there are a few helper functions that live in
`<vcpkg-test/util.h>` and `src/vcpkg-test/util.cpp` -- make sure to look into
them so that you're not rewriting functionality.

That should be all you need to know to start writing your own tests!
Remember to check out the [Catch2 documentation]
if you'd like to get more advanced with your tests,
and good luck on your testing journey!

## Adding New Test Files

Adding new test files should be easy and straightforward. All it requires is
creating a new source file in `toolsrc/src/vcpkg-test`.

### Example

Let's try writing a new test file called `example` (very creative, I know).

First, we should create a file, `example.cpp`, in `toolsrc/src/vcpkg-test`:

```cpp
// vcpkg-test/example.cpp
#include <vcpkg-test/catch.h>
```

This is the minimum file needed for tests; let's rebuild!

```sh
$ cmake --build .
[80/80] Linking CXX executable vcpkg.exe
```

Okay, now let's make sure this worked; add a test case to `example.cpp`:

```cpp
TEST_CASE("Example 1 - fail", "[example]") {
    REQUIRE(false);
}
```

Now build the tests again, and run them:

```sh
$ cmake --build .
[2/2] Linking CXX executable vcpkg-test.exe
$ ./vcpkg-test

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vcpkg-test.exe is a Catch v2.9.1 host application.
Run with -? for options

-------------------------------------------------------------------------------
Example 1 - fail
-------------------------------------------------------------------------------
$VCPKG_DIRECTORY/toolsrc/src/vcpkg-test/example.cpp(3)
...............................................................................

$VCPKG_DIRECTORY/toolsrc/src/vcpkg-test/example.cpp(14): FAILED:
    REQUIRE( false )

===============================================================================
test cases:  102 |  101 passed | 1 failed
assertions: 3611 | 3610 passed | 1 failed
```

Hopefully, that worked! It should compile correctly, and have one failing test.
Now let's try a more complex test, after deleting the old one;

```cpp
// add #include <vcpkg/base/strings.h> to the top of the file
namespace Strings = vcpkg::Strings;

TEST_CASE("Example 2 - success", "[example]") {
    std::string hello = "Hello";
    REQUIRE(Strings::case_insensitive_ascii_equals(hello, "hELLo"));
    REQUIRE_FALSE(Strings::case_insensitive_ascii_starts_with(hello, "E"));
}
```

Now compile and build the tests, and this time let's only run our example tests:

```sh
$ cmake --build .
[2/2] Linking CXX executable vcpkg-test.exe
$ ./vcpkg-test [example]
Filters: [example]
===============================================================================
All tests passed (2 assertions in 1 test case)
```

Hopefully you have one test running and succeeding! If you have that, you have
succeeded at adding a new file to vcpkg's tests. Congratulations! Have fun on
the rest of your journey 🐱‍👤😁

[Catch2 documentation]: https://github.com/catchorg/Catch2/blob/master/docs/tutorial.md#top
