apes = ["Homo sapiens", "Pan troglodytes", "Gorilla gorilla"]

print(apes[0] + " is an ape")
print(apes[1] + " is an ape")
print(apes[2] + " is an ape")
print()

for i in range(0, 3, 1):
    print(apes[i] + " is an ape")
print()

for ape in apes:
    print(ape + " is an ape")