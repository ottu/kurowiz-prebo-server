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
import std.uuid;

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
    SSP = "SS+",
    L = "L",
    None = "N"
}

struct Card
{
    UUID uuid;
    string name;
    Element[] elements;
    Category category;
    Rank rank;
    string option;

    this( string name, Element[] elements, Category category, Rank rank, string option = "" )
    {
        this.uuid = randomUUID();
        this.name = name;
        this.elements = elements;
        this.category = category;
        this.rank = rank;
        this.option = option;
    }

    this( JSONValue json )
    {
        this.uuid = randomUUID();
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

    JSONValue toJson() const
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

    string toString() const
    {
        return "( name: %s, element: %s, category: %s, rank: %s, option: %s )"
               .format( name, elements, category, rank, option );
    }
}

struct PagedCard
{
    immutable uint index;
    const Card card;
    alias card this;

    string toString() { return "page: %4d, card: %s".format( index, card.toString ); }
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

    void addNews( Card[] news )
    {
        cards = news ~ cards;
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

    void save()
    {
        JSONValue[] pages = [];
        foreach( index, cards; this )
        {
            JSONValue[string] page;
            page["page"] = index;
            page["cards"] = cards.map!"a.toJson".array;
            pages ~= JSONValue( page );
        }

        auto root = JSONValue( [ "pages": pages ] );

        if ( exists("./backup.json") )
            std.file.remove("./backup.json");
        if ( exists("./list.json") )
            std.file.rename("./list.json", "./backup.json");
        std.file.write("./list.json", root.toPrettyString);
    }
}

enum QueryKey
{
    Name, Element, Category, Rank
}

struct Query
{
    PagedCard[] cards;
    alias cards this;

    this( PagedCard[] cards )
    {
        this.cards = cards;
    }

    this( Box box )
    {
        foreach( index, cards; box ) {
            foreach( card; cards ) {
                this.cards ~= PagedCard( index, card );
            }
        }
    }

    Query search( QueryKey key, string[] values )
    {
        if (values.empty) {
            return this;
        }

        PagedCard[] result = [];
        foreach( card; cards )
        {
            final switch (key)
            {
                case QueryKey.Name:
                {
                    bool found = false;
                    foreach( name; values ) {
                        if ( match( card.name, regex(name) ) ) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) continue;
                } break;

                case QueryKey.Element:
                {
                    bool found = false;
                    foreach( element; card.elements )
                    {
                        if (!find(values, element).empty) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) continue;
                } break;

                case QueryKey.Category:
                {
                    if (find(values, card.category).empty) {
                        continue;
                    }
                } break;

                case QueryKey.Rank:
                {
                    if (find(values, card.rank).empty) {
                        continue;
                    }

                } break;
            }
            result ~= card;
        }
        return Query(result);
    }

    private enum FinishKey { Sort, Aggregate }
    private auto finish( FinishKey FK )()
    {
        PagedCard[][string][string][string][string][string] temp;
        foreach( card; cards ) {
            temp[card.elements[0]][card.category][card.name][card.rank][card.option] ~= card;
        }

        static if ( FK == FinishKey.Sort )
            PagedCard[] result;
        else static if ( FK == FinishKey.Aggregate )
            Tuple!( ulong, const(Card) )[] result; // this.aggregate() return type.

        foreach( key1; temp.keys ) {
            auto value1 = temp[key1];
            foreach( key2; value1.keys ) {
                auto value2 = value1[key2];
                foreach( key3; value2.keys ) {
                    auto value3 = value2[key3];
                    foreach( key4; value3.keys ) {
                        auto value4 = value3[key4];
                        foreach( key5; value4.keys ) {
                            auto value5 = value4[key5];

                            static if ( FK == FinishKey.Sort )
                                result ~= value5;
                            else static if ( FK == FinishKey.Aggregate )
                                result ~= tuple( value5.length, value5[0].card );
                        }
                    }
                }
            }
        }

        return result;
    }

    Query sort()
    {
        return Query( finish!(FinishKey.Sort)() );
    }

    auto aggregate()
    {
        return finish!(FinishKey.Aggregate)();
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

    Box box = Box();
    box.reload;
    box.addNews( news );
    box.save;
}

void search(string[] args)
{
    arraySep = ",";

    string[] names = [];
    string[] elements = [];
    string[] categories = [];
    string[] ranks = [];
    bool sort_flag = false;
    bool aggregate_flag = false;
    getopt( args,
        "name", &names,
        "element", &elements,
        "category", &categories,
        "rank", &ranks,
        "sort", &sort_flag,
        "aggregate", &aggregate_flag
    );

    Box box = Box();
    box.reload;
    auto searched =
        Query( box )
            .search( QueryKey.Name, names )
            .search( QueryKey.Element, elements )
            .search( QueryKey.Category, categories )
            .search( QueryKey.Rank, ranks );

    if ( sort_flag )
        searched = searched.sort;

    if ( aggregate_flag ) {
        foreach ( cache; searched.aggregate() ) {
            writefln( "count: %4d, card: %s", cache[0], cache[1].toString );
        }
    } else {
        foreach ( card; searched ) {
            writeln( card );
        }
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
