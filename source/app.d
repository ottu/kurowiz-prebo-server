import std.stdio;
import std.json;
import std.algorithm;
import std.string;
import std.conv;
import std.file;
import std.range;
import std.array;

void main()
{
    auto list = readText("./list.json");
    auto json = parseJSON(list);

    auto f = File("./news.csv");
    JSONValue[] news = [];
    foreach( line; f.byLine ) {
        string[3] parsed = line.split(',');

        string element = "";
        switch (parsed[1]) {
            case "f": { element = "fire"; } break;
            case "w": { element = "water"; } break;
            case "t": { element = "thunder"; } break;
            case "m": { element = "mana"; } break;
            case "e": { element = "ether"; } break;
            default: {} break;
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

    writeln( generated );
}
