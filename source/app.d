import std.stdio;
import std.json;
import std.algorithm;
import std.string;
import std.conv;
import std.file;
import std.range;
import std.array;
import std.getopt;
import std.typecons;

enum Command: string {
    Generate = "generate",
    Search = "search"
}

enum Element: string {
    None = "none",
    Fire = "fire",
    Water = "water",
    Thunder = "thunder",
    Mana = "mana",
    Ether = "ether"
}

void generate()
{
    auto list = readText("./list.json");
    auto json = parseJSON(list);

    auto f = File("./news.csv");
    JSONValue[] news = [];
    foreach( line; f.byLine ) {
        string[3] parsed = line.split(',');

        string element = "";
        switch (parsed[1]) {
            case "f": { element = Element.Fire; } break;
            case "w": { element = Element.Water; } break;
            case "t": { element = Element.Thunder; } break;
            case "m": { element = Element.Mana; } break;
            case "e": { element = Element.Ether; } break;
            default: { element = Element.None; } break;
        }
        news ~= JSONValue( [
            "name": parsed[0].idup,
            "element": element,
            "rank": parsed[2].idup
        ] );
    }

    foreach( page; json["pages"].array ) {
        foreach( card; page["cards"].array) {
            news ~= card;
        }
    }

    auto chunked = news.chunks(10);

    JSONValue[] generated = [];
    foreach( i, chunk; chunked.array ) {
        JSONValue[] cards = [];
        foreach( j, card; chunk ) {
            card.object["row"] = j+1;
            cards ~= card;
        }

        auto gen = JSONValue([ "page": i+1 ]);
        gen.object["cards"] = cards;
        generated ~= gen;
    }

    auto root = JSONValue( [ "pages": generated ] );

    writeln( root );

}

void search(string[] args)
{

    arraySep = ",";

    string[] names = [];
    Element[] elements = [];
    string[] ranks = [];
    getopt( args,
        "name", &names,
        "element", &elements,
        "rank", &ranks
    );

    auto file = readText("./list.json");
    auto json = parseJSON(file);

    Tuple!(long, JSONValue)[] searched = [];
    foreach( page; json["pages"].array ) {
        foreach( card; page["cards"].array ) {
            if (!names.empty && find(names, card["name"].str).empty) {
                continue;
            }
            if (!elements.empty && find(elements, card["element"].str).empty) {
                continue;
            }
            if (!ranks.empty && find(ranks, card["rank"].str).empty) {
                continue;
            }
            searched ~= tuple( page["page"].integer, card );
        }
    }

    foreach ( card; searched ) {
        writeln( "page: %03d, card: %s".format( card[0], card[1] ) );
    }

}

void main( string[] args )
{
    if ( args.length < 2 ) {
        writeln("Insufficient arguments.");
        return;
    }

    string command = args[1];
    switch (command) {
        case Command.Generate: {
           generate();
        } break;

        case Command.Search: {
            search(args);
        } break;

        default: {
            writeln("Usage: ./colosort {generate|search}");
        } break;
    }

}
