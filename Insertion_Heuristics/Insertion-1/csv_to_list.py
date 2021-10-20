"""
This program contains the program that will convert data from a
csv into an array, which can be used for matricies of network data.
"""
import csv


def csv_to_array(csv_path):
    """
    Converts a csv to an array given the path of the csv.
    :param csv_path: The path of the csv file in a string.
    :return: The csv converted to an array.
    """
    with open(csv_path) as csv_file:
        reader = csv.reader(csv_file, quoting=csv.QUOTE_NONNUMERIC)
        array = [row for row in reader]

    if len(array) == 1:
        return array[0]

    return array
