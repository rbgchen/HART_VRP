"""
Converts results (path and timetable) into a csv
"""
from os.path import exists
import csv


def results_to_csv(nodes, paths, timetables):
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

    if exists('../results.csv'):
        mode = 'w'

    else:
        mode = 'a'

    with open('../results.csv', mode, newline='') as results_file:
        writer = csv.writer(results_file)
        writer.writerow(fields)
        writer.writerows(results)
