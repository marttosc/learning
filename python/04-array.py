list = [1, 2, 3]

print list * 3
print list + [4, 5, 6]

for i in list:
    print i * 2

for i in list:
    if i % 2 == 0:
        print "even"
    else:
        print "odd"
