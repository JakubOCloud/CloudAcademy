const { Kafka } = require("kafkajs");

const INSTANCE_ID = process.env.INSTANCE_ID || "processor-1";

const kafka = new Kafka({
    clientId: `processor-service-${INSTANCE_ID}`,
    brokers: ["localhost:9092"],
});

const consumer = kafka.consumer({
    groupId: "event-processors-replay",
});

const producer = kafka.producer();

const RAW_TOPIC = "system-events-raw";
const PROCESSED_TOPIC = "system-events-processed";
const DLQ_TOPIC = "system-events-dlq";

const SIMULATE_CRASH = process.env.SIMULATE_CRASH === "true";

function validateEvent(event) {
    if (!event || typeof event !== "object") {
        return "Event must be an object";
    }

    if (!event.event_id) {
        return "Missing event_id";
    }

    if (!event.event_type) {
        return "Missing event_type";
    }

    if (!event.payload || typeof event.payload !== "object") {
        return "Missing payload";
    }

    if (!event.payload.order_id) {
        return "Missing order_id";
    }

    if (!event.payload.customer_id) {
        return "Missing customer_id";
    }

    if (typeof event.payload.amount !== "number") {
        return "Amount must be a number";
    }

    if (!event.payload.currency) {
        return "Missing currency";
    }

    return null;
}

async function sendToDLQ(message, error, originalEvent = null) {
    const dlqEvent = {
        source_event_id: originalEvent?.event_id || null,
        error,
        failed_at: new Date().toISOString(),
        original_event: originalEvent,
        original_message: {
            key: message.key?.toString() || null,
            value: message.value?.toString() || null,
        },
    };

    await producer.send({
        topic: DLQ_TOPIC,
        messages: [
            {
                key:
                    originalEvent?.event_id ||
                    message.key?.toString() ||
                    message.offset,
                value: JSON.stringify(dlqEvent),
            },
        ],
    });

    console.log("Event sent to DLQ");
    console.log(`Reason: ${error}`);
}

async function processMessage(message, partition) {
    let event;

    try {
        event = JSON.parse(message.value.toString());
    } catch (error) {
        console.error(`Invalid JSON at offset ${message.offset}`);

        await sendToDLQ(
            message,
            `Invalid JSON: ${error.message}`
        );

        return;
    }

    console.log("\n------------------------------");
    console.log(`Processor: ${INSTANCE_ID}`);
    console.log(`Topic: ${RAW_TOPIC}`);
    console.log(`Partition: ${partition}`);
    console.log(`Offset: ${message.offset}`);
    console.log(`Event ID: ${event.event_id || "MISSING"}`);
    console.log(
        `Order ID: ${event.payload?.order_id || "MISSING"}`
    );
    console.log("------------------------------");

    const validationError = validateEvent(event);

    if (validationError) {
        await sendToDLQ(
            message,
            validationError,
            event
        );

        return;
    }

    const processedEvent = {
        processed_event_id: `${event.event_id}-processed-v2`,
        source_event_id: event.event_id,
        event_type: `${event.event_type}_processed_v2`,
        processed_at: new Date().toISOString(),
        payload: {
            order_id: event.payload.order_id,
            customer_id: event.payload.customer_id,
            amount: event.payload.amount,
            amount_with_fee: Number(
                (event.payload.amount * 1.23).toFixed(2)
            ),
            currency: event.payload.currency,
        },
    };

    await producer.send({
        topic: PROCESSED_TOPIC,
        messages: [
            {
                key: event.payload.order_id,
                value: JSON.stringify(processedEvent),
            },
        ],
    });

    console.log("Event processed successfully");
    console.log(`Source Event ID: ${event.event_id}`);
    console.log(
        `Processed Event ID: ${processedEvent.processed_event_id}`
    );

    if (SIMULATE_CRASH) {
        console.log(
            "Simulating application crash before offset commit..."
        );

        process.exit(1);
    }
}

async function main() {
    await consumer.connect();
    await producer.connect();

    console.log("Processor connected to Kafka");
    console.log(`Instance ID: ${INSTANCE_ID}`);
    console.log("Consumer group: event-processors-replay");

    await consumer.subscribe({
        topic: RAW_TOPIC,
        fromBeginning: true,
    });

    console.log(`Subscribed to ${RAW_TOPIC}`);

    await consumer.run({
        autoCommit: false,

        eachMessage: async ({
            topic,
            partition,
            message,
        }) => {
            try {
                await processMessage(message, partition);

                const nextOffset = (
                    BigInt(message.offset) + 1n
                ).toString();

                await consumer.commitOffsets([
                    {
                        topic,
                        partition,
                        offset: nextOffset,
                    },
                ]);

                console.log(
                    `Committed offset ${nextOffset} for partition ${partition}`
                );
            } catch (error) {
                console.error(
                    `Processing error at offset ${message.offset}:`,
                    error
                );
            }
        },
    });
}

main().catch(async (error) => {
    console.error(error);

    try {
        await consumer.disconnect();
    } catch (e) { }

    try {
        await producer.disconnect();
    } catch (e) { }

    process.exit(1);
});