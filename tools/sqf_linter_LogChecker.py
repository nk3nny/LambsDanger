import sys
import os

defaultFalsePositives = 13 # Change 0 to Current number of false positives
def main():
    f = open("sqf.log", "r")
    log = f.readlines()
    if (len(log) == defaultFalsePositives):
        print("{} number of false Positives found".format( len(log) ))
        return 0
    print("Warning {} than the Default number of false Positives found".format( len(log) - defaultFalsePositives ))
    return 1

if __name__ == "__main__":
    sys.exit(main())
