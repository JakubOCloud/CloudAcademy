const { Kafka } = require("kafkajs");
const crypto = require("crypto");

const kafka = new Kafka({
    clientId: "publisher-service",
    brokers: ["localhost:9092"],
});

const producer = kafka.producer();

const TOPIC = "system-events-raw";

function createEvent(isInvalid = false) {
    const event = {
        event_id: crypto.randomUUID(),
        event_type: "order_created",
        source_service: "publisher-service",
        timestamp: new Date().toISOString(),

        payload: {
            order_id: `A-${Math.floor(Math.random() * 10)}`,
            customer_id: `C-${Math.floor(Math.random() * 1000)}`,
            amount: Number((Math.random() * 500 + 50).toFixed(2)),
            currency: "PLN",
        },
    };

    if (isInvalid) {
        const errorType = Math.floor(Math.random() * 3);

        if (errorType === 0) {
            delete event.payload.order_id;
        }

        if (errorType === 1) {
            event.payload.amount = "invalid-amount";
        }

        if (errorType === 2) {
            delete event.payload.customer_id;
        }
    }

    return event;
}

async function main() {
    await producer.connect();

    console.log("Publisher connected to Kafka");

    for (let i = 0; i < 10; i++) {
        const isInvalid = i >= 7;
        const event = createEvent(isInvalid);

        await producer.send({
            topic: TOPIC,
            messages: [
                {
                    key: event.payload.order_id || event.event_id,
                    value: JSON.stringify(event),
                },
            ],
        });

        console.log("Published event:");
        console.log(`Event ID: ${event.event_id}`);
        console.log(`Order ID: ${event.payload.order_id || "MISSING"}`);
        console.log(`Key: ${event.payload.order_id || event.event_id}`);
        console.log(`Valid: ${!isInvalid}`);
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