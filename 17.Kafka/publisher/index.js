const { Kafka } = require("kafkajs");
const crypto = require("crypto");

const kafka = new Kafka({
    clientId: "publisher-service",
    brokers: ["localhost:9092"],
});

const producer = kafka.producer();

const TOPIC = "system-events";

function createEvent() {
    return {
        event_id: crypto.randomUUID(),
        event_type: "order_created",
        source_service: "publisher-service",
        timestamp: new Date().toISOString(),

        payload: {
            order_id: `A-${Math.floor(Math.random() * 100000)}`,
            customer_id: `C-${Math.floor(Math.random() * 1000)}`,
            amount: Number((Math.random() * 500 + 50).toFixed(2)),
            currency: "PLN",
        },
    };
}

async function main() {
    await producer.connect();

    console.log("Publisher connected to Kafka");

    for (let i = 0; i < 10; i++) {
        const event = createEvent();

        await producer.send({
            topic: TOPIC,
            messages: [
                {
                    value: JSON.stringify(event),
                },
            ],
        });

        console.log("Published event:");
        console.log(event);

        await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    await producer.disconnect();

    console.log("Publisher disconnected");
}

main().catch(async (error) => {
    console.error(error);
    await producer.disconnect();
    process.exit(1);
});