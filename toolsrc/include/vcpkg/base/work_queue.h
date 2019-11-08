#pragma once

#include <vcpkg/base/checks.h>

#include <condition_variable>
#include <memory>
#include <vector>

namespace vcpkg
{
    template<class Action>
    struct WorkQueue
    {
        WorkQueue(LineInfo li) : m_line_info(li) {}
        WorkQueue(const WorkQueue&) = delete;

        ~WorkQueue()
        {
            auto lck = std::unique_lock<std::mutex>(m_mutex, std::try_to_lock);
            /*
                if we don't own the lock, there isn't much we can do
                it is likely a spurious failure
            */
            if (lck && m_running_workers != 0)
            {
                Checks::exit_with_message(
                    m_line_info, "Internal error -- outstanding workers (%u) at destruct point", m_running_workers);
            }
        }

        template<class F>
        void run_and_join(unsigned num_threads, const F& tld_init) noexcept
        {
            if (m_actions.empty()) return;

            std::vector<std::thread> threads;
            threads.reserve(num_threads);
            for (unsigned i = 0; i < num_threads; ++i)
            {
                threads.emplace_back(Worker<decltype(tld_init())>{this, tld_init()});
            }

            for (auto& thrd : threads)
            {
                thrd.join();
            }
        }

        // useful in the case of errors
        // doesn't stop any existing running tasks
        // returns immediately, so that one can call this in a task
        void cancel() const
        {
            {
                auto lck = std::lock_guard<std::mutex>(m_mutex);
                m_cancelled = true;
                m_actions.clear();
            }
            m_cv.notify_all();
        }

        void enqueue_action(Action a) const
        {
            {
                auto lck = std::lock_guard<std::mutex>(m_mutex);
                if (m_cancelled) return;

                m_actions.push_back(std::move(a));
            }
            m_cv.notify_one();
        }

    private:
        template<class ThreadLocalData>
        struct Worker
        {
            const WorkQueue* work_queue;
            ThreadLocalData tld;

            void operator()()
            {
                auto lck = std::unique_lock<std::mutex>(work_queue->m_mutex);
                for (;;)
                {
                    const auto& w = *work_queue;
                    work_queue->m_cv.wait(lck, [&w] {
                        if (w.m_cancelled)
                            return true;
                        else if (!w.m_actions.empty())
                            return true;
                        else if (w.m_running_workers == 0)
                            return true;
                        else
                            return false;
                    });

                    if (work_queue->m_cancelled || work_queue->m_actions.empty())
                    {
                        /*
                            if we've been cancelled, or if the work queue is empty
                            and there are no other workers, we want to return
                            immediately; we don't check for the latter condition
                            since if we're at this point, then either the queue
                            is not empty, or there are no other workers, or both.
                            We can't have an empty queue, and other workers, or
                            we would still be in the wait.
                        */
                        break;
                    }

                    ++work_queue->m_running_workers;

                    auto action = std::move(work_queue->m_actions.back());
                    work_queue->m_actions.pop_back();

                    lck.unlock();
                    work_queue->m_cv.notify_one();
                    std::move(action)(tld, *work_queue);
                    lck.lock();

                    const auto after = --work_queue->m_running_workers;
                    if (work_queue->m_actions.empty() && after == 0)
                    {
                        work_queue->m_cv.notify_all();
                        return;
                    }
                }
            }
        };

        mutable std::mutex m_mutex{};
        // these are all under m_mutex
        mutable bool m_cancelled = false;
        mutable std::vector<Action> m_actions{};
        mutable std::condition_variable m_cv{};
        mutable unsigned long m_running_workers = 0;

        LineInfo m_line_info;
    };
}
