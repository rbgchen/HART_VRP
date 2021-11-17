"""
Insertion heuristic for the second way to calculate c2, minimizing push forward and wait times.
"""

from csv_to_list import csv_to_array
from results_to_csv import results_to_csv

# Path constants
a_path = "../data/a.csv"
b_path = "../data/b.csv"
s_path = "../data/s.csv"
t_path = "../data/t.csv"
d_path = "../data/d.csv"

# Parameter Constants
MU = 1.0
ALPHA_1 = 0.5
ALPHA_2 = 0.5
BETA_1 = 0.5
BETA_2 = 0.5

# Network data
a = csv_to_array(a_path)
b = csv_to_array(b_path)
s = csv_to_array(s_path)
t = csv_to_array(t_path)
d = csv_to_array(d_path)
HOME = 0
P_PLUS = set(range(1, int((len(a) - 2) / 2) + 1))
P_MINUS = set(range(max(P_PLUS) + 1, len(a) - 1))
DEPOT = max(P_MINUS) + 1
P = P_PLUS | P_MINUS
N = {HOME} | P | {DEPOT}
INITIAL_PATH = [[0 if (i, j) != (HOME, DEPOT) else 1 for j in N] for i in N]
INITIAL_T = [-float('inf') if i != HOME and i != DEPOT else 0 for i in N]


def print_path(path):
    """
    Prints a path with each i in a different row
    :param path: The path to be printed
    """
    for i in range(len(path)):
        print(path[i])  # Prints each row individually
    print()  # Prints a new line


def print_timetable(timetable):
    """
    Prints a timetable with start times for each node
    :param timetable: The timetable to be printed
    """
    print('u\tTᵤ\twait time')
    for i in timetable:
        print(f'{i}\t{timetable[i][0]}' + (3 - len(str(timetable[i][0])) + 4) * ' ' + f'{timetable[i][1]}')
        # Prints the node, followed by a tab, and the time of that node
    print()  # Prints a new line


def copy_path(path):
    """
    Creates a copy of the path that does not link to the original since the .copy() method is malfunctioning.
    :param path: The path to be copied
    :return: The copy of the path
    """
    return [row[:] for row in path]


def copy_timetable(timetable):
    """
    Creates a copy of the timetable that won't link to the original since the .copy() method is malfunctioning.
    :param timetable: The timetable to be copied
    :return: The copied timetable
    """
    return [timetable[i] for i in range(len(timetable))]


def eval_c1(timetable, i, u, j):
    new_T = copy_timetable(timetable)
    new_T[u] = max(a[u], timetable[i] + s[i] + t[i][u])
    new_T[j] = max(a[j], new_T[u] + s[u] + t[u][j])
    c_12 = new_T[j] - timetable[j]
    c_11 = d[i][u] + d[u][j] - MU * d[i][j]
    for node in range(len(new_T)):
        # Pushes forward the times of each node after insertion and checks if it exceeds latest time.

        if timetable[node] >= timetable[j]:
            new_T[node] = timetable[node] + c_12

        if new_T[node] > b[node]:
            return float('inf')
    c_1 = ALPHA_1 * c_11 + ALPHA_2 * c_12
    return c_1


def eval_c2(path, timetable, i, u, j):
    total_distance = d[i][u] + d[u][j]
    total_time = t[i][u] + t[u][j]
    for row in range(len(path)):
        for col in range(len(path[row])):
            total_distance += path[row][col] * d[row][col]
            if path[row][col] == 1:
                total_time += timetable[row] + t[row][col]

    c_2 = BETA_1 * total_distance + BETA_2 * total_time
    return c_2


def optimal_i_j(path, timetable):
    min_c1 = float('inf')
    op_i = None
    op_j = None
    for u in P_PLUS:
        for i in N - {DEPOT}:
            for j in N - {HOME}:
                if path[i][j] == 1:
                    temp_c1 = eval_c1(timetable, i, u, j)
                    if temp_c1 < min_c1:
                        min_c1 = temp_c1
                        op_i = i
                        op_j = j
    return op_i, op_j

def optimal_u(path, timetable, i, j):
    min_c2 = float('inf')
    op_u = None
    for u in P_PLUS:
        temp_c2 = eval_c2(path, timetable, i, u, j)
        if temp_c2 < min_c2:
            min_c2 = temp_c2
            op_u = u
    return op_u


def clean_timetable(timetable):
    """
    Cleans the timetable by sorting it, packing it into a dictionary, and tightening the schedule.
    :param timetable: The original timetable.
    :return: The cleaned timetable.
    """
    new_timetable = {}
    previous_node = None
    wait_time = 0
    for i in range(len(timetable)):
        if timetable[i] != float('-inf'):

            new_timetable[i] = [timetable[i]]

            if i != 0:
                wait_time = a[i] - (new_timetable[previous_node][0] + s[previous_node] + t[previous_node][i])

                if wait_time < 0:  # Accounts for negative wait times
                    wait_time = 0.0

            new_timetable[i].append(wait_time)
            previous_node = i
    key_one = min(new_timetable, key=new_timetable.get)  # Grabs the second smallest time in the table
    new_timetable[0] = [timetable[key_one] - t[0][key_one], 0.0]
    new_timetable = dict(sorted(new_timetable.items(), key=lambda item: item[1]))
    return new_timetable


def insertion():
    final_paths = []
    final_times = []

    path = copy_path(INITIAL_PATH)
    T = copy_timetable(INITIAL_T)

    updated_P = P_PLUS.union(P_MINUS)

    while len(updated_P) != 0:
        inserted = False
        i, j = optimal_i_j(path, T)
        if (i, j) != (None, None):
            u = optimal_u(path, T, i, j)
            if u is not None:
                temp_path = copy_path(path)
                temp_path[i][j] = 0
                temp_path[i][u] = 1
                temp_path[u][j] = 1
                u_d = u + int(len(N) / 2) - 1
                new_T = copy_timetable(T)
                new_T[u] = max(a[u], T[i] + s[i] + t[i][u])
                new_T[j] = max(a[j], new_T[u] + s[u] + t[u][j])
                dT = new_T[j] - T[j]
                for node in range(len(new_T)):
                    # Pushes forward the times of each node after insertion and checks if it exceeds latest time.

                    if T[node] >= T[j]:
                        new_T[node] = T[node] + dT
                i_d, j_d = optimal_i_j(temp_path, new_T)
                T = copy_timetable(new_T)
                P_PLUS.remove(u)
                P_MINUS.remove(u_d)
                inserted = True
        if not inserted:
            used_path = copy_path(path)
            used_timetable = copy_timetable(T)
            final_paths.append(used_path)
            final_times.append(used_timetable)
            path = copy_path(INITIAL_PATH)
            T = copy_timetable(INITIAL_T)
            updated_P = P_PLUS.union(P_MINUS)

    for i in range(len(final_times)):
        final_times[i] = clean_timetable(final_times[i])

    results_to_csv(N, final_paths, final_times)
    print('Results have been written to results.csv.')


if __name__ == '__main__':
    insertion()
