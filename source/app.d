import vibe.d;
import vibe.core.log;

import prebo;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", &_index);
    router.get("/search", &_search);
    router.delete_("/delete", &_delete);
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "0.0.0.0"];

    auto logger = cast(shared)( new FileLogger("access.log") );
    registerLogger(logger);

    listenHTTP( settings, router );
}

Box reload()
{
    Box box = Box();
    box.reload;
    return box;
}

void _index(HTTPServerRequest req, HTTPServerResponse res)
{

    string[] names = [];
    string[] elements = [ "fire", "water", "thunder" ];
    string[] categories = [ "spirit", "material", "ether", "mana" ];
    string[] ranks = [ "L", "SS+", "SS", "S+", "S", "A+", "A", "B+", "B", "C+" ];

    Box pages = reload();

    res.render!("default.dt", pages, names, elements, categories, ranks);
}

void _search(HTTPServerRequest req, HTTPServerResponse res)
{
    logInfo(req.query.to!string);

    string[] names;
    string[] elements;
    string[] categories;
    string[] ranks;

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

            case "rank": {
                ranks ~= value;
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
            .search( QueryKey.Category, categories )
            .search( QueryKey.Rank, ranks );

    auto sorted = pages.sort();
    auto aggregated = pages.aggregate();

    res.render!("tab.dt", pages, sorted, aggregated, names, elements, categories, ranks);
}

void _delete(HTTPServerRequest req, HTTPServerResponse res)
{
    string[] uuids;
    foreach( key, value; req.form ) {
        if (key != "uuids[]") continue;
        uuids ~= value;
    }
    logInfo(uuids.to!string);

    Box pages = reload();
    res.render!("default.dt", pages);
}
