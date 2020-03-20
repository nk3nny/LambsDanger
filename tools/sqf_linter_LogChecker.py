import sys
import os

def main():
    f = open("sqf.log", "r")
    log = f.readlines()
    if (len(log) != 9): # Change 9 to Current number of false positives
        print("Warning more than the Default number of false Positives found")
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())