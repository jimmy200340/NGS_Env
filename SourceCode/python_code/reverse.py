ranks = ["kingdom","phylum", "class", "order", "family"]
print("at the start : " + str(ranks))
# ["kingdom","phylum", "class", "order", "family"]

ranks.reverse()
print("after reversing : " + str(ranks))
# ['family', 'order', 'class', 'phylum', 'kingdom']

ranks.sort()
print("after sorting : " + str(ranks))
# ['class', 'family', 'kingdom', 'order', 'phylum']