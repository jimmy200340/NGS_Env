fish = ['anchovy', 'barracuda', 'cod', 'devil ray', 'eel', 'flounder']
more_fish = ['goby','herring','ide','kissing gourami']

fish2 = fish+more_fish
print(len(fish2))
# 10

fish.extend(more_fish)
print(len(fish))
# 10