const express = require("express");

const app = express();

app.use(express.json());

const tasks = [
    {
        id: 1,
        title: "Learn Jenkins",
        completed: false
    },
    {
        id: 2,
        title: "Create CI pipeline",
        completed: false
    }
];

app.get("/health", (req, res) => {
    res.status(200).json({
        status: "ok"
    });
});

app.get("/tasks", (req, res) => {
    res.status(200).json(tasks);
});

const PORT = process.env.PORT || 3000;

if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
}

module.exports = app;