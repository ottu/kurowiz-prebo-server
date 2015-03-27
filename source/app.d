import vibe.d;
import vibe.core.log;

import prebo;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", &hello);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto logger = cast(shared)( new FileLogger("access.log") );
    registerLogger(logger);

    listenHTTP( settings, router );
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
    Box box = Box();
    box.reload;
    res.render!("index.dt", box);
}
