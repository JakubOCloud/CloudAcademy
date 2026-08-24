const { Kafka } = require("kafkajs");

const INSTANCE_ID = process.env.INSTANCE_ID || "processor-1";

const kafka = new Kafka({
    clientId: `processor-service-${INSTANCE_ID}`,
    brokers: ["localhost:9092"],
});

const consumer = kafka.consumer({
    groupId: "event-processors",
});

const TOPIC = "system-events";

async function main() {
    await consumer.connect();

    console.log(`Processor connected to Kafka`);
    console.log(`Instance ID: ${INSTANCE_ID}`);
    console.log(`Consumer group: event-processors`);

    await consumer.subscribe({
        topic: TOPIC,
        fromBeginning: true,
    });

    console.log(`Subscribed to ${TOPIC}`);

    await consumer.run({
        eachMessage: async ({ topic, partition, message }) => {
            const event = JSON.parse(message.value.toString());

            console.log("\n------------------------------");
            console.log(`Processor: ${INSTANCE_ID}`);
            console.log(`Topic: ${topic}`);
            console.log(`Partition: ${partition}`);
            console.log(`Offset: ${message.offset}`);
            console.log(`Event ID: ${event.event_id}`);
            console.log(`Order ID: ${event.payload.order_id}`);
            console.log("------------------------------");

            console.log("Event:");
            console.log(JSON.stringify(event, null, 2));
        },
    });
}

main().catch(async (error) => {
    console.error(error);
    await consumer.disconnect();
    process.exit(1);
});