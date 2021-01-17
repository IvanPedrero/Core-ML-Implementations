import json

APPLE_PRODUCTS = ["Apple", "iPhone", "iPod", "iPad",
    "Mac", "AirPods", "Watch", "Pencil", "Catalyst", "M1"]

# Training samples.
training_sentences = [
    "The iPhone is incredible !",
    "The new Mac models will have a M1 processor, no more Intel on Mac .",
    "The iPod is still in the market .",
    "The new AirPods will provide awesome sound quality .",
    "The iPad is a great tool for productivity .",
    "AirPods are a fantastic Apple product .",
    "The iPhone takes stunning photos .",
    "The Apple Watch is an incredible tool to pair with your iPhone .",
    "The Apple Pencil can turn you iPad into a sketch book ."
    "Start building a native Mac app from your current iPad ap using Mac Catalyst ."
]


# Query-like sentences.
testing_sentences = [
    "I want an iPhone",
    "Mac M1 price USA",
    "Amazon iPad",
    "Where to buy an iPhone",
    "How to create a iPad app ?",
    "Where can I buy an Apple Watch ?",
    "Is the Apple Pencil worth it ?"
]


def generateData(sentences):
    dic_array= []

    for sentence in sentences:
        tokens= sentence.split()
        labels= []

        for word in tokens:
            if word in APPLE_PRODUCTS:
                labels.append("PROD")
            else:
                labels.append("NONE")

        dic= {'tokens': tokens, 'labels': labels}

        dic_array.append(dic)

    return dic_array


def createJson(dic, filename):
    with open(filename + ".json", 'w') as file:
        file.write(json.dumps(dic, indent=4))


if __name__ == "__main__":
    training_data= generateData(training_sentences)
    createJson(training_data, "training_data")

    testing_data= generateData(testing_sentences)
    createJson(testing_data, "testing_data")
