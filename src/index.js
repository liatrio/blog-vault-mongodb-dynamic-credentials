const hapi = require("@hapi/hapi");
const mongodb = require("./mongodb");

(async () => {
    const server = hapi.server({
        port: 5555,
        host: "0.0.0.0",
    });

    server.route({
        method: "GET",
        path: "/healthz",
        handler: () => "ok",
    });

    server.route({
        method: "GET",
        path: "/",
        handler: () => "hello world",
    });

    await mongodb.start();
    await server.start();

    console.log("Server running on %s", server.info.uri);

    ["SIGINT", "SIGTERM"].forEach((signal) => {
        process.on(signal, async () => {
            console.log("Termination signal %s received, stopping...", signal);

            await stop(server);
        });
    });

    process.on("unhandledRejection", async (err) => {
        console.log("Unhandled promise rejection", err);

        await stop(server, 1);
    });
})();

const stop = async (server, code = 0) => {
    try {
        await mongodb.stop();
        await server.stop();
    } catch (e) {
        console.log("Error stopping server", e);

        return process.exit(1);
    }

    return process.exit(code);
};
