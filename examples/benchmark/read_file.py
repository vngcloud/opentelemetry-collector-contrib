import sys

# Check if the correct number of command-line arguments is provided
if len(sys.argv) != 2:
    print("Usage: python read_file_line_by_line.py <file_path>")
    sys.exit(1)

# Get the file path from the command-line argument
file_path = sys.argv[1]

try:
    # Open the file for reading
    with open(file_path, 'r') as file:
        # Read and print each line of the file
        res = []
        for line in file:
            # print(line, end='')  # The 'end='' is used to prevent double spacing between lines
            arr = line.split()
            # print(arr)
            if len(arr) == 0:
                continue
            # if arr[0] in ['transactions:', 'queries:', 'reconnects:']:
            if arr[0] in ['transactions:']:
                res = res + [arr[2][1:]]
            # if arr[0] in ['min:', 'avg:', 'max:']:
            #     res = res + [arr[1]]
            # if arr[0] in ['ignored']:
            #     res = res + [arr[3][1:]]
            # if arr[0] in ['95th']:
            #     res = res + [arr[2]]
        # print(res)
        # to float
        # print([float(i) for i in res])
        # print res by space
        print(' '.join(res))



except FileNotFoundError:
    print(f"File not found: {file_path}")
except Exception as e:
    print(f"An error occurred: {e}")
