import vibe.d;
import vibe.core.log;

import std.uuid;
import std.csv;

import prebo;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", &_index);
    router.get("/search", &_search);
    router.delete_("/delete", &_delete);
    router.post("/add", &_add);
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

void _add(HTTPServerRequest req, HTTPServerResponse res)
{
    logInfo(req.form["news"].to!string);

    Card[] news;
    foreach( line; csvReader!(Tuple!(string,string,string,string,string))(req.form["news"]) ) {

        if (line == tuple("","","","","")) { continue; }

        if ( line[0].empty || line[1].empty || line[2].empty || line[3].empty ) {
            logInfo("Broken format!: %s".format(line));
            return;
        }

        Element[] elements;
        foreach( elem; line[1].split("/") ) {
            elements ~= cast(Element)elem;
        }

        logInfo("Add new Card: %s".format(line));

        news ~= Card(
            line[0],
            elements,
            cast(Category)line[2],
            cast(Rank)line[3],
            line[4]
        );
    }

    if (!news.empty) { return; }

    Box pages = reload();
    pages.addNews( news );
    pages.save("./import/kurowiz-prebo/");
    res.render!("default.dt", pages);
}


void _delete(HTTPServerRequest req, HTTPServerResponse res)
{
    UUID[] uuids;
    foreach( key, value; req.form ) {
        if (key != "uuids[]") continue;
        uuids ~= UUID(value);
    }

    Box pages = reload();
    pages.deleteUUIDs(uuids);
    pages.save("./import/kurowiz-prebo/");
    res.render!("default.dt", pages);
}
