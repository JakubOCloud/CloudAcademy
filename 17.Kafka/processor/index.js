const { Kafka } = require("kafkajs");

const INSTANCE_ID = process.env.INSTANCE_ID || "processor-1";

const kafka = new Kafka({
    clientId: `processor-service-${INSTANCE_ID}`,
    brokers: ["localhost:9092"],
});

const consumer = kafka.consumer({
    groupId: "event-processors",
});

const producer = kafka.producer();

const RAW_TOPIC = "system-events-raw";
const PROCESSED_TOPIC = "system-events-processed";
const DLQ_TOPIC = "system-events-dlq";
const SIMULATE_CRASH = process.env.SIMULATE_CRASH === "true";

function validateEvent(event) {
    if (!event.event_id) {
        return "Missing event_id";
    }

    if (!event.event_type) {
        return "Missing event_type";
    }

    if (!event.payload) {
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

async function main() {
    await consumer.connect();
    await producer.connect();

    console.log("Processor connected to Kafka");
    console.log(`Instance ID: ${INSTANCE_ID}`);
    console.log("Consumer group: event-processors");

    await consumer.subscribe({
        topic: RAW_TOPIC,
        fromBeginning: false,
    });

    console.log(`Subscribed to ${RAW_TOPIC}`);

    await consumer.run({
        autoCommit: false,

        eachBatch: async ({
            batch,
            resolveOffset,
            heartbeat,
            isRunning,
            isStale,
        }) => {
            for (const message of batch.messages) {
                if (!isRunning() || isStale()) {
                    break;
                }

                const event = JSON.parse(message.value.toString());

                console.log("\n------------------------------");
                console.log(`Processor: ${INSTANCE_ID}`);
                console.log(`Topic: ${batch.topic}`);
                console.log(`Partition: ${batch.partition}`);
                console.log(`Offset: ${message.offset}`);
                console.log(`Event ID: ${event.event_id}`);
                console.log(
                    `Order ID: ${event.payload?.order_id || "MISSING"}`
                );
                console.log("------------------------------");

                const validationError = validateEvent(event);

                if (validationError) {
                    const dlqEvent = {
                        source_event_id: event.event_id,
                        error: validationError,
                        failed_at: new Date().toISOString(),
                        original_event: event,
                    };

                    await producer.send({
                        topic: DLQ_TOPIC,
                        messages: [
                            {
                                key: event.event_id,
                                value: JSON.stringify(dlqEvent),
                            },
                        ],
                    });

                    console.log("Event sent to DLQ");
                    console.log(`Reason: ${validationError}`);
                } else {
                    const processedEvent = {
                        processed_event_id: `${event.event_id}-processed`,
                        source_event_id: event.event_id,
                        event_type: `${event.event_type}_processed`,
                        processed_at: new Date().toISOString(),
                        payload: {
                            order_id: event.payload.order_id,
                            customer_id: event.payload.customer_id,
                            amount: event.payload.amount,
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
                    console.log(
                        `Source Event ID: ${event.event_id}`
                    );
                    console.log(
                        `Processed Event ID: ${processedEvent.processed_event_id}`
                    );

                    if (SIMULATE_CRASH) {
                        console.log("Simulating application crash before offset commit...");
                        process.exit(1);
                    }
                }

                resolveOffset(message.offset);

                await heartbeat();
            }

            await consumer.commitOffsets([
                {
                    topic: batch.topic,
                    partition: batch.partition,
                    offset: (
                        BigInt(batch.messages[batch.messages.length - 1].offset) + 1n
                    ).toString(),
                },
            ]);

            console.log(
                `Committed offset for partition ${batch.partition}`
            );
        },
    });
}

main().catch(async (error) => {
    console.error(error);

    await consumer.disconnect();
    await producer.disconnect();

    process.exit(1);
});