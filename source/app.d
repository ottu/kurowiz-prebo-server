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
import std.csv;
import std.regex;

enum Command: string {
    Generate = "generate",
    Search = "search"
}

enum Element: string {
    Fire = "fire",
    Water = "water",
    Thunder = "thunder",
    None = "none"
}

enum Category: string {
    Spirit = "spirit",
    Material = "material",
    Mana = "mana",
    Ether = "ether",
    Mate = "mate",
    Crystal = "crystal",
    Gold = "gold"
}

enum Rank: string {
    CP = "C+",
    B = "B",
    BP = "B+",
    A = "A",
    AP = "A+",
    S = "S",
    SP = "S+",
    SS = "SS",
    L = "L",
    None = "N"
}

struct Card
{
    string name;
    Element[] elements;
    Category category;
    Rank rank;
    string option;

    this( string name, Element[] elements, Category category, Rank rank, string option = "" )
    {
        this.name = name;
        this.elements = elements;
        this.category = category;
        this.rank = rank;
        this.option = option;
    }

    this( JSONValue json )
    {
        this.name = json["name"].str;

        Element[] elements = [];
        foreach( elem; json["element"].str.split('/') ) {
            elements ~= cast(Element)(elem.to!string);
        }
        this.elements = elements;
        this.category = cast(Category)(json["category"].str);
        this.rank = cast(Rank)(json["rank"].str);
        this.option =json["option"].str;
    }

    JSONValue toJson()
    {
        string elements = "";
        foreach( elem; this.elements ) {
            elements ~= elem;
        }
        elements = elements[0..$-1];

        return JSONValue( [
            "name": this.name,
            "element": this.elements.join("/"),
            "category": this.category,
            "rank": this.rank,
            "option": this.option
        ] );
    }
}

struct Box
{
    Card[] cards;

    void reload()
    {
        cards = [];
        auto f = readText("./list.json");
        auto json = parseJSON(f);

        foreach( page; json["pages"].array ) {
            foreach( card; page["cards"].array ) {
                cards ~= Card( card );
            }
        }
    }

    int opApply( int delegate( ref uint, ref const(Card)[] ) dg ) const
    {
        int result = 0;
        auto chunked = cards.chunks(10).array;

        uint index = 1;
        foreach( cards; chunked ) {
            result = dg( index, cards );
            if (result) break;
            index++;
        }
        return result;
    }
}

unittest
{
    Card card1 = Card( "TEST1", [Element.Fire], Category.Spirit, Rank.None, "" );
    Card card2 = Card( "TEST2", [Element.Water], Category.Spirit, Rank.None, "" );
    Card card3 = Card( "TEST3", [Element.Thunder], Category.Spirit, Rank.None, "" );

    Box box = Box();
    box.cards ~= card1;
    box.cards ~= card2;
    box.cards ~= card3;

    foreach( index, cards; box ) {
        assert( index == 1 );
        assert( cards[0] == card1 );
        assert( cards[1] == card2 );
        assert( cards[2] == card3 );
    }
}

void generate()
{
    auto f = readText("./news.csv");

    Card[] news = [];
    foreach( line; csvReader!(Tuple!(string,string,string,string,string))(f) ) {

        if ( line == tuple("","","","","") ) { continue; }

        Element[] elements = [];
        foreach( elem; line[1].split('/') ) {
            elements ~= cast(Element)(elem);
        }

        news ~= Card(
            line[0],
            elements,
            cast(Category)line[2],
            cast(Rank)line[3],
            line[4]
        );
    }

    auto list = readText("./list.json");
    auto json = parseJSON(list);

    foreach( page; json["pages"].array ) {
        foreach( card; page["cards"].array) {
            news ~= Card( card );
        }
    }

    auto chunked = news.chunks(10);

    JSONValue[] generated = [];
    foreach( i, page; chunked.array ) {
        JSONValue[] cards = [];
        foreach( j, card; page ) {
            cards ~= card.toJson;
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
    string[] elements = [];
    string[] categories = [];
    string[] ranks = [];
    getopt( args,
        "name", &names,
        "element", &elements,
        "category", &categories,
        "rank", &ranks
    );

    auto file = readText("./list.json");
    auto json = parseJSON(file);

    Tuple!(long, JSONValue)[] searched = [];
    foreach( page; json["pages"].array ) {
        foreach( card; page["cards"].array ) {
            if (!names.empty) {
                bool found = false;
                foreach( name; names ) {
                    if ( match( card["name"].str, regex(name) ) ) {
                        found = true;
                        break;
                    }
                }
                if (!found) continue;
            }
            if (!elements.empty && find(elements, card["element"].str).empty) {
                continue;
            }
            if (!categories.empty && find(categories, card["category"].str).empty) {
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
