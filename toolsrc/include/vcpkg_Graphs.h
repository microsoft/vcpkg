#pragma once

#include <unordered_map>
#include <unordered_set>

namespace vcpkg::Graphs
{
    enum class ExplorationStatus
    {
        // We have not visited this vertex
        NOT_EXPLORED,

        // We have visited this vertex but haven't visited all vertices in its subtree
        PARTIALLY_EXPLORED,

        // We have visited this vertex and all vertices in its subtree
        FULLY_EXPLORED
    };

    template <class V>
    class Graph
    {
        template <class Func>
        static void find_topological_sort_internal(V vertex,
                                                   ExplorationStatus& status,
                                                   const Func adjacency_list_provider,
                                                   std::unordered_map<V, ExplorationStatus>& exploration_status,
                                                   std::vector<V>& sorted)
        {
            status = ExplorationStatus::PARTIALLY_EXPLORED;

            auto neighbours = adjacency_list_provider(vertex);

            for (V neighbour : neighbours)
            {
                ExplorationStatus& neighbour_status = exploration_status[neighbour];
                if (neighbour_status == ExplorationStatus::NOT_EXPLORED)
                {
                    find_topological_sort_internal(neighbour, neighbour_status, adjacency_list_provider, exploration_status, sorted);
                }
                else if (neighbour_status == ExplorationStatus::PARTIALLY_EXPLORED)
                {
                    throw std::runtime_error("cycle in graph");
                }
            }

            status = ExplorationStatus::FULLY_EXPLORED;
            sorted.push_back(vertex);
        }

    public:

        void add_vertex(V v)
        {
            this->vertices[v];
        }

        // TODO: Change with iterators
        void add_vertices(const std::vector<V>& vs)
        {
            for (const V& v : vs)
            {
                this->vertices[v];
            }
        }

        void add_edge(V u, V v)
        {
            this->vertices[v];
            this->vertices[u].insert(v);
        }

        std::vector<V> find_topological_sort() const
        {
            std::unordered_map<V, int> indegrees = count_indegrees();

            std::vector<V> sorted;
            sorted.reserve(indegrees.size());

            std::unordered_map<V, ExplorationStatus> exploration_status;
            exploration_status.reserve(indegrees.size());

            for (auto& pair : indegrees)
            {
                if (pair.second == 0) // Starting from vertices with indegree == 0. Not required.
                {
                    V vertex = pair.first;
                    ExplorationStatus& status = exploration_status[vertex];
                    if (status == ExplorationStatus::NOT_EXPLORED)
                    {
                        find_topological_sort_internal(vertex,
                                                       status,
                                                       [this](const V& v) { return this->vertices.at(v); },
                                                       exploration_status,
                                                       sorted);
                    }
                }
            }

            return sorted;
        }

        std::unordered_map<V, int> count_indegrees() const
        {
            std::unordered_map<V, int> indegrees;

            for (auto& pair : this->vertices)
            {
                indegrees[pair.first];
                for (V neighbour : pair.second)
                {
                    ++indegrees[neighbour];
                }
            }

            return indegrees;
        }

        const std::unordered_map<V, std::unordered_set<V>>& adjacency_list() const
        {
            return this->vertices;
        }

    private:
        std::unordered_map<V, std::unordered_set<V>> vertices;
    };
}
