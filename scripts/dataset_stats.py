from dataset import dfg_dataset

labels = {v: k for k, v in dfg_dataset.labels.items()}

result = { v: 0 for k, v in labels.items() }

for item in dfg_dataset:
  item_labels = item[1]['labels'].tolist()
  names = [labels[id] for id in item_labels]
  for name in names:
    result[name] += 1

print(result)
