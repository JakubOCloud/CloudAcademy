const { Kafka } = require("kafkajs");

const kafka = new Kafka({
    clientId: "processor-service",
    brokers: ["localhost:9092"],
});

const consumer = kafka.consumer({
    groupId: "event-processors",
});

const TOPIC = "system-events";

async function main() {
    await consumer.connect();

    console.log("Processor connected to Kafka");

    await consumer.subscribe({
        topic: TOPIC,
        fromBeginning: true,
    });

    console.log(`Subscribed to ${TOPIC}`);

    await consumer.run({
        eachMessage: async ({ topic, partition, message }) => {
            const event = JSON.parse(message.value.toString());

            console.log("\nReceived event:");
            console.log(`Topic: ${topic}`);
            console.log(`Partition: ${partition}`);
            console.log(`Offset: ${message.offset}`);
            console.log(JSON.stringify(event, null, 2));
        },
    });
}

main().catch(async (error) => {
    console.error(error);
    await consumer.disconnect();
    process.exit(1);
});