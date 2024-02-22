#pragma once

#include <functional>
#include <sstream>

// ReSharper disable CppInconsistentNaming
namespace DB
{
    /// <summary>A std::bad_alloc exception with a custom message.</summary>
    class out_of_memory_error : public std::bad_alloc
    {
        const std::string m_message;  // NOLINT(cppcoreguidelines-avoid-const-or-ref-data-members)

    public:
        explicit out_of_memory_error(std::string message) : m_message(std::move(message))
        {
        }

        [[nodiscard]] auto what() const noexcept -> const char* override
        {
            return m_message.c_str();
        }
    };

    /// <summary>
    ///     <para>In some cases, your application needs to complete a number of steps before reporting errors.
    ///     TryCatcher uses the RAII pattern in a unique way by throwing an exception from its destructor (this is
    ///     valid modern C++ because the destructor is marked to throw).</para>
    ///     <para></para>
    ///     <para>Example 1: In a cleanup() function, it may need to release the handle on a database, close
    ///     a logger, and release some hardware interfaces. If any of these steps throw an exception, it
    ///     would be premature to bail out, thus skipping subsequent cleanup steps. A better approach
    ///     would be to run each step in its own try-catch block, then throw a single exception at the end
    ///     of the cleanup() function reporting all errors. In practice, it may look something like this:</para>
    ///
    ///    <example>
    ///     void cleanup() // This will complete as many cleanup steps as it can. It will throw an exception if and only if anything goes wrong.
    ///     {
    ///         TryCatcher tryCatcher;
    ///
    ///         tryCatcher.Try([&, this]() { CloseDatabase() }); // CloseDatabase might throw an exception.
    ///         tryCatcher.Try([&, this]() { CloseLogger() }); // CloseLogger might throw an exception.
    ///         tryCatcher.Try([&, this]() { CloseDeviceConnection() }); // CloseDeviceConnection might throw an exception.
    ///         tryCatcher.Try([&, this]()
    ///             {
    ///                 if (CloseDevice2Connection() != SUCCESS) // CloseDevice2Connection does not throw exceptions, so check error code.
    ///                 {
    ///                     tryCatcher.AddMessage("Error happened when closing Device2."); // Manually add a message to force the TryCatcher to throw upon destruction.
    ///                     }
    ///             }); // CloseDeviceConnection might throw an exception.
    ///
    ///         // tryCatcher instance is about to go out of scope, thus throwing an exception if and only if any of the above steps had exceptions.
    ///     }
    ///    </example>
    ///
    ///    <para>Example 2: When running multiple asynchronous tasks, TryCatcher can be handy for retrieving stored exceptions.</para>
    ///
    ///    <example>
    ///     {
    ///         // These will all start running in parallel and store any exceptions that may occur.
    ///         auto future1 = std::async(std::launch::async, [&](params) { DoSomethingOnAThread(params); });
    ///         auto future2 = std::async(std::launch::async, [&](params) { DoSomethingOnAThread(params); });
    ///         auto future3 = std::async(std::launch::async, [&](params) { DoSomethingOnAThread(params); });
    ///         auto future4 = std::async(std::launch::async, [&](params) { DoSomethingOnAThread(params); });
    ///
    ///         po::TryCatcher tryCatcher;
    ///         tryCatcher.Try([&]() { future1.get(); }); // Block until completed and catch any exceptions that are/were thrown.
    ///         tryCatcher.Try([&]() { future2.get(); }); // Block until completed and catch any exceptions that are/were thrown.
    ///         tryCatcher.Try([&]() { future3.get(); }); // Block until completed and catch any exceptions that are/were thrown.
    ///         tryCatcher.Try([&]() { future4.get(); }); // Block until completed and catch any exceptions that are/were thrown.
    ///
    ///         // tryCatcher instance is about to go out of scope, thus throwing an exception if and only if any of the above steps had exceptions.
    ///     }
    ///     </example>
    /// </summary>
    class TryCatcher final
    {
        std::stringstream m_accumulatedMessages;

