apes = ["Homo sapiens", "Pan troglodytes", "Gorilla gorilla", "Pan paniscus"]

apes2 = apes[1:3]
print(apes2)
# ["Pan troglodytes", "Gorilla gorilla"]

monkeys = ["Papio ursinus", "Macaca mulatta"]
primates = apes + monkeys

print(str(len(apes)) + " apes")
# 4 apes
print(str(len(monkeys)) + " monkeys")
# 2 monkeys
print(str(len(primates)) + " primates")
# 5 primates