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
    Box pages = Box();
    pages.reload;
    res.render!("index.dt", pages);
}

void search(HTTPServerRequest req, HTTPServerResponse res)
{
    logInfo(req.query.to!string);

    string[] names;
    string[] elements;
    string[] categories;

    foreach( key, value; req.query )
    {
        switch( key ) {
            case "name": {
                if( !value.empty )
                    names ~= value;
            } break;

            case "element": {
                elements ~= value;
            } break;

            case "category": {
                categories ~= value;
            } break;

            default: {

            } break;
        }
    }

    Box box = Box();
    box.reload;

    auto pages =
        Query(box)
            .search( QueryKey.Name, names )
            .search( QueryKey.Element, elements )
            .search( QueryKey.Category, categories );

    res.render!("index.dt", pages);
}
