import vibe.d;
import vibe.core.log;

import prebo;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", &index);
    router.get("/search", &search);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto logger = cast(shared)( new FileLogger("access.log") );
    registerLogger(logger);

    listenHTTP( settings, router );
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
    Box box = Box();
    box.reload;
    res.render!("index.dt", box);
}

void search(HTTPServerRequest req, HTTPServerResponse res)
{
    //string[] test = req.queryString.split('&');
    //logInfo(test.to!string);
    logInfo(req.query.length.to!string);
    logInfo(req.query.to!string);

    foreach( key, value; req.query )
    {
        logInfo( key ~ ":" ~ value );
    }
}
