const mongoose = require("mongoose");
const mongodb = require("./mongodb");

const petSchema = new mongoose.Schema({
    name: String,
    age: Number,
    type: String,
});

const Pet = () => {
    const connection = mongodb.getConnection();

    return connection.model("Pet", petSchema);
};

module.exports = {
    Pet,
};
