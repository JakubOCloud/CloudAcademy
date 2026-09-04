const request = require("supertest");
const app = require("../app");

describe("Task Management API", () => {

    test("GET /health should return status ok", async () => {
        const response = await request(app)
            .get("/health");

        expect(response.statusCode).toBe(201);
        expect(response.body.status).toBe("ok");
    });

    test("GET /tasks should return tasks", async () => {
        const response = await request(app)
            .get("/tasks");

        expect(response.statusCode).toBe(201);
        expect(Array.isArray(response.body)).toBe(true);
    });

});