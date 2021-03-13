const { Pet } = require("./models");

const loadInitialData = async () => {
    const pets = await Pet().find({});

    if (pets.length === 0) {
        await Pet().create([
            {
                name: "Pabu",
                age: 4,
                type: "Cat",
            },
            {
                name: "Momo",
                age: 4,
                type: "Cat",
            },
        ]);
    }
};

module.exports = {
    loadInitialData,
};
