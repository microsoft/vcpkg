#pragma once

#include <condition_variable>
#include <memory>
#include <queue>

namespace vcpkg {
    template <class Action, class ThreadLocalData>
    struct WorkQueue;

    namespace detail {
        // for SFINAE purposes, keep out of the class
        template <class Action, class ThreadLocalData>
        auto call_moved_action(
            Action& action,
            const WorkQueue<Action, ThreadLocalData>& work_queue,
            ThreadLocalData& tld
        ) -> decltype(static_cast<void>(std::move(action)(tld, work_queue)))
        {
            std::move(action)(tld, work_queue);
        }

        template <class Action, class ThreadLocalData>
        auto call_moved_action(
            Action& action,
            const WorkQueue<Action, ThreadLocalData>&,
            ThreadLocalData& tld
        ) -> decltype(static_cast<void>(std::move(action)(tld)))
        {
            std::move(action)(tld);
        }
    }

    template <class Action, class ThreadLocalData>
    struct WorkQueue {
        template <class F>
        explicit WorkQueue(const F& tld_init) noexcept {
            m_state = State::Running;

            std::size_t num_threads = std::thread::hardware_concurrency();
            if (num_threads == 0) {
                num_threads = 4;
            }

            m_threads.reserve(num_threads);
            for (std::size_t i = 0; i < num_threads; ++i) {
                m_threads.push_back(std::thread(Worker{this, tld_init()}));
            }
        }

        WorkQueue(WorkQueue const&) = delete;
        WorkQueue(WorkQueue&&) = delete;

        ~WorkQueue() = default;

        // runs all remaining tasks, and blocks on their finishing
        // if this is called in an existing task, _will block forever_
        // DO NOT DO THAT
        // thread-unsafe
        void join() {
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                if (m_state == State::Running) {
                    m_state = State::Joining;
                } else if (m_state == State::Joining) {
                    Checks::exit_with_message(VCPKG_LINE_INFO, "Attempted to join more than once");
                }
            }
            for (auto& thrd : m_threads) {
                thrd.join();
            }
        }

        // useful in the case of errors
        // doesn't stop any existing running tasks
        // returns immediately, so that one can call this in a task
        void terminate() const {
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                m_state = State::Terminated;
            }
            m_cv.notify_all();
        }

        void enqueue_action(Action a) const {
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                m_actions.push_back(std::move(a));
            }
            m_cv.notify_one();
        }

        template <class Rng>
        void enqueue_all_actions_by_move(Rng&& rng) const {
            {
                using std::begin;
                using std::end;

                auto lck = std::unique_lock<std::mutex>(m_mutex);

                const auto first = begin(rng);
                const auto last = end(rng);

                m_actions.reserve(m_actions.size() + (last - first));

                std::move(first, last, std::back_inserter(rng));
            }

            m_cv.notify_all();
        }

        template <class Rng>
        void enqueue_all_actions(Rng&& rng) const {
            {
                using std::begin;
                using std::end;

                auto lck = std::unique_lock<std::mutex>(m_mutex);

                const auto first = begin(rng);
                const auto last = end(rng);

                m_actions.reserve(m_actions.size() + (last - first));

                std::copy(first, last, std::back_inserter(rng));
            }

            m_cv.notify_all();
        }

    private:
        struct Worker {
            const WorkQueue* work_queue;
            ThreadLocalData tld;

            void operator()() {
                // unlocked when waiting, or when in the `call_moved_action`
                // block
                // locked otherwise
                auto lck = std::unique_lock<std::mutex>(work_queue->m_mutex);
                for (;;) {
                    const auto state = work_queue->m_state;

                    if (state == State::Terminated) {
                        return;
                    }

                    if (work_queue->m_actions.empty()) {
                        if (state == State::Running || work_queue->running_workers > 0) {
                            work_queue->m_cv.wait(lck);
                            continue;
                        }

                        // state == State::Joining and we are the only worker
                        // no more work!
                        return;
                    }

                    Action action = std::move(work_queue->m_actions.back());
                    work_queue->m_actions.pop_back();

                    ++work_queue->running_workers;
                    lck.unlock();
                    detail::call_moved_action(action, *work_queue, tld);
                    lck.lock();
                    --work_queue->running_workers;
                }
            }
        };

        enum class State : std::uint16_t {
            Running,
            Joining,
            Terminated,
        };

        mutable std::mutex m_mutex;
        // these four are under m_mutex
        mutable State m_state;
        mutable std::uint16_t running_workers;
        mutable std::vector<Action> m_actions;
        mutable std::condition_variable m_cv;

        std::vector<std::thread> m_threads;
    };
}
