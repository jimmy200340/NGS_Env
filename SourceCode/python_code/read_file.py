# open the file
my_file = open('dna.txt', 'r')

# read the contents
my_dna = my_file.read()

# calculate the length
dna_length = len(my_dna)

# print the output
print("sequence is "+ my_dna + "\nand length is " + str(dna_length))
# sequence is ACTGTACGTGCACTGATC
# and length is 19
