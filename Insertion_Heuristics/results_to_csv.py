"""
Converts results (path and timetable) into a csv
"""
from os.path import exists
import csv
from metrics import get_route_metrics


def results_to_csv(nodes, paths, timetables, hh_id):
    """
    Converts the results into a csv named resutls.csv and writes the results.
    :param nodes: The nodes in the network (N in Insertion.py)
    :param paths: The list of paths being used
    :param timetables: The list of timetables being used
    """
    fields = ['Nodes'] + list(nodes) + ['', '', '', 'u', 'T', 'wait time']
    results = []
    for i in range(len(paths)):
        for j in range(len(paths[i])):
            if j < len(timetables[i]):
                key = list(timetables[i].keys())[j]
                results.append([j] + paths[i][j] + ['', '', '', key] + timetables[i][key])
            else:
                results.append([j] + paths[i][j])

        results.append('')

    if exists(f'../{hh_id}_results.csv'):
        mode = 'w'

    else:
        mode = 'a'

    with open(f'../{hh_id}_results.csv', mode, newline='') as results_file:
        writer = csv.writer(results_file)
        writer.writerow(fields)
        writer.writerows(results)


def record_metrics(d, t, s, depot, paths, timetables, hh_id):
    """
    Records the metrics in the metrics.csv file.
    :param d: The travel distance matrix.
    :param t: The travel time matrix.
    :param s: The request durations.
    :param depot: The depot node.
    :param paths: The list of used paths.
    :param timetables: The list of used timetables.
    """
    fields = ['Vehicle #', 'R(d)', 'R(t)', 'Wait Time', 'Avg. Occupancy']
    path_metrics = []
    for i in range(len(paths)):
        row = [i+1]

        row.extend(get_route_metrics(d, t, s, depot, paths[i], timetables[i]))
        path_metrics.append(row)
    if exists(f'../{hh_id}_metrics.csv'):
        mode = 'w'

    else:
        mode = 'a'

    with open(f'../{hh_id}_metrics.csv', mode, newline='') as metrics_file:
        writer = csv.writer(metrics_file)
        writer.writerow(fields)
        writer.writerows(path_metrics)
