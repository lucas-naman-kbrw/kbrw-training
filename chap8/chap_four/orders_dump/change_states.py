import json

with open("orders_chunk0.json", "r") as jsonFile:
    data = json.load(jsonFile)

for d in data:
    d["status"][u"state"] = u"init"

with open("orders_chunk0.json", "w") as jsonFile:
    json.dump(data, jsonFile)

with open("orders_chunk0.json", "r") as jsonFile:
    data = json.load(jsonFile)

for d in data:
    print(d["status"][u"state"])