        bool m_isBadAllocExceptionCaught{};

    public:
        explicit TryCatcher() = default;

        /// <summary>
        ///     <para>This destructor is marked as "noexcept(false)", which tells the compiler to
        ///     allow exceptions to be thrown. When the TryCatcher goes out of scope,
        ///     it checks for any accumulated messages. If it finds one or more messages, it
        ///     will throw a runtime_error with a composite message using newline separators.</para>
        ///     <para>NOTE: If one or more of the caught exceptions derives from bad_alloc, then it will throw
        ///     an out_of_memory_error instead of std::runtime_error.</para>
        ///</summary>
        ~TryCatcher() noexcept(false) // NOTE: Throws from a destructor, so be sure to catch it!
        {
            // ReSharper disable once CppTooWideScopeInitStatement
            const auto message = GetMessage();
            if (!message.empty())
            {
                if (m_isBadAllocExceptionCaught)
                {
                    throw out_of_memory_error(message);
                }
                else
                {
                    throw std::runtime_error(message);
                }
            }
        }

        /// <summary>
        ///     <para>This method is the heart of TryCatcher. It immediately (and synchronously in the same thread)
        ///     runs the given function (typically a lambda function) in a try-catch block and catches
        ///     any and all types of exceptions. If it catches an exception derived from std::exception,
        ///     then it accumulates the e.what() message, separated by newline. If it catches
        ///     any other exception type, it adds an "Unknown exception." message.</para>
        ///     <para></para>
        ///     <para>NOTE: If ANY exceptions deriving from std::bad_alloc are caught, then the
        ///     TryCatcher::~TryCatcher destructor will throw an out_of_memory_error
        ///     instead of a std::runtime_error. This allows your app to handle out-of-memory
        ///     conditions as a special case.<para>
        ///</summary>
        auto Try(const std::function<void()>& functionToCallInTryCatchBlockAndAccumulateAnyExceptionMessage) -> void
        {
            try
            {
                functionToCallInTryCatchBlockAndAccumulateAnyExceptionMessage();
            }
            catch (const std::bad_alloc& e)
            {
                m_accumulatedMessages << std::string(e.what()) << '\n';
                m_isBadAllocExceptionCaught = true;
            }
            catch (const std::exception& e)
            {
                m_accumulatedMessages << std::string(e.what()) << '\n';
            }
            catch (...) // COM errors or other exception types.
            {
                m_accumulatedMessages << std::string("Unknown exception.") << '\n';
            }
        }

        /// <summary>Add a message to any accumulated messages. It will be separated
        /// with a newline. This will force an exception to be thrown when TryCatcher goes
        /// out of scope.</summary>
        auto AddMessage(const std::string& message) -> void
        {
            m_accumulatedMessages << message << '\n';
        }

        /// <summary>
        ///     <para>Retrieve any accumulated messages.</para>
        ///     <para></para>
        ///     <para>It is not normally necessary to do this because they will be automatically thrown
        ///     from the destructor as a std::runtime_error exception.</para>
        /// </summary>
        [[nodiscard]] auto GetMessage() const -> std::string
        {
            const auto accumulatedMessagesIncludingTrailingNewline = m_accumulatedMessages.str();

            return accumulatedMessagesIncludingTrailingNewline.substr(0, accumulatedMessagesIncludingTrailingNewline.length() - 1); // Trim trailing newline
        }

        // ReSharper disable CppMissingBlankLines
        auto operator=(TryCatcher&&)->TryCatcher & = delete; // Move
        TryCatcher(TryCatcher&&) = delete; // Move
        auto operator=(const TryCatcher&)->TryCatcher & = delete; // Assignment
        TryCatcher(const TryCatcher&) = delete; // Copy
        auto operator==(const TryCatcher& other) const -> bool = delete;
        auto operator!=(const TryCatcher& other) const -> bool = delete;
        // ReSharper restore CppMissingBlankLines
    };
    // ReSharper restore CppInconsistentNaming
}